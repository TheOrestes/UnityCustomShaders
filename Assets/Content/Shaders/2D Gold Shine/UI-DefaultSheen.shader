// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Root16/UI/DefaultSheen"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15
			
		_SheenSpeed ("Sheen Speed", Float) = 1
		_SheenIntensity("Sheen Intensity", Range(0,1)) = 1
		_SheenColor("Sheen Color", Color) = (1,1,1,1)
		_SheenThickness("Sheen Thickness", Range(0,1)) = 0.4
		_SheenAngle("Sheen Angle (Degrees)", Range(0,360)) = 35

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;

			float _SheenSpeed;
			float _SheenIntensity;
			float _SheenThickness;
			float _SheenAngle;
			fixed4 _SheenColor;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

                OUT.color = v.color * _Color;
                return OUT;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

				// Get position in UV space in range [0,1]
                float x = (IN.worldPosition.x + _ScreenParams[0] / 2) / _ScreenParams[0];
                float y = (IN.worldPosition.y + _ScreenParams[1] / 2) / _ScreenParams[1];

				// Consider the sheen angle & modify UVs
				float radAngle = _SheenAngle * 0.017453f;	// DegAngle * PI/180

				float s = sin(radAngle);
				float c = cos(radAngle);
				float2x2 rotationMatrix = float2x2(c, -s, s, c);
				float2 xy = mul(float2(x, y) - float2(0.5f, 0.5f), rotationMatrix) + float2(0.5f, 0.5f);
				x = xy.x;
				y = xy.y;

				//x = x * cos(radAngle) - y * sin(radAngle);
				//y = y * cos(radAngle) + x * sin(radAngle);

				// Create a band using two smoothsteps & animate using Sin of time!
				//http://www.fundza.com/rman_shaders/smoothstep/index.html
				float angle = ((_SheenSpeed * _Time[1]) % 90.0f) * 0.017453f;
				float sineTime = sin(angle);
				float startX = sineTime;
				float startXEnd = sineTime - (_SheenThickness / 2.0f);
				float endX = startXEnd;
				float endXEnd = startXEnd - (_SheenThickness / 2.0f);

				float sheenPattern = smoothstep(startX, startXEnd, x) * (1 - smoothstep(endX, endXEnd, x));
                half3 sheen = _SheenColor.rgb * half3(sheenPattern, sheenPattern, sheenPattern);

                color.rgb += sheen * _SheenIntensity;

                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                return color;
            }
        ENDCG
        }
    }
}
