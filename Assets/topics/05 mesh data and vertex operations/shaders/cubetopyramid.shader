Shader "Custom/PolarCoordinateDisplacementWithWave"
{
    Properties
    {
        _Scale ("Noise Scale", Range(2, 50)) = 15.5
        _Displacement ("Displacement", Range(0, 0.75)) = 0.33
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _GradientColor ("Gradient Color", Color) = (0, 1, 1, 1)
        _UsePolar ("Use Polar Coordinates", Range(0, 1)) = 1
        _WaveFrequency ("Wave Frequency", Float) = 10.0
        _WaveAmplitude ("Wave Amplitude", Float) = 0.1
        _GradientStrength ("Gradient Strength", Float) = 1.0
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

            float _Scale;
            float _Displacement;
            float4 _BaseColor;
            float4 _GradientColor;
            float _UsePolar;
            float _WaveFrequency;
            float _WaveAmplitude;
            float _GradientStrength;

            float rand (float2 uv) {
                return frac(sin(dot(uv.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float value_noise (float2 uv) {
                float2 ipos = floor(uv);
                float2 fpos = frac(uv); 
                
                float o  = rand(ipos);
                float x  = rand(ipos + float2(1, 0));
                float y  = rand(ipos + float2(0, 1));
                float xy = rand(ipos + float2(1, 1));

                float2 smooth = smoothstep(0, 1, fpos);
                return lerp( lerp(o,  x, smooth.x), 
                             lerp(y, xy, smooth.x), smooth.y);
            }

            float fractal_noise (float2 uv) {
                float n = 0;

                n  = (1 / 2.0)  * value_noise( uv * 1);
                n += (1 / 4.0)  * value_noise( uv * 2); 
                n += (1 / 8.0)  * value_noise( uv * 4); 
                n += (1 / 16.0) * value_noise( uv * 8);
                
                return n;
            }

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 color : COLOR;
                float2 uv : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                
                float r = length(worldPos.xz);
                float theta = atan2(worldPos.z, worldPos.x);
                
                float wave = sin(theta * _WaveFrequency + worldPos.y) * _WaveAmplitude;
                r += wave;
                
                float fn = fractal_noise(v.uv * _Scale);
                float3 polarPosition = float3(r * cos(theta), worldPos.y, r * sin(theta)) + v.normal * fn * _Displacement;
                
                float3 displacedPosition = lerp(worldPos, polarPosition, _UsePolar);
                
                o.pos = UnityObjectToClipPos(float4(displacedPosition, 1.0));
                o.uv = v.uv;
                o.worldPos = float4(worldPos, 1.0);

                float t = fractal_noise(v.uv * _Scale);
                o.color = lerp(_BaseColor.rgb, _GradientColor.rgb, t);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {

                float gradientFactor = saturate((i.worldPos.y + _GradientStrength) / (_GradientStrength * 2.0));
                float3 finalColor = lerp(i.color, _GradientColor.rgb, gradientFactor);
                return float4(finalColor, 1.0);
            }
            ENDCG
        }
    }
}