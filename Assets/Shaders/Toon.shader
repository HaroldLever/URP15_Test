Shader "MyShader/Toon"
{
    Properties
    {
        [MainTexture] _BaseMap ("BaseMap", 2D) = "white" {}
        [KeywordEnum(None,RGB,A,RGBA)] _BaseMap_Debug ("BaseMap_Debug", float) = 0
        _NormalMap ("NormalMap", 2D) = "bump" {}
        [KeywordEnum(None,R,G,B,A,RGB)] _NormalMap_Debug ("NormalMap_Debug", float) = 0
        _MaskMap ("MaskMap", 2D) = "black" {}
        [KeywordEnum(None,R,G,B,A)] _MaskMap_Debug ("MaskMap_Debug", float) = 0    
        _PropertyMap ("PropertyMap", 2D) = "black" {}
        [KeywordEnum(None,RGB,A)] _PropertyMap_Debug ("PropertyMap_Debug", float) = 0
        _EnvMap1 ("EnvMap1", 2D) = "black" {}
        [Toggle(_ENVMAP1_DEBUG)] _EnvMap1_Debug ("EnvMap1_Debug", float) = 0
        _EnvMap2 ("EnvMap2", 2D) = "black" {}
        [Toggle(_ENVMAP2_DEBUG)] _EnvMap2_Debug ("EnvMap2_Debug", float) = 0
        _EnvMap3 ("EnvMap3", 2D) = "black" {}
        [Toggle(_ENVMAP3_DEBUG)] _EnvMap3_Debug ("EnvMap3_Debug", float) = 0
        _RampMap ("RampMap", 2D) = "white" {}
        [Toggle(_RAMPMAP_DEBUG)] _RampMap_Debug ("RampMap_Debug", float) = 0
        [Toggle(_USE_RAMPMAP)] _UseRampMap ("UseRampMap", float) = 1
        [Toggle(_RAMPMAP_SHADOW)] _RampMapShadow ("RampMapShadow", float) = 1
        [Toggle(_MUL_SEMI)] _MulSemi ("MulSemi", float) = 0
        [Toggle(_MUL_SHADOW)] _MulShadow ("MulShadow", float) = 0
        _StepA ("StepA", Range(-1.0, 1.0)) = 0.0
        _StepB ("StepB", Range(-1.0, 1.0)) = 0.2
        [Toggle(_IS_FACE)] _IsFace ("IsFace", float) = 0

        [Header(Ambient)][Space(10)]
        [Toggle(_ENABLE_RIM)] _EnableRim ("EnableRim",float) = 1
        _RimParam ("RimParam", Vector) = (5.0, 0.001, 1.0, 10)
        [Toggle(_ENABLE_LIGHT_PROBE)] _EnableLightProbe ("EnableLightProbe",float) = 1

        [Header(Experimental)][Space(10)]
        [Toggle(_USE_SHADOW_DELAY)]_USE_SHADOW_DELAY ("UseShadowDelay", float) = 0.0
        [Space(10)]
        [Toggle(_BETTER_MAINLIGHT_SHADOW)]_BetterMainLightShadow ("BetterMainLightShadow", float) = 0.0
        _ML_MaxStep ("ML_MaxStep", float) = 1
        _ML_StepLength ("ML_StepLength", float) = 0.0001
        _ML_SampleOffset ("ML_SampleOffset", Range(0.0,0.005)) = 0.0015
        [Toggle(_BETTER_ADDLIGHT_SHADOW)]_BetterAddLightShadow ("BetterAddLightShadow", float) = 0.0
        _AL_MaxStep ("AL_MaxStep", float) = 1
        _AL_PosOffset ("AL_PosOffset", float) = 0.001

        [Header(Outline)][Space(10)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("OutlineCullMode", float) = 1
        [KeywordEnum(None,R,G,B,A,RGB)] _VertexCol_Debug ("VertexCol_Debug", float) = 0
        [Toggle(_USE_VERTEXCOL)] _Use_VertexCol ("Use_VertexCol",float) = 0
        _OutlineParam ("OutlineParam", Vector) = (5.0, 0.00001,0,0)
    }
    SubShader
    {
        Tags 
        {
            "Queue" = "Geometry"
            "RenderType" = "Opaque"
            "IgnoreProjector" = "True"
            "RenderPipeline" = "UniversalPipeline" 
        }

        LOD 100

        Pass    // ToonLit
        {
            Name "ToonLit"

            Tags
            {
                "LightMode" = "UniversalForward"
            }

            ZWrite On
            ZTest LEqual
            Cull Back

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // -------------------------------------
            // Material keywords
            #pragma shader_feature_local _BASEMAP_DEBUG_NONE _BASEMAP_DEBUG_RGB _BASEMAP_DEBUG_A _BASEMAP_DEBUG_RGBA
            #pragma shader_feature_local _NORMALMAP_DEBUG_NONE _NORMALMAP_DEBUG_R _NORMALMAP_DEBUG_G _NORMALMAP_DEBUG_B _NORMALMAP_DEBUG_A _NORMALMAP_DEBUG_RGB
            #pragma shader_feature_local _MASKMAP_DEBUG_NONE _MASKMAP_DEBUG_R _MASKMAP_DEBUG_G _MASKMAP_DEBUG_B _MASKMAP_DEBUG_A
            #pragma shader_feature_local _PROPERTYMAP_DEBUG_NONE _PROPERTYMAP_DEBUG_RGB _PROPERTYMAP_DEBUG_A
            #pragma shader_feature_local _ _ENVMAP1_DEBUG
            #pragma shader_feature_local _ _ENVMAP2_DEBUG
            #pragma shader_feature_local _ _ENVMAP3_DEBUG
            #pragma shader_feature_local _ _RAMPMAP_DEBUG
            #pragma shader_feature_local _ _RAMPMAP_SHADOW
            #pragma shader_feature_local _ _MUL_SEMI
            #pragma shader_feature_local _ _MUL_SHADOW
            // #pragma multi_compile_local _ _VERTEXCOL_DEBUG
            #pragma multi_compile_local_fragment _ _USE_RAMPMAP
            #pragma multi_compile_local _ _IS_FACE
            #pragma multi_compile_local_fragment _ _ENABLE_RIM
            #pragma multi_compile_local_fragment _ _ENABLE_LIGHT_PROBE
            #pragma multi_compile_local_fragment _ _BETTER_MAINLIGHT_SHADOW
            #pragma multi_compile_local_fragment _ _BETTER_ADDLIGHT_SHADOW
            #pragma multi_compile_local _ _USE_SHADOW_DELAY

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
            #pragma multi_compile_fragment _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _FORWARD_PLUS
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
            #pragma multi_compile _ _SHADOW_DELAY

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            //--------------------------------------
            // Include
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #if defined(LOD_FADE_CROSSFADE)
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif
            #include "Assets/Shaders/ToonLib.hlsl"

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

            v2f vert (appdata v)
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

                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // GPU实例化
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                // LOD渐隐切换
                #ifdef LOD_FADE_CROSSFADE
                    LODFadeCrossFade(i.pos);
                #endif
                
                // 向量
                float3 wPos = i.wPos;
                float4 cPos = TransformWorldToHClip(wPos);
                half3 wViewDir = normalize(_WorldSpaceCameraPos - wPos);
                half3 wNor = TransformObjectToWorldNormal(i.normal);
                half3 wTan = TransformObjectToWorldDir(i.tangent.xyz);
                half3 wBiTan = TransformObjectToWorldDir(i.biTangent);

                float2 sUV = GetNormalizedScreenSpaceUV(i.pos);

                // 采样纹理
                half4 base = tex2D(_BaseMap, TRANSFORM_TEX(i.uv, _BaseMap));
                half4 nor = tex2D(_NormalMap, TRANSFORM_TEX(i.uv, _NormalMap));
                half4 mask = tex2D(_MaskMap, TRANSFORM_TEX(i.uv, _MaskMap));
                half4 prop = tex2D(_PropertyMap, TRANSFORM_TEX(i.uv, _PropertyMap));
                //half4 ramp = tex2D(_RampMap, TRANSFORM_TEX(i.uv, _RampMap));
                half faceMaskFlip = tex2D(_MaskMap, TRANSFORM_TEX(float2(1-i.uv.x, i.uv.y), _MaskMap)).a;

                // 调试
                #include "Assets/Shaders/ToonDebug.hlsl"
                //return 1.0;

                // 处理法线贴图
                half3 tNor = UnpackNormal(nor).rgb;
                tNor.z = 1-sqrt(dot(tNor.xy, tNor.xy));
                real3x3 tbn = real3x3(wTan, wBiTan,wNor);
                wNor = TransformTangentToWorld(tNor.xyz, tbn, true);

                // 漫反射_主光
                #if _MAIN_LIGHT_SHADOWS_SCREEN
                    float4 shadowCoord = float4(GetNormalizedScreenSpaceUV(i.pos),1,1);
                #else
                    float4 shadowCoord = TransformWorldToShadowCoord(wPos);
                #endif
                Light mainLight = GetMainLight(shadowCoord);
                
                // #define MAX_STEP 1
                // #define STEP_LENGTH 0.0001
                // #define SAMPLE_OFFSET 0.0015
                #define _ML_MaxStep 1
                #define _ML_StepLength 0.0001
                //#define _ML_SampleOffset 0.0015
                #define _AL_MaxStep 1
                // #define _AL_PosOffset 0.005
                
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

                half3 diffuse = CalculateToonDiffuse(wNor, mainLight, prop.a, mask.a, faceMaskFlip);
                // return half4(diffuse, 1.0);

                // 漫反射_额外光
                int addLightCount = GetAdditionalLightsCount();
                #ifdef _BETTER_ADDLIGHT_SHADOW
                    half addLightShadow = 0.0;
                    half addLightShadow1 = 0.0;
                    half addLightShadow2 = 0.0;
                    half addLightShadow3 = 0.0;
                    half addLightShadow4 = 0.0;
                    half addLightShadow5 = 0.0;
                    half addLightShadow6 = 0.0;
                    half addLightShadow7 = 0.0;
                    half addLightShadow8 = 0.0;
                #endif  // #ifdef BETTER_ADDLIGHT_SHADOW
                for (int index = 0; index < addLightCount; index++)
                {
                    Light addLight = GetAdditionalLight(index, wPos, half4(1,1,1,1));
                    #ifdef _BETTER_ADDLIGHT_SHADOW
                        for (half step = 0; step < _AL_MaxStep; step++)
                        {
                            float wPosOffset = _AL_PosOffset * (step+1);
                            addLightShadow += GetAdditionalLight(index, wPos, half4(1,1,1,1)).shadowAttenuation;
                            addLightShadow1 += GetAdditionalLight(index,wPos+float3(wPosOffset,wPosOffset,wPosOffset),half4(1,1,1,1)).shadowAttenuation;
                            addLightShadow2 += GetAdditionalLight(index,wPos+float3(wPosOffset,wPosOffset,-wPosOffset),half4(1,1,1,1)).shadowAttenuation;
                            addLightShadow3 += GetAdditionalLight(index,wPos+float3(wPosOffset,-wPosOffset,wPosOffset),half4(1,1,1,1)).shadowAttenuation;
                            addLightShadow4 += GetAdditionalLight(index,wPos+float3(wPosOffset,-wPosOffset,-wPosOffset),half4(1,1,1,1)).shadowAttenuation;
                            addLightShadow5 += GetAdditionalLight(index,wPos+float3(-wPosOffset,wPosOffset,wPosOffset),half4(1,1,1,1)).shadowAttenuation;
                            addLightShadow6 += GetAdditionalLight(index,wPos+float3(-wPosOffset,wPosOffset,-wPosOffset),half4(1,1,1,1)).shadowAttenuation;
                            addLightShadow7 += GetAdditionalLight(index,wPos+float3(-wPosOffset,-wPosOffset,wPosOffset),half4(1,1,1,1)).shadowAttenuation;
                            addLightShadow8 += GetAdditionalLight(index,wPos+float3(-wPosOffset,-wPosOffset,-wPosOffset),half4(1,1,1,1)).shadowAttenuation;
                        }
                        addLightShadow = (
                            addLightShadow + \
                            addLightShadow1 + \
                            addLightShadow2 + \
                            addLightShadow3 + \
                            addLightShadow4 + \
                            addLightShadow5 + \
                            addLightShadow6 + \
                            addLightShadow7 + \
                            addLightShadow8) / 9 / _AL_MaxStep;
                        addLight.shadowAttenuation = addLightShadow;
                    #endif  // #ifdef BETTER_ADDLIGHT_SHADOW
                    diffuse += CalculateToonDiffuse(wNor, addLight, prop.a, mask.a, faceMaskFlip);
                }
                
                #ifdef _RAMPMAP_DEBUG
                    return half4(diffuse, 1.0);
                #endif

                // 反射球
                half3 vNor = mul(unity_MatrixV, float4(wNor, 0.0)).xyz;
                half3 vViewDir = mul(unity_MatrixV, float4(wViewDir, 0.0)).xyz;
                half2 sNor = vNor.xy * vViewDir.z - vViewDir.xy * vNor.z;

                half4 env1 = tex2D(_EnvMap1, sNor.xy*0.5+0.5);
                half4 env2 = tex2D(_EnvMap2, sNor.xy*0.5+0.5);
                half4 env3 = tex2D(_EnvMap3, sNor.xy*0.5+0.5);
                #ifdef _ENVMAP1_DEBUG
                    return env1;
                #endif
                #ifdef _ENVMAP2_DEBUG
                    return env2;
                #endif
                #ifdef _ENVMAP3_DEBUG
                    return env3;
                #endif
                env1 *= mask.r;
                env2 *= mask.g;
                env3 *= mask.b;

                // 边缘光
                #ifdef _ENABLE_RIM
                    _RimParam.y /= _ProjectionParams.z - _ProjectionParams.y;
                    float depth = SampleSceneDepth(sUV);
                    depth = Linear01Depth(depth, _ZBufferParams);
                    half rim = \
                        Linear01Depth(
                            SampleSceneDepth(
                                sUV + float2(
                                    _RimParam.x / _ScreenParams.x, 0)), _ZBufferParams)\
                        - depth > _RimParam.y ? 1.0 : 0.0\
                        + Linear01Depth(
                            SampleSceneDepth(
                                sUV + float2(
                                    -_RimParam.x / _ScreenParams.x, 0)), _ZBufferParams)\
                        - depth > _RimParam.y ? 1.0 : 0.0\
                        + Linear01Depth(
                            SampleSceneDepth(
                                sUV + float2(
                                    0, _RimParam.x / _ScreenParams.y)), _ZBufferParams)\
                        - depth > _RimParam.y ? 1.0 : 0.0\
                        + Linear01Depth(
                            SampleSceneDepth(
                                sUV + float2(
                                    0, -_RimParam.x / _ScreenParams.y)), _ZBufferParams)\
                        - depth > _RimParam.y ? 1.0 : 0.0;
                    _RimParam.zw -= _ProjectionParams.y;
                    _RimParam.zw /= _ProjectionParams.z - _ProjectionParams.y;
                    rim *= (_RimParam.w - depth) / (_RimParam.w - _RimParam.z);
                    rim = saturate(rim);
                #else
                    half rim = 0.0;
                #endif

                // 环境光
                //half3 ambient = half3(0,0,0);
                half3 ambient = i.vertexSH;
                //half3 ambient = SampleSH(wNor);
                ambient += ambient * (rim + env1.rgb + env2.rgb +env3.rgb);

                // 最终颜色
                half4 finalCol = half4(.5, .5, .5, 1);
                finalCol.rgb = (diffuse + ambient) * base.rgb;

                // 环境光遮蔽
                #if defined(_SCREEN_SPACE_OCCLUSION)
                    AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion(sUV);
                    half aoLightFactor = saturate(dot(mainLight.direction, wNor));
                    aoLightFactor *= mainLight.shadowAttenuation;
                    finalCol.rgb *= lerp(aoFactor.indirectAmbientOcclusion
                                        , aoFactor.directAmbientOcclusion
                                        , aoLightFactor);
                #endif

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

                return finalCol;
            }
            ENDHLSL
        }

        // Pass    // Outline
        // {
        //     Name "Outline"
        //     Tags
        //     {
        //         "LightMode" = "SRPDefaultUnlit"
        //     }

        //     ZWrite On
        //     ZTest LEqual
        //     Cull [_Cull]

        //     HLSLPROGRAM
            
        //     // -------------------------------------
        //     // Shader Stages
        //     #pragma vertex OutlinePassVertex
        //     #pragma fragment OutlinePassFragment

        //     // -------------------------------------
        //     // Material Keywords
        //     #pragma multi_compile_local _PROPERTYMAP_DEBUG_NONE _PROPERTYMAP_DEBUG_RGB _PROPERTYMAP_DEBUG_A
        //     #pragma multi_compile_local _VERTEXCOL_DEBUG_NONE _VERTEXCOL_DEBUG_R _VERTEXCOL_DEBUG_G _VERTEXCOL_DEBUG_B _VERTEXCOL_DEBUG_A _VERTEXCOL_DEBUG_RGB
        //     #pragma multi_compile_local _ _USE_VERTEXCOL

        //     // -------------------------------------
        //     // Unity defined keywords
        //     #pragma multi_compile_fog
        //     #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
        //     #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

        //     //--------------------------------------
        //     // GPU Instancing
        //     #pragma multi_compile_instancing
        //     #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

        //     // -------------------------------------
        //     // Includes
        //     #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        //     #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        //     #if defined(LOD_FADE_CROSSFADE)
        //         #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        //     #endif
        //     #include "Assets/Shaders/ToonLib.hlsl"

        //     struct appdata
        //     {
        //         float4 vertex : POSITION;
        //         half3 normal : NORMAL;
        //         half4 tangent : TANGENT;
        //         half4 vertexCol : COLOR;
        //         float2 uv : TEXCOORD0;

        //         UNITY_VERTEX_INPUT_INSTANCE_ID
        //     };

        //     struct v2f
        //     {
        //         float4 pos : SV_POSITION;
        //         half4 vertexCol : COLOR;
        //         float2 uv : TEXCOORD0;
        //         float fogCoord : TEXCOORD1; 
        //         float3 wPos : TEXCOORD2;
        //         float3 vertexSH : TEXCOORD3;

        //         UNITY_VERTEX_INPUT_INSTANCE_ID
        //         UNITY_VERTEX_OUTPUT_STEREO
        //     };

        //     v2f OutlinePassVertex (appdata v)
        //     {
        //         v2f o;

        //         // GPU实例化
        //         UNITY_SETUP_INSTANCE_ID(v);
        //         UNITY_TRANSFER_INSTANCE_ID(v, o);
        //         UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

        //         o.wPos = TransformObjectToWorld(v.vertex.xyz);
        //         o.pos = TransformObjectToHClip(v.vertex.xyz);
        //         o.uv = v.uv;
        //         o.vertexCol = v.vertexCol;

        //         half3 normal = TransformObjectToWorldNormal(v.normal);
        //         half3 tangent = TransformObjectToWorldDir(v.tangent.xyz);
        //         half3 biTangent = cross(normal, tangent) * v.tangent.w * GetOddNegativeScale();


        //         #ifdef _USE_VERTEXCOL
        //             half3 tNor = v.vertexCol.rgb;
        //             tNor = tNor.xyz *2-1;
        //             tNor = half3(tNor.x, -tNor.y, tNor.z);

        //             real3x3 tbn = real3x3(tangent, biTangent,normal);
        //             normal = TransformTangentToWorld(tNor.xyz, tbn, true);
        //             normal = TransformWorldToObjectDir(normal);
        //             normal *= v.vertexCol.a;
        //         #endif

        //         float3 norCS = \
        //         mul((float3x3)UNITY_MATRIX_MVP,normal);
        //         float2 outlineOffset = normalize(norCS.xy)/_ScreenParams.xy \
        //                 * o.pos.w * _OutlineParam.x;
        //         #ifdef _VERTEXCOL_DEBUG
        //             o.pos = TransformObjectToHClip(v.vertex.xyz + normal * _OutlineParam.y * 0.0001);
        //         #else
        //             o.pos.xy += length(outlineOffset) < length(norCS.xy) * _OutlineParam.y ? \
        //                     outlineOffset : norCS.xy * _OutlineParam.y;
        //         #endif
                
        //         #if defined(_FOG_FRAGMENT)
        //             o.fogCoord = TransformWorldToView(o.wPos).z;
        //         #else
        //             o.fogCoord = ComputeFogFactor(o.pos.z);
        //         #endif
                
        //         // 环境光
        //         o.vertexSH = \
        //                 SampleSH(half3(1,0,0)) + \
        //                 SampleSH(half3(-1,0,0)) + \
        //                 SampleSH(half3(0,1,0)) + \
        //                 SampleSH(half3(0,-1,0)) + \
        //                 SampleSH(half3(0,0,1)) + \
        //                 SampleSH(half3(0,0,-1));
        //         o.vertexSH /= 6.0;

        //         return o;
        //     }

        //     half4 OutlinePassFragment (v2f i) : SV_TARGET
        //     {
        //         UNITY_SETUP_INSTANCE_ID(i);
        //         UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

        //         //
        //         #ifdef LOD_FADE_CROSSFADE
        //             LODFadeCrossFade(i.pos);
        //         #endif

        //         // 采样纹理
        //         half4 prop = tex2D(_PropertyMap, TRANSFORM_TEX(i.uv, _PropertyMap));
                
        //         // 最终颜色
        //         half4 finalCol = half4(0.01, 0.01, 0.01, 1.0);
        //         finalCol.rgb = prop.rgb * i.vertexSH;

        //         #ifdef _VERTEXCOL_DEBUG
        //             finalCol.rgb = i.vertexCol.rgb;
        //         #endif

        //         // 应用雾
        //         #if defined(_FOG_FRAGMENT)
        //             #if (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
        //                 float viewZ = -i.fogCoord;
        //                 float nearToFarZ = max(viewZ - _ProjectionParams.y, 0);
        //                 half fogFactor = ComputeFogFactorZ0ToFar(nearToFarZ);
        //             #else
        //                 half fogFactor = 0;
        //             #endif
        //         #else
        //             half fogFactor = i.fogCoord;
        //         #endif
        //         finalCol.rgb = MixFog(finalCol.rgb, fogFactor);

        //         #ifdef _PROPERTYMAP_DEBUG_RGB
        //             finalCol = half4(prop.rgb, 1.0);
        //         #endif
        //         #ifdef _PROPERTYMAP_DEBUG_A
        //             finalCol = half4(prop.aaa, 1.0);
        //         #endif

        //         #ifdef _VERTEXCOL_DEBUG_R
        //             finalCol = half4(i.vertexCol.rrr, 1.0);
        //         #endif
        //         #ifdef _VERTEXCOL_DEBUG_G
        //             finalCol = half4(i.vertexCol.ggg, 1.0);
        //         #endif
        //         #ifdef _VERTEXCOL_DEBUG_B
        //             finalCol = half4(i.vertexCol.bbb, 1.0);
        //         #endif
        //         #ifdef _VERTEXCOL_DEBUG_A
        //             finalCol = half4(i.vertexCol.aaa, 1.0);
        //         #endif
        //         #ifdef _VERTEXCOL_DEBUG_RGB
        //             finalCol = half4(i.vertexCol.rgb, 1.0);
        //         #endif

        //         return finalCol;
        //     }
        //     ENDHLSL
        // }

        Pass    // ShadowCaster
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            ZWrite On
            ZTest LEqual
            ColorMask 0

            HLSLPROGRAM

            // -------------------------------------
            // Shader Stages
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #if defined(LOD_FADE_CROSSFADE)
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif


            float3 _LightDirection;
            float3 _LightPosition;

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS   : SV_POSITION;
            };



            Varyings ShadowPassVertex(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

                #if _CASTING_PUNCTUAL_LIGHT_SHADOW
                    float3 lightDirectionWS = normalize(_LightPosition - positionWS);
                #else
                    float3 lightDirectionWS = _LightDirection;
                #endif

                    output.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

                #if UNITY_REVERSED_Z
                    output.positionCS.z = min(output.positionCS.z, UNITY_NEAR_CLIP_VALUE);
                #else
                    output.positionCS.z = max(output.positionCS.z, UNITY_NEAR_CLIP_VALUE);
                #endif
                return output;
            }

            half4 ShadowPassFragment(Varyings input) : SV_TARGET
            {
                #ifdef LOD_FADE_CROSSFADE
                    LODFadeCrossFade(input.positionCS);
                #endif

                return 0;
            }

            ENDHLSL
        }

        Pass    // DepthOnly
        {
            Name "DepthOnly"

            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            ZTest LEqual
            Cull Back
            ColorMask R

            HLSLPROGRAM

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            //#include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #if defined(LOD_FADE_CROSSFADE)
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

            sampler2D _BaseMap;

            cbuffer UnityPerMaterial
            {
                float4 _BaseMap_ST;
                float _StepA;
                float _StepB;
            }


            struct Attributes
            {
                float4 position     : POSITION;
                float2 texcoord     : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv           : TEXCOORD0;
                float4 positionCS   : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings DepthOnlyVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.positionCS = TransformObjectToHClip(input.position.xyz);
                return output;
            }

            half DepthOnlyFragment(Varyings input) : SV_TARGET
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                #ifdef LOD_FADE_CROSSFADE
                    LODFadeCrossFade(input.positionCS);
                #endif

                return input.positionCS.z;
            }
            ENDHLSL
        }

        Pass    // DepthNormals
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            Cull Back

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords


            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            // -------------------------------------
            // Universal Pipeline keywords
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #if defined(LOD_FADE_CROSSFADE)
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS     : POSITION;
                float4 tangentOS      : TANGENT;
                float3 normal       : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS   : SV_POSITION;
                float3 normalWS                 : TEXCOORD2;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings DepthNormalsVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangentOS);
                output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);

                return output;
            }

            void DepthNormalsFragment(
                Varyings input
                , out half4 outNormalWS : SV_Target0
                #ifdef _WRITE_RENDERING_LAYERS
                    , out float4 outRenderingLayers : SV_Target1
                #endif
            )
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                #ifdef LOD_FADE_CROSSFADE
                    LODFadeCrossFade(input.positionCS);
                #endif

                #if defined(_GBUFFER_NORMALS_OCT)
                float3 normalWS = normalize(input.normalWS);
                float2 octNormalWS = PackNormalOctQuadEncode(normalWS);           // values between [-1, +1], must use fp32 on some platforms.
                float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);   // values between [ 0,  1]
                half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);      // values between [ 0,  1]
                outNormalWS = half4(packedNormalWS, 0.0);
                #else
                float3 normalWS = NormalizeNormalPerPixel(input.normalWS);
                outNormalWS = half4(normalWS, 0.0);
                #endif

                #ifdef _WRITE_RENDERING_LAYERS
                    uint renderingLayers = GetMeshRenderingLayer();
                    outRenderingLayers = float4(EncodeMeshRenderingLayer(renderingLayers), 0, 0, 0);
                #endif
            }
            ENDHLSL
        }
    }
}
