Shader "MyShader/ToonOutline"
{
    Properties
    {   
        _PropertyMap ("PropertyMap", 2D) = "black" {}
        [KeywordEnum(None,RGB,A)] _PropertyMap_Debug ("PropertyMap_Debug", float) = 0
        _MulCol ("MulCol", Color) = (0, 0, 0, 0)

        [Header(Outline)][Space(10)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("OutlineCullMode", float) = 1
        [KeywordEnum(None,R,G,B,A,RGB)] _VertexCol_Debug ("VertexCol_Debug", float) = 0
        _OutlineParam ("OutlineParam", Vector) = (5.0, 0.00001,0,0)
    }
    SubShader
    {
        Tags 
        {   
            "IgnoreProjector" = "True"
            "RenderPipeline" = "UniversalPipeline" 
        }

        LOD 100

        Pass    // Outline
        {
            Name "Outline"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            ZWrite On
            ZTest LEqual
            Cull [_Cull]

            HLSLPROGRAM
            
            // -------------------------------------
            // Shader Stages
            #pragma vertex OutlinePassVertex
            #pragma fragment OutlinePassFragment

            // -------------------------------------
            // Material Keywords
            #pragma multi_compile_local _PROPERTYMAP_DEBUG_NONE _PROPERTYMAP_DEBUG_RGB _PROPERTYMAP_DEBUG_A
            #pragma multi_compile_local _VERTEXCOL_DEBUG_NONE _VERTEXCOL_DEBUG_R _VERTEXCOL_DEBUG_G _VERTEXCOL_DEBUG_B _VERTEXCOL_DEBUG_A _VERTEXCOL_DEBUG_RGB

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"
            #if defined(LOD_FADE_CROSSFADE)
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
            #endif

            sampler2D _PropertyMap;
            cbuffer UnityPerMaterial
            {
                float4 _PropertyMap_ST;
                float4 _OutlineParam;
                float4 _MulCol;
            }

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

            v2f OutlinePassVertex (appdata v)
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

                half3 normal = TransformObjectToWorldNormal(v.normal);
                half3 tangent = TransformObjectToWorldDir(v.tangent.xyz);
                half3 biTangent = cross(normal, tangent) * v.tangent.w * GetOddNegativeScale();

                half3 tNor = v.vertexCol.rgb;
                tNor = tNor.xyz *2-1;
                tNor = half3(tNor.x, -tNor.y, tNor.z);

                real3x3 tbn = real3x3(tangent, biTangent,normal);
                normal = TransformTangentToWorld(tNor.xyz, tbn, true);
                normal = TransformWorldToObjectDir(normal);
                normal *= v.vertexCol.a;

                half3 norCS = \
                mul((float3x3)UNITY_MATRIX_MVP,normal);
                float2 outlineOffset = normalize(norCS.xy)/_ScreenParams.xy \
                        * o.pos.w * _OutlineParam.x;
                #if (defined(_VERTEXCOL_DEBUG_R)||defined(_VERTEXCOL_DEBUG_G)||defined(_VERTEXCOL_DEBUG_A)||defined(_VERTEXCOL_DEBUG_RGB))
                    o.pos = TransformObjectToHClip(v.vertex.xyz + normal * _OutlineParam.y);
                #else
                    o.pos.xy += length(outlineOffset) < length(norCS.xy) * _OutlineParam.y ? \
                            outlineOffset : norCS.xy * _OutlineParam.y;
                #endif

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

            half4 OutlinePassFragment (v2f i) : SV_TARGET
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

                // 采样纹理
                half4 prop = tex2D(_PropertyMap, TRANSFORM_TEX(i.uv, _PropertyMap));
                
                // 最终颜色
                half4 finalCol = half4(0.01, 0.01, 0.01, 1.0);
                finalCol.rgb = _MulCol.rgb;

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

                #ifdef _PROPERTYMAP_DEBUG_RGB
                    finalCol = half4(prop.rgb, 1.0);
                #endif
                #ifdef _PROPERTYMAP_DEBUG_A
                    finalCol = half4(prop.aaa, 1.0);
                #endif

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
            ENDHLSL
        }
    }
}
