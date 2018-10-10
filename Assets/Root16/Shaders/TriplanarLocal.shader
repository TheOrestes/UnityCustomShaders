Shader "Root16/TriplanarLocal" 
{
	Properties 
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_TextureScale ("Texture Scale", float) = 1
	}

	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard vertex:vert fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		float _TextureScale;

		struct Input 
		{
			float3 localPos;
			float3 localNormal;
		};

		void vert(inout appdata_full v, out Input data)
		{
			UNITY_INITIALIZE_OUTPUT(Input, data);
			data.localPos = v.vertex.xyz;
			data.localNormal = v.normal.xyz;
		}

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			// find UVs for each axis based on worldPosition of the fragment
			half2 xUV = IN.localPos.zy * _TextureScale;
			half2 yUV = IN.localPos.xz * _TextureScale;
			half2 zUV = IN.localPos.xy * _TextureScale;

			// Blending factor for triplanar mapping
			float3 bf = normalize(abs(IN.localNormal));
			bf /= dot(bf, (float3)1);

			// Sample texture using 3 UV sets just created
			half4 xDiffuse = tex2D(_MainTex, xUV) * bf.x;
			half4 yDiffuse = tex2D(_MainTex, yUV) * bf.y;
			half4 zDiffuse = tex2D(_MainTex, zUV) * bf.z;
			half4 color = (xDiffuse + yDiffuse + zDiffuse);

			o.Albedo = color.rgb;
			o.Alpha = color.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
