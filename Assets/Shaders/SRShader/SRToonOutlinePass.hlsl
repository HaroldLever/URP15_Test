#ifndef SR_TOON_OUTLINE_PASS_INCLUDED
#define SR_TOON_OUTLINE_PASS_INCLUDED

struct appdata
{
    float4 vertex : POSITION;
    half3 normal : NORMAL;
    half4 tangent : TANGENT;
    half4 vertexCol : COLOR;
    float2 uv : TEXCOORD0;

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float4 pos : SV_POSITION;
    half4 vertexCol : COLOR;
    float2 uv : TEXCOORD0;
    float fogCoord : TEXCOORD1; 
    float3 wPos : TEXCOORD2;
    float3 vertexSH : TEXCOORD3;
    half4 fPos : TEXCOORD4;

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

v2f SRToonOutlineVertex (appdata v)
{
    v2f o;

    // GPU实例化
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    o.wPos = TransformObjectToWorld(v.vertex.xyz);
    o.pos = TransformObjectToHClip(v.vertex.xyz);
    o.uv = v.uv;
    o.vertexCol = v.vertexCol;

    half3 oNor = v.normal.xyz;
    oNor *= v.vertexCol.a;

    // 裁剪空间下的顶点位置
    float4 cOutlinePos = TransformObjectToHClip(v.vertex.xyz + oNor * _OutlineParam.y);
    float4 cPos = TransformObjectToHClip(v.vertex.xyz);
    // NDC空间下的顶点位置
    float4 ndcOutlinePos = cOutlinePos / cOutlinePos.w;
    float4 ndcPos = cPos / cPos.w;
    // 屏幕空间下的顶点距离（仅xy）
    float2 sDist = (ndcOutlinePos.xy - ndcPos.xy) * _ScreenParams.xy;
    // 法线缩放系数
    float norScaleFac = sqrt(dot(sDist.xy, sDist.xy)) / _OutlineParam.x;
    // 输出pos
    if(norScaleFac > 1.0){
        o.pos = TransformObjectToHClip(v.vertex.xyz + oNor * _OutlineParam.y / norScaleFac);
    }else{
        o.pos = cOutlinePos;
    }

    o.fPos = TransformObjectToHClip(v.vertex.xyz);
    
    #if defined(_FOG_FRAGMENT)
        o.fogCoord = TransformWorldToView(o.wPos).z;
    #else
        o.fogCoord = ComputeFogFactor(o.pos.z);
    #endif
    
    // 环境光
    o.vertexSH = \
            SampleSH(half3(1,0,0)) + \
            SampleSH(half3(-1,0,0)) + \
            SampleSH(half3(0,1,0)) + \
            SampleSH(half3(0,-1,0)) + \
            SampleSH(half3(0,0,1)) + \
            SampleSH(half3(0,0,-1));
    o.vertexSH /= 6.0;

    return o;
}

half4 SRToonOutlineFragment (v2f i) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(i);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

    //  LOD渐隐切换
    #ifdef LOD_FADE_CROSSFADE
        LODFadeCrossFade(i.pos);
    #endif

    i.fPos.xyz /= i.fPos.w;
    i.fPos.xy = i.fPos.xy * 0.5 + 0.5;
    #if UNITY_UV_STARTS_AT_TOP
        i.fPos.y = 1 - i.fPos.y;
    #endif
    float2 sUV = i.fPos.xy;

    
    // 最终颜色
    half4 finalCol = half4(0.01, 0.01, 0.01, 1.0);

    // 应用雾
    #if defined(_FOG_FRAGMENT)
        #if (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
            float viewZ = -i.fogCoord;
            float nearToFarZ = max(viewZ - _ProjectionParams.y, 0);
            half fogFactor = ComputeFogFactorZ0ToFar(nearToFarZ);
        #else
            half fogFactor = 0;
        #endif
    #else
        half fogFactor = i.fogCoord;
    #endif
    finalCol.rgb = MixFog(finalCol.rgb, fogFactor);

    #ifdef _VERTEXCOL_DEBUG_R
        finalCol = half4(i.vertexCol.rrr, 1.0);
    #endif
    #ifdef _VERTEXCOL_DEBUG_G
        finalCol = half4(i.vertexCol.ggg, 1.0);
    #endif
    #ifdef _VERTEXCOL_DEBUG_B
        finalCol = half4(i.vertexCol.bbb, 1.0);
    #endif
    #ifdef _VERTEXCOL_DEBUG_A
        finalCol = half4(i.vertexCol.aaa, 1.0);
    #endif
    #ifdef _VERTEXCOL_DEBUG_RGB
        finalCol = half4(i.vertexCol.rgb, 1.0);
    #endif


    return finalCol;
}

#endif