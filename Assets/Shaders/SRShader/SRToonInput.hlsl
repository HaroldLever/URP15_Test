#ifndef SR_TOON_INPUT_INCLUDED
#define SR_TOON_INPUT_INCLUDED

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
// TEXTURE2D(_NormalMap);
// SAMPLER(sampler_NormalMap);
TEXTURE2D(_LightMap);
SAMPLER(sampler_LightMap);
#ifdef _RAMPMAP_MODE_WARM
TEXTURE2D(_WarmRampMap);
SAMPLER(sampler_WarmRampMap);
#endif
#ifdef _RAMPMAP_MODE_COOL
TEXTURE2D(_CoolRampMap);
SAMPLER(sampler_CoolRampMap);
#endif

CBUFFER_START(UnityPerMaterial)
// #ifdef _IS_FACE
float4x4 _FaceWorldToLocal;
// #endif
// #ifdef _BETTER_MAINLIGHT_SHADOW
float _ML_MaxStep;
float _ML_StepLength;
float _ML_SampleOffset;
// #endif
float4 _AmbientModulate;
float4 _OutlineParam;
float4 _BaseColor;
float4 _BaseMap_ST;
// float4 _NormalMap_ST;
float4 _LightMap_ST;
// #ifdef _RAMPMAP_MODE_WARM
float4 _WarmRampMap_ST;
// #endif
// #ifdef _RAMPMAP_MODE_COOL
float4 _CoolRampMap_ST;
// #endif
float4 _RampRemap;
CBUFFER_END

#endif