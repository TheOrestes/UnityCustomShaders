Shader "Root16/ColorStripSelection"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _SelectionTex("Selection Texture", 2D) = "white" {}
        _SelectionValue("Selection Value", float) = 0
        _FloatEpsilon("Float Epsilon", float) = 0.01
        _BlinkSpeed("Blink Speed", float) = 1
        _BlinkRange("Blink Range", Range(0,1)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "RenderType"="Transparent" }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _SelectionTex;
            float4 _MainTex_ST;
            float _SelectionValue;  // selection value :D
            float _FloatEpsilon;    // Controls selection error
            float _BlinkSpeed;      // speed at which to blink
            float _BlinkRange;      // range of blinking 0 = black to color, 1 = white to color

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 finalColor = float4(0,0,0,1);

                // sample the Main texture
                float4 col = tex2D(_MainTex, i.uv);

                // sample the selection texture
                float4 selTexColor = tex2D(_SelectionTex, i.uv);
                //float3 GreySelectionColor = dot(_SelectionColor.rgb, float3(0.3, 0.59, 0.11));

                float3 GreySelectionColor = float3(_SelectionValue, _SelectionValue, _SelectionValue);
                
                
                if(abs(selTexColor.r - GreySelectionColor.r) < _FloatEpsilon &&
                   abs(selTexColor.g - GreySelectionColor.g) < _FloatEpsilon &&
                   abs(selTexColor.b - GreySelectionColor.b) < _FloatEpsilon)
                {
                    finalColor = col;
                }
                else
                {
                    finalColor = float4(col.r, col.g, col.b, 0);
                } 
                           
                // Blink it!!
                finalColor.rgb *= (_BlinkRange + abs(sin(_Time.y * _BlinkSpeed)));
           
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);

                return float4(finalColor);
            }
            ENDCG
        }
    }
}
