Shader "Root16/colorID"
{
	Properties
	{
		Color_ID("Color ID", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags { "RenderType"="ID" }
		Pass
		{
			Fog { Mode Off }
			Color [Color_ID]
		}
	}
}
