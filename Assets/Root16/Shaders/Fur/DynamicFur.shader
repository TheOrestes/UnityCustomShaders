Shader "Root16/DynamicFur"
{
    // Properties block
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Main Color", Color) = (1.0,1.0,1.0,1.0)
        _SpecColor ("Specular Color", Color) = (0.5,0.5,0.5,1.0)
        _Smoothness ("Smoothness", Range(1,48)) = 8
        _Length("Fur length", Range(0,1)) = 0.2
        _FurTex("Fur Texture", 2D) = "white" {}
        _Density("Fur Density", Range(0,1)) = 0.2
        _FurMultiplier("Fur Multiplier", int) = 1
        _Rigidness("Fur Rigidness", Range(0,1)) = 1
        _RimPower("Rim Shading strength", float) = 1.0
        _RimColor("Rim Color", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    
    // Category block
    // Everything inside it will be applied to all passes
    Category
    {
        Tags 
        { 
            "RenderType" = "Transparent" 
            "IgnoreProjector" = "True" 
            "Queue" = "Transparent" 
        }
        Cull Off
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha
        
        SubShader
        {
            Pass
            {
                CGPROGRAM
                #define FURSTEP 0.0
                #pragma vertex baseVert
                #pragma fragment baseFrag
                #include "DynamicFurLib.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #define FURSTEP 0.05
                #pragma vertex furVert
                #pragma fragment furFrag
                #include "DynamicFurLib.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #define FURSTEP 0.1
                #pragma vertex furVert
                #pragma fragment furFrag
                #include "DynamicFurLib.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #define FURSTEP 0.15
                #pragma vertex furVert
                #pragma fragment furFrag
                #include "DynamicFurLib.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #define FURSTEP 0.2
                #pragma vertex furVert
                #pragma fragment furFrag
                #include "DynamicFurLib.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #define FURSTEP 0.25
                #pragma vertex furVert
                #pragma fragment furFrag
                #include "DynamicFurLib.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #define FURSTEP 0.3
                #pragma vertex furVert
                #pragma fragment furFrag
                #include "DynamicFurLib.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #define FURSTEP 0.35
                #pragma vertex furVert
                #pragma fragment furFrag
                #include "DynamicFurLib.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #define FURSTEP 0.4
                #pragma vertex furVert
                #pragma fragment furFrag
                #include "DynamicFurLib.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #define FURSTEP 0.45
                #pragma vertex furVert
                #pragma fragment furFrag
                #include "DynamicFurLib.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #define FURSTEP 0.5
                #pragma vertex furVert
                #pragma fragment furFrag
                #include "DynamicFurLib.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #define FURSTEP 0.55
                #pragma vertex furVert
                #pragma fragment furFrag
                #include "DynamicFurLib.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #define FURSTEP 0.6
                #pragma vertex furVert
                #pragma fragment furFrag
                #include "DynamicFurLib.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #define FURSTEP 0.65
                #pragma vertex furVert
                #pragma fragment furFrag
                #include "DynamicFurLib.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #define FURSTEP 0.7
                #pragma vertex furVert
                #pragma fragment furFrag
                #include "DynamicFurLib.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #define FURSTEP 0.75
                #pragma vertex furVert
                #pragma fragment furFrag
                #include "DynamicFurLib.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #define FURSTEP 0.8
                #pragma vertex furVert
                #pragma fragment furFrag
                #include "DynamicFurLib.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #define FURSTEP 0.85
                #pragma vertex furVert
                #pragma fragment furFrag
                #include "DynamicFurLib.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #define FURSTEP 0.9
                #pragma vertex furVert
                #pragma fragment furFrag
                #include "DynamicFurLib.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #define FURSTEP 0.95
                #pragma vertex furVert
                #pragma fragment furFrag
                #include "DynamicFurLib.cginc"
                ENDCG
            }
            Pass
            {
                CGPROGRAM
                #define FURSTEP 1.0
                #pragma vertex furVert
                #pragma fragment furFrag
                #include "DynamicFurLib.cginc"
                ENDCG
            }
        }
    }
}