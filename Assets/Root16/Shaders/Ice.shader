// Reference : https://lindenreid.wordpress.com/2017/12/30/ice-shader-in-unity/

Shader "Root16/Ice"
{
	Properties
	{
		_RampTex("Ramp", 2D) = "white" {}
		_BumpTex("Bump", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_EdgeThickness("Silhoutte Thickness", float) = 1.0
		_DistortStrength("Distortion Strength", float) = 1.0
	}

	SubShader
	{
		GrabPass
		{
			"_BackgroundTexture"
		}
		
		// Background distortion!
		Pass
		{
			Tags { "Queue"="Transparent" } 

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _BackgroundTexture;
			sampler2D _BumpTex;
			float _DistortStrength;

			struct VS_INPUT
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct VS_OUTPUT
			{
				float4 pos : SV_POSITION;
				float4 grabPos : TEXCOORD0;
			};

			VS_OUTPUT vert(VS_INPUT i)
			{
				VS_OUTPUT o;

				o.pos = UnityObjectToClipPos(i.vertex);
				o.grabPos = ComputeGrabScreenPos(o.pos);

				float3 bump = tex2Dlod(_BumpTex, float4(i.texcoord, 0, 0)).rgb;
				o.grabPos.x += bump.x * _DistortStrength;
				o.grabPos.y += bump.y * _DistortStrength;

				return o; 
			}

			float4 frag(VS_OUTPUT i) : COLOR
			{
				return tex2Dproj(_BackgroundTexture, i.grabPos);
			}

			ENDCG
		}

		Pass
		{
			Tags 
			{
				"LightMode"="ForwardBase"
				"Queue"="Transparent" 
			}
			//Cull Off
			Blend SrcAlpha OneMinusSrcAlpha
			LOD 100

			// Transparency & lighting!
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"
			struct VS_INPUT
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};
			struct VS_OUTPUT
			{
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
				UNITY_FOG_COORDS(1)
			};
			sampler2D _RampTex, _BumpTex;
			float4 _Color;
			float _EdgeThickness;

			VS_OUTPUT vert (VS_INPUT v)
			{
				VS_OUTPUT o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.texcoord = v.texcoord;
				o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex).xyz);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag (VS_OUTPUT i) : COLOR
			{
				float edgeFactor = abs(dot(i.viewDir, i.normal));
				float oneMinusEdge = 1.0 - edgeFactor;
				float opacity = min(1.0, _Color.a / edgeFactor);
				opacity = pow(opacity, _EdgeThickness);
				float3 rgb = tex2D(_RampTex, float2(oneMinusEdge, 0.5)).rgb;
				// bump
				float3 bump = tex2D(_BumpTex, i.texcoord).rgb + i.normal.xyz;
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float ndotl = clamp(dot(bump, lightDir), 0.001, 1.0);
				UNITY_APPLY_FOG(i.fogCoord, rgb);
				return float4(rgb, opacity) * ndotl;
			}
			ENDCG
		}
	}
}
