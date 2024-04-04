#ifndef SR_TOON_LIT_PASS
#define SR_TOON_LIT_PASS

struct appdata
{
    float4 vertex : POSITION;
    half3 normal : NORMAL;
    half4 tangent : TANGENT;
    float2 uv : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float4 pos : SV_POSITION;
    half3 normal : NORMAL;
    half4 tangent : TANGENT;
    half3 biTangent : TEXCOORD4;
    float2 uv : TEXCOORD0;
    float fogCoord : TEXCOORD1; // 雾坐标
    float3 wPos : TEXCOORD2;     // 物体坐标
    half3 vertexSH : TEXCOORD3;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

v2f SRToonLitVertex (appdata v)
{
    v2f o;

    // GPU实例化
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    o.wPos = TransformObjectToWorld(v.vertex.xyz);
    o.pos = TransformObjectToHClip(v.vertex.xyz);
    o.uv = v.uv;
    o.normal = v.normal;
    o.tangent = v.tangent;
    o.biTangent = cross(v.normal, v.tangent.xyz) * v.tangent.w * GetOddNegativeScale();
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
    //o.vertexSH = SampleSH(TransformObjectToWorldNormal(v.normal));
    o.vertexSH *= _AmbientModulate.rgb;

    return o;
}

half3 CalculateToonDiffuse(half3 wNor, Light light, half channel=0.0, half shadowMask=1.0, half faceMaskFlip=1.0, half eyeMask = 0.0)
{
    #define _StepA -0.3
    #define _StepB -0.1
    half nDotL = dot(light.direction, wNor);

    #ifdef _IS_FACE
        half3 faceLightDir = mul(_FaceWorldToLocal, half4(light.direction, 0.0)).xyz;
        half faceStepA = dot(normalize(faceLightDir.xz),half2(0.0, -1.0))*0.5+0.5;
        half faceLM = faceLightDir.x > 0 ? shadowMask : faceMaskFlip;
        nDotL = smoothstep((1-faceStepA)*(1-faceStepA), 1-faceStepA,faceLM);
        nDotL = nDotL-0.5;
        channel = 0.0;
    #else
        nDotL += (shadowMask-1);
    #endif

    float2 rampUV = float2(nDotL, channel) * float2(_RampRemap.y-_RampRemap.x, _RampRemap.w-_RampRemap.z) + float2(_RampRemap.x, _RampRemap.z);
    #ifdef _RAMPMAP_MODE_WARM
    half3 diffuse = SAMPLE_TEXTURE2D(_WarmRampMap, sampler_WarmRampMap, rampUV).rgb;
    #endif
    #ifdef _RAMPMAP_MODE_COOL
    half3 diffuse = SAMPLE_TEXTURE2D(_CoolRampMap, sampler_CoolRampMap, rampUV).rgb;
    #endif

    #ifdef _RECEIVE_SHADOW
        diffuse *= light.shadowAttenuation;
    #endif
    
    #ifdef _IS_FACE
    half stepNDotL = smoothstep(_StepA, _StepB, nDotL);
    half stepFaceNDotL = smoothstep(-1.0, 0.5, faceStepA*2.0-1.0);
    diffuse *= (eyeMask + stepNDotL*(1-eyeMask)) * ((1-eyeMask) + stepFaceNDotL * eyeMask);
    #else
    half stepNDotL = smoothstep(_StepA, _StepB, nDotL);
    diffuse *= stepNDotL;
    #endif

    
    #ifdef _RAMPMAP_DEBUG
        return diffuse;
    #endif
    
    diffuse *= light.color * light.distanceAttenuation;
    
    return diffuse;
}

half4 SRToonLitFragment (v2f i, half facing:VFACE) : SV_Target
{
    // GPU实例化
    UNITY_SETUP_INSTANCE_ID(i);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

    // LOD渐隐切换
    #ifdef LOD_FADE_CROSSFADE
        LODFadeCrossFade(i.pos);
    #endif

    #ifdef _ONLY_COLOR
    return _BaseColor;
    #endif
    
    // 向量
    float3 wPos = i.wPos;
    float4 cPos = TransformWorldToHClip(wPos);
    half3 wViewDir = normalize(_WorldSpaceCameraPos - wPos);
    half3 wNor = TransformObjectToWorldNormal(i.normal);
    half3 wTan = TransformObjectToWorldDir(i.tangent.xyz);
    half3 wBiTan = TransformObjectToWorldDir(i.biTangent);

    float2 sUV = GetNormalizedScreenSpaceUV(i.pos);

    // 采样贴图
    half4 base = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, TRANSFORM_TEX(i.uv, _BaseMap));
    // half4 nor = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, TRANSFORM_TEX(i.uv, _NormalMap));
    half4 lightMap = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, TRANSFORM_TEX(i.uv, _LightMap));
    #ifdef _IS_FACE
    half faceMaskFlip = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, TRANSFORM_TEX(i.uv, _LightMap) * float2(-1, 1) + float2(1, 0)).a;
    #endif
    
    wNor *= facing;

    // 调试
    #include "Assets/Shaders/SRShader/SRToonDebug.hlsl"

    // 漫反射_主光
    #if _MAIN_LIGHT_SHADOWS_SCREEN
        float4 shadowCoord = float4(GetNormalizedScreenSpaceUV(i.pos),1,1);
    #else
        float4 shadowCoord = TransformWorldToShadowCoord(wPos);
    #endif
    Light mainLight = GetMainLight(shadowCoord);

    #if (defined(_BETTER_MAINLIGHT_SHADOW) && defined(_SHADOWS_SOFT))
        half mainLightShadow = 0.0;
        half mainLightShadow1 = 0.0;
        half mainLightShadow2 = 0.0;
        half mainLightShadow3 = 0.0;
        half mainLightShadow4 = 0.0;
        half mainLightShadow5 = 0.0;
        half mainLightShadow6 = 0.0;
        half mainLightShadow7 = 0.0;
        half mainLightShadow8 = 0.0;
        for (half step = 0; step < _ML_MaxStep; step++)
        {
            float3 wPosTemp = wPos + mainLight.direction * _ML_StepLength * step;
            #if _MAIN_LIGHT_SHADOWS_SCREEN
                float4 shadowCoordTemp = float4(GetNormalizedScreenSpaceUV(i.pos),1,1);
            #else
                float4 shadowCoordTemp = TransformWorldToShadowCoord(wPos);
            #endif
            mainLightShadow += MainLightRealtimeShadow(shadowCoordTemp);
            mainLightShadow1 += MainLightRealtimeShadow(shadowCoordTemp+float4(_ML_SampleOffset,0,0,0));
            mainLightShadow2 += MainLightRealtimeShadow(shadowCoordTemp+float4(-_ML_SampleOffset,0,0,0));
            mainLightShadow3 += MainLightRealtimeShadow(shadowCoordTemp+float4(0,_ML_SampleOffset,0,0));
            mainLightShadow4 += MainLightRealtimeShadow(shadowCoordTemp+float4(0,-_ML_SampleOffset,0,0));
            mainLightShadow5 += MainLightRealtimeShadow(shadowCoordTemp+float4(_ML_SampleOffset,_ML_SampleOffset,0,0));
            mainLightShadow6 += MainLightRealtimeShadow(shadowCoordTemp+float4(-_ML_SampleOffset,_ML_SampleOffset,0,0));
            mainLightShadow7 += MainLightRealtimeShadow(shadowCoordTemp+float4(-_ML_SampleOffset,-_ML_SampleOffset,0,0));
            mainLightShadow8 += MainLightRealtimeShadow(shadowCoordTemp+float4(_ML_SampleOffset,-_ML_SampleOffset,0,0));
        }
        mainLightShadow = (
            mainLightShadow + \
            mainLightShadow1 + \
            mainLightShadow2 + \
            mainLightShadow3 + \
            mainLightShadow4 + \
            mainLightShadow5 + \
            mainLightShadow6 + \
            mainLightShadow7 + \
            mainLightShadow8) / 9 / _ML_MaxStep;
        
        mainLight.shadowAttenuation = mainLightShadow;
    #endif  // #ifdef BETTER_MAINLIGHT_SHADOW

    half3 diffuse = CalculateToonDiffuse(wNor, mainLight, lightMap.a
    #ifdef _IS_FACE
    , lightMap.a
    , faceMaskFlip
    , lightMap.g
    #else
    , lightMap.r
    #endif
    );
    // return half4(diffuse, 1.0);

    half4 finalCol = half4(1.0, 1.0, 1.0, 1.0);
    finalCol.rgb = base.rgb * _BaseColor.rgb * i.vertexSH;
    finalCol.rgb += diffuse * base.rgb;
    finalCol.a = _BaseColor.a;

    return finalCol;
}



#endif