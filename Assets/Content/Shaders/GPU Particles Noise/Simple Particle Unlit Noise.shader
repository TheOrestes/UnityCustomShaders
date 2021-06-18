Shader "Root16/Simple Particle Unlit Noise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_TimeOffset("Phase Shift Offset", Range(0,100)) = 0.0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType"="Opaque" }
        LOD 100

		Blend One One	// Additive blending
		ZWrite Off		// Depth test off

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
				fixed4 color : COLOR;
                float3 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _TimeOffset;

            v2f vert (appdata v)
            {
                v2f o;

				float3 vertexOffset = float3(0, 0, 0);
				v.vertex.xyz += vertexOffset;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
				o.color = v.color;

				// pass across particle's incoming AgePercent param
				o.uv.z = v.uv.z;

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
				col *= i.color;
				col *= col.a;

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
