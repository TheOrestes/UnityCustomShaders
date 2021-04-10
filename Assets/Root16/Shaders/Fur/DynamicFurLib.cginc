#pragma target 3.0

#include "Lighting.cginc"
#include "UnityCG.cginc"

sampler2D _MainTex;

fixed4 _Color;

half _Smoothness;

float _Length;
float _Density;
int _FurMultiplier;
float _Rigidness;
float _RimPower;
fixed4 _RimColor;
sampler2D _FurTex;

struct appdata
{
    float2 uv : TEXCOORD0;
    float4 vertex : POSITION;
    float3 normal: NORMAL;
};
            
struct v2f
{
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    float3 worldPos : TEXCOORD1;
    float3 worldNormal : NORMAL;
};
  
fixed3 lightAttenuation(float3 albedo, float3 wNormal, float3 wPos)
{
    fixed3 wLight = normalize(_WorldSpaceLightPos0.xyz);
    fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos);
    fixed3 halfVector = normalize(viewDir + wLight);
    
    half ndoth = dot(wNormal, halfVector);
    half ndotl = dot(wNormal, wLight);
    
    fixed3 diffuse = _LightColor0.rgb * saturate(ndotl) + UNITY_LIGHTMODEL_AMBIENT.xyz;
    fixed3 specular = _LightColor0.rgb * _SpecColor.rgb * pow(saturate(ndoth), _Smoothness);

    return diffuse * albedo + specular;
}

    
v2f baseVert (appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.uv = v.uv;
    return o;
}
    

fixed4 baseFrag (v2f i) : SV_Target
{
    fixed3 color = tex2D(_MainTex, i.uv).rgb * _Color;
    color = lightAttenuation(color, normalize(i.worldNormal), i.worldPos);
    return fixed4(color, 1.0);
}
    
v2f furVert (appdata v)
{
    v2f output;
    float3 pos = v.vertex.xyz + v.normal * _Length * FURSTEP;
    float4 gravity = float4(0,-1,0,0) * (1-_Rigidness);

    pos += clamp(mul(unity_WorldToObject, gravity).xyz, -1, 1) * pow(FURSTEP, 3) * _Length;

    output.vertex = UnityObjectToClipPos(float4(pos, 1));

    output.uv = v.uv;
    output.worldNormal = UnityObjectToWorldNormal(v.normal);
    output.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

    return output;
}
    
fixed4 furFrag (v2f i) : SV_Target
{
     fixed alpha = tex2D(_FurTex, i.uv * _FurMultiplier).r;
     fixed3 albedo = baseFrag(i).rgb - pow(1-FURSTEP, 3) * 0.1f;

     fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
     half rim = 1.0 - saturate(dot(viewDir, i.worldNormal));
     albedo += fixed4(_RimColor.rgb * pow(rim, _RimPower), 1.0);

     alpha = clamp(alpha - pow(FURSTEP,2) * _Density, 0, 1);
     return fixed4(albedo, alpha);
}