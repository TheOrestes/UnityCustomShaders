Shader "Root16/Screenspace_surface"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [HDR] _Emission("Emission", Color) = (0,0,0)
        _HalftoneTex("Halftone texture", 2D) = "white" {}

        _RemapInputMin("Remap Input Min Value", Range(0,1)) = 0
        _RemapInputMax("Remap Input Max Value", Range(0,1)) = 1
        _RemapOuptutMin("Remap Output Min Value", Range(0,1)) = 0
        _RemapOuptutMax("Remap Output Max Value", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Halftone fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _HalftoneTex;
        float4 _HalftoneTex_ST;

        struct Input
        {
            float2 uv_MainTex;
            float4 screenPos;
        };

        struct HalftoneOutput
        {
            fixed3 Albedo;
            float2 screenPos;
            half3 Emission;
            fixed Alpha;
            fixed3 Normal;
        };

        half3 _Emission;
        fixed4 _Color;

        float _RemapInputMin;
        float _RemapInputMax;
        float _RemapOuptutMin;
        float _RemapOuptutMax;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        // Custom Remap Function
        float Remap(float input, float inMin, float inMax, float outMin, float outMax)
        {
            float relativeValue = (input - inMin) / (inMax - inMin);
            return lerp(outMin, outMax, relativeValue);
        }

        // Custom Lighting function
        float4 LightingHalftone(HalftoneOutput OUT, float3 lightDir, float atten)
        {
            //how much does the normal point towards the light?
            float towardsLight = dot(OUT.Normal, lightDir);
            //remap the value from -1 to 1 to between 0 and 1
            towardsLight = towardsLight * 0.5 + 0.5;

            //combine shadow and light and clamp the result between 0 and 1 to get light intensity
            float lightIntensity = saturate(atten * towardsLight);

            //get halftone comparison value
            float halftoneValue = tex2D(_HalftoneTex, OUT.screenPos).r;

            halftoneValue = Remap(halftoneValue, _RemapInputMin, _RemapInputMax, _RemapOuptutMin, _RemapOuptutMax);

            float halftoneChange = fwidth(halftoneValue) * 0.5;
            //make lightness binary between hully lit and fully shadow based on halftone pattern.
            lightIntensity = smoothstep(halftoneValue - halftoneChange, halftoneValue + halftoneChange, lightIntensity);

            //combine the color
            float4 col;
            //intensity we calculated previously, diffuse color, light falloff and shadowcasting, color of the light
            col.rgb = lightIntensity * OUT.Albedo * _LightColor0.rgb;
            //in case we want to make the shader transparent in the future - irrelevant right now
            col.a = OUT.Alpha;

            return col;
        }

        void surf (Input IN, inout HalftoneOutput o)
        {
            // Get rid of perspective correction!
            float2 texCoord = IN.screenPos.xy / IN.screenPos.w;

            // Make sure it considers screen aspect for avoiding weird stretches
            float aspect = _ScreenParams.x / _ScreenParams.y;
            texCoord.x *= aspect;

            // Make sure we can apply scaling & offset too
            texCoord = TRANSFORM_TEX(texCoord, _HalftoneTex);

            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Emission = _Emission;
            o.screenPos = texCoord;
        }
        ENDCG
    }
    FallBack "Standard"
}
