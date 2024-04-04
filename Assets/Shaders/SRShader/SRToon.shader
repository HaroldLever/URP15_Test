Shader "MyShader/SRToon"
{
    Properties
    {
        [Header(Settings)][Space(10)]
        [Enum(Off,0,On,1)] _ZWrite("ZWrite", Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("ZTest", Float) = 4 //"LessEqual"
        [Enum(UnityEngine.Rendering.CullMode)] _Culling("Culling", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcColor("SrcColor", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstColor("DstColor", Float) = 10
        [Enum(UnityEngine.Rendering.BlendOp)] _BlendOp("BlendOp", Float) = 0

        [Header(Face)][Space(10)]
        [Toggle(_IS_FACE)] _IsFace("IsFace", Float) = 0.0

        [Header(Shadow)][Space(10)]
        [Toggle(_RECEIVE_SHADOW)] _ReceiveShadow("ReceiveShadow", Float) = 1.0
        [Toggle(_USE_SHADOW_DELAY)] _UseShadowDelay("UseShadowDelay", Float) = 0.0
        [Space(5)]
        [Toggle(_BETTER_MAINLIGHT_SHADOW)] _BetterMainLightShadow("BetterMainLightShadow", Float) = 0.0
        _ML_MaxStep ("ML_MaxStep", float) = 1
        _ML_StepLength ("ML_StepLength", float) = 0.0001
        _ML_SampleOffset ("ML_SampleOffset", Range(0.0,0.005)) = 0.0015

        [Header(Ambient)][Space(10)]
        _AmbientModulate("AmbientModulate", Color) = (1, 1, 1, 1)

        [Header(Outline)][Space(10)]
        _OutlineParam("OutlineParam", Vector) = (5.0, 0.00001,0,0)

        [Header(Colors)][Space(10)]
        [MainColor] _BaseColor("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        [Toggle(_ONLY_COLOR)] _OnlyColor("OnlyColor", Float) = 0.0
        
        [Header(Textures)][Space(10)]
        [MainTexture] _BaseMap("BaseMap", 2D) = "white"{}
        [KeywordEnum(None,RGB,A,RGBA)] _BaseMap_Debug ("BaseMap_Debug", float) = 0
        // _NormalMap("NormalMap", 2D) = "bump"{}
        // [KeywordEnum(None,R,G,B,A,RGB)] _NormalMap_Debug ("NormalMap_Debug", float) = 0
        _LightMap("LightMap", 2D) = "black"{}
        [KeywordEnum(None,R,G,B,A)] _LightMap_Debug ("LightMap_Debug", float) = 0
        _WarmRampMap("WarmRampMap", 2D) = "white"{}
        _CoolRampMap("CoolRampMap", 2D) = "white"{}
        [KeywordEnum(Warm,Cool)] _RampMap_Mode("RampMap_Mode", float) = 0
        [Toggle(_RAMPMAP_DEBUG)] _RampMap_Debug ("RampMap_Debug", float) = 0
        _RampRemap("RampRemap", Vector) = (0,1,0,1)
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

        Pass    //"SRToonLit"
        {
            Name "SRToonLit"

            Tags
            {
                "LightMode" = "UniversalForward"
            }

            ZWrite [_ZWrite]
            ZTest [_ZTest]
            Cull [_Culling]
            Blend [_SrcColor] [_DstColor]
            BlendOp [_BlendOp]

            HLSLPROGRAM

            #pragma vertex SRToonLitVertex
            #pragma fragment SRToonLitFragment

            // -------------------------------------
            // Material keywords
            #pragma shader_feature_local _ _ONLY_COLOR
            #pragma shader_feature_local _BASEMAP_DEBUG_NONE _BASEMAP_DEBUG_RGB _BASEMAP_DEBUG_A _BASEMAP_DEBUG_RGBA
            #pragma shader_feature_local _LIGHTMAP_DEBUG_NONE _LIGHTMAP_DEBUG_R _LIGHTMAP_DEBUG_G _LIGHTMAP_DEBUG_B _LIGHTMAP_DEBUG_A
            #pragma shader_feature_local _ _RAMPMAP_DEBUG
            // #pragma shader_feature_local _NORMALMAP_DEBUG_NONE _NORMALMAP_DEBUG_R _NORMALMAP_DEBUG_G _NORMALMAP_DEBUG_B _NORMALMAP_DEBUG_A _NORMALMAP_DEBUG_RGB
            // #pragma shader_feature_local _MASKMAP_DEBUG_NONE _MASKMAP_DEBUG_R _MASKMAP_DEBUG_G _MASKMAP_DEBUG_B _MASKMAP_DEBUG_A
            // #pragma shader_feature_local _PROPERTYMAP_DEBUG_NONE _PROPERTYMAP_DEBUG_RGB _PROPERTYMAP_DEBUG_A
            // #pragma shader_feature_local _ _ENVMAP1_DEBUG
            // #pragma shader_feature_local _ _ENVMAP2_DEBUG
            // #pragma shader_feature_local _ _ENVMAP3_DEBUG
            // #pragma shader_feature_local _ _RAMPMAP_SHADOW
            // #pragma shader_feature_local _ _MUL_SEMI
            // #pragma shader_feature_local _ _MUL_SHADOW
            // // #pragma multi_compile_local _ _VERTEXCOL_DEBUG
            #pragma multi_compile_local _ _RECEIVE_SHADOW
            #pragma multi_compile_local _ _IS_FACE
            #pragma multi_compile_local _RAMPMAP_MODE_WARM _RAMPMAP_MODE_COOL
            // #pragma multi_compile_local_fragment _ _ENABLE_RIM
            // #pragma multi_compile_local_fragment _ _ENABLE_LIGHT_PROBE
            #pragma multi_compile_local_fragment _ _BETTER_MAINLIGHT_SHADOW
            // #pragma multi_compile_local_fragment _ _BETTER_ADDLIGHT_SHADOW
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

            #include "Assets/Shaders/SRShader/SRToonInput.hlsl"
            #include "Assets/Shaders/SRShader/SRToonLitPass.hlsl"

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
            ZWrite [_ZWrite]
            ZTest [_ZTest]
            Cull [_Cull]
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

            #include "Assets/Shaders/SRShader/SRToonInput.hlsl"
            #include "Assets/Shaders/SRShader/SRToonDepthOnlyPass.hlsl"

            ENDHLSL
        }

        Pass    // ShadowCaster
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            Cull Off
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

            #include "Assets/Shaders/SRShader/SRToonInput.hlsl"
            #include "Assets/Shaders/SRShader/SRToonShadowCasterPass.hlsl"
            
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
            ZWrite [_ZWrite]
            ZTest [_ZTest]
            Cull [_Cull]

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

            #include "Assets/Shaders/SRShader/SRToonInput.hlsl"
            #include "Assets/Shaders/SRShader/SRToonDepthNormalPass.hlsl"
            
            ENDHLSL
        }
    
        Pass    // SROutline
        {
            Name "SRToonOutline"
            Tags
            {
                "LightMode" = "SROutline"
            }

            Cull Front
            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            
            // -------------------------------------
            // Shader Stages
            #pragma vertex SRToonOutlineVertex
            #pragma fragment SRToonOutlineFragment

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

            #include "Assets/Shaders/SRShader/SRToonInput.hlsl"
            #include "Assets/Shaders/SRShader/SRToonOutlinePass.hlsl"
            
            ENDHLSL
        }
    }
}
