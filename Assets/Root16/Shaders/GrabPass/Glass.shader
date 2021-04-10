Shader "Custom/Glass"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("Normal", 2D) = "bump" {}
        _Distortion("Distortion Power", Range(0,1)) = 0.5
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Occlusion("Occlusion", Range(0,1)) = 1
        [Space]
        [Header(Rim)]
        [HDR]_RimColor("Rim Color", Color) = (0.5, 0.37, 0.87, 1)
        _RimPower("Rim Fill", Range(0,2)) = 0.1
        _RimSmooth("Rim Smoothness", Range(0.5, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

        //Pass
        //{
        //    ZWrite On
        //    ColorMask A
        //}

        GrabPass{ }

        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard alpha

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        #define EPSILON 1.192092896e-07

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _GrabTexture;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float3 viewDir;
            float4 screenPos;
        };

        half    _Glossiness;
        half    _Metallic;
        half    _Occlusion;
        fixed4  _Color;
        fixed3  _RimColor;
        half    _RimPower;
        half    _RimSmooth;
        half    _Distortion;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));

            half2 distortion = lerp(float2(1,1), pow(o.Normal.xy, 2), _Distortion);

            // Sample the Grab pass texture!
            float2 grabUV = IN.screenPos.xy / max(EPSILON, IN.screenPos.w) * distortion;
            fixed3 grabColor = tex2D(_GrabTexture, grabUV);

            o.Albedo = lerp(c.rgb, grabColor, c.a);
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Occlusion = _Occlusion;
            o.Alpha = c.a;

            half rimDot = 1 - pow(dot(o.Normal, IN.viewDir), _RimPower);
            half rim = smoothstep(0.5, max(0.5, _RimSmooth), rimDot);

            o.Emission = _RimColor * rim;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
