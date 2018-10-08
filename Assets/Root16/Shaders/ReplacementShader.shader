Shader "Root16/ReplacementShader"
{
	SubShader
	{
		Tags { "RenderType"="Opaque"}
		Pass
		{
			Fog { Mode Off }
			Color [Color_ID]
		}
	}	

	SubShader
	{
		Tags { "RenderType"="Transparent"}
		Pass
		{
			Fog { Mode Off }
			Color [Color_ID]
		}
	}	

	SubShader
	{
		Tags { "RenderType"="ID"}
		Pass
		{
			Fog { Mode Off }
			Color [Color_ID]
		}
	}	
}
