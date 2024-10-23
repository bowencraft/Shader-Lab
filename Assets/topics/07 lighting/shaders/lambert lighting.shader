Shader "examples/week 7/lambert"
{
    Properties 
    {
        _surfaceColor ("surface color", Color) = (0.4, 0.1, 0.9)
        [Toggle] _normalMode ("normal mode", Float) = 0
    }
    SubShader
    {
        Tags {"LightMode"="ForwardBase"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            float3 _surfaceColor;
            float _normalMode;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;
                float3 normal = normalize(i.normal);
                
                float3 lightDirection = _WorldSpaceLightPos0;
                float3 lightColor = _LightColor0;

                float falloff = max(0, dot(lerp(i.normal, normal, _normalMode), lightDirection));
                float3 diffuse = falloff * _surfaceColor * lightColor;

                color = diffuse;
                
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
