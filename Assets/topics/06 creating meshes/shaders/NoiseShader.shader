Shader "Custom/NoiseShader"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float hash3(float3 p)
            {
                return frac(sin(1000.0 * dot(p, float3(1.0, 57.0, -13.7))) * 4375.5453);
            }

            float noise3(float3 x)
            {
                float3 p = floor(x);
                float3 f = frac(x);
                f = f * f * (3.0 - 2.0 * f); // smoother interpolation

                return lerp(lerp(lerp(hash3(p + float3(0.0, 0.0, 0.0)), hash3(p + float3(1.0, 0.0, 0.0)), f.x),
                                 lerp(hash3(p + float3(0.0, 1.0, 0.0)), hash3(p + float3(1.0, 1.0, 0.0)), f.x), f.y),
                            lerp(lerp(hash3(p + float3(0.0, 0.0, 1.0)), hash3(p + float3(1.0, 0.0, 1.0)), f.x),
                                 lerp(hash3(p + float3(0.0, 1.0, 1.0)), hash3(p + float3(1.0, 1.0, 1.0)), f.x), f.y), f.z);
            }

            float noise(float3 x)
            {
                return (noise3(x) + noise3(x + 11.5)) / 2.0;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 R = float2(_ScreenParams.x, _ScreenParams.y);
                float3 U = float3(i.uv * 8.0 / R.y, 0.1 * _Time.y);
                float n = noise(U);
                float v = sin(6.28 * 10.0 * n);

                // Smooth the value
                v = smoothstep(1.0, 0.0, 0.5 * abs(v) / fwidth(v));

                float4 texColor = tex2D(_MainTex, i.uv + float2(1.0, sin(_Time.y)) / R);
                float4 color = lerp(exp(-33.0 / R.y) * texColor, 0.5 + 0.5 * sin(12.0 * n + float4(0, 2.1, -2.1, 0)), v);

                return color;
            }
            ENDCG
        }
    }
}