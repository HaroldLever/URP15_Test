sampler2D _BaseMap;
sampler2D _NormalMap;
sampler2D _MaskMap;
sampler2D _PropertyMap;
sampler2D _EnvMap1;
sampler2D _EnvMap2;
sampler2D _EnvMap3;
sampler2D _RampMap;

cbuffer UnityPerMaterial
{
    float4 _BaseMap_ST;
    float4 _NormalMap_ST;
    float4 _MaskMap_ST;
    float4 _PropertyMap_ST;
    float4 _EnvMap1_ST;
    float4 _EnvMap2_ST;
    float4 _EnvMap3_ST;
    float4 _RampMap_ST;
    float _StepA;
    float _StepB;
    float4 _RimParam;
    // float _ML_MaxStep;
    // float _ML_StepLength;
    float _ML_SampleOffset;
    // float _AL_MaxStep;
    float _AL_PosOffset;
    float4 _OutlineParam;

    float4x4 _FaceWorldToLocal;
}

half3 CalculateToonDiffuse(half3 wNor, Light light, half channel=0.0, half shadowMask=1.0, half faceMaskFlip=1.0)
{
    half nDotL = saturate(dot(light.direction, wNor));
    //half stepNDotL = smoothstep(_StepA, _StepB, nDotL);

    #ifdef _IS_FACE
        half3 faceLightDir = mul(_FaceWorldToLocal, half4(light.direction, 0.0)).xyz;
        half faceStepA = dot(normalize(faceLightDir.yz),half2(1.0, 0.0))*0.5+0.5;
        half faceLM = faceLightDir.z > 0 ? shadowMask : faceMaskFlip;
        nDotL = smoothstep(1-faceStepA, 1-faceStepA+(1-faceStepA),faceLM);
    #else
        nDotL *= shadowMask;
    #endif

    #ifdef _USE_RAMPMAP
        #ifdef _RAMPMAP_SHADOW
            nDotL *= light.shadowAttenuation;
        #endif
        half3 diffuse = tex2D(_RampMap,half2(nDotL, channel)).rgb;
        #ifdef _MUL_SEMI
            half stepNDotL = smoothstep(_StepA, _StepB, nDotL);
            diffuse *= stepNDotL;
        #endif
        #ifdef _MUL_SHADOW
            diffuse *= light.shadowAttenuation;
        #endif
    #else
        half stepNDotL = smoothstep(_StepA, _StepB, nDotL);
        half3 diffuse = stepNDotL * light.shadowAttenuation;
    #endif

    
    #ifdef _RAMPMAP_DEBUG
        return diffuse;
    #endif
    
    diffuse *= light.color * light.distanceAttenuation;;
    
    return diffuse;
}

