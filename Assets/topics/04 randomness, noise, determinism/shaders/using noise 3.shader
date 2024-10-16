Shader "Custom/AuroraShader"
{
    Properties
    {
    _TopColor ("Top Color", Color) = (0,1,0,1)
    _TopColor2 ("Top Color 2", Color) = (1,0,0,1)
    _BottomColor ("Bottom Color", Color) = (0,0,1,1)
    _BottomColor2 ("Bottom Color 2", Color) = (1,1,0,1)
    _ColorSpeed ("Color Change Speed", Float) = 0.5
        _NoiseScale ("Noise Scale", Float) = 10.0
        _NoiseSpeed ("Noise Speed", Float) = 1.0
        _NoiseIntensity ("Noise Intensity", Float) = 0.3
        _EdgeFade ("Edge Fade", Range(0.0, 0.5)) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            float4 _TopColor;
            float4 _BottomColor;
            float4 _TopColor2;
            float4 _BottomColor2;
            float _ColorSpeed;
            float _NoiseScale;
            float _NoiseSpeed;
            float _NoiseIntensity;
            float _EdgeFade;

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

            float Hash(float n)
            {
                return frac(sin(n) * 43758.5453);
            }

            float Noise(float2 x)
            {
                float2 p = floor(x);
                float2 f = frac(x);

                float a = Hash(p.x + p.y * 57.0);
                float b = Hash(p.x + 1.0 + p.y * 57.0);
                float c = Hash(p.x + (p.y + 1.0) * 57.0);
                float d = Hash(p.x + 1.0 + (p.y + 1.0) * 57.0);

                float2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

                return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
            }

            float UpperWave(float x, float time)
            {
                return 0.7 + 0.05 * sin(5.0 * x + time) + 0.05 * sin(10.0 * x + time * 0.5);
            }

            float LowerWave(float x, float time)
            {
                return 0.3 + 0.05 * sin(5.0 * x + time + 2.0) + 0.05 * sin(10.0 * x + time * 0.7 + 1.0);
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float time = _Time.y;
                float2 uv = i.uv;

                float upper = UpperWave(uv.x, time);
                float lower = LowerWave(uv.x, time);

                float t = (uv.y - lower) / (upper - lower);

                float noise = Noise(float2(uv.x * _NoiseScale, time * _NoiseSpeed));
                t += (noise - 0.5) * _NoiseIntensity * 2.0;
                float alpha = smoothstep(0.0, _EdgeFade, t) * smoothstep(1.0, 1.0 - _EdgeFade, t);

                float inAurora = step(0.0, t) * step(t, 1.0);
                float colorTime = sin(time * _ColorSpeed) * 0.5 + 0.5;

                float3 topColor = lerp(_TopColor.rgb, _TopColor2.rgb, colorTime);
                float3 bottomColor = lerp(_BottomColor.rgb, _BottomColor2.rgb, colorTime);

                float3 color = lerp(bottomColor, topColor, saturate(t)) * inAurora;

                return float4(color.rgb, 1) * alpha * inAurora;
            }
            ENDCG
        }
    }
}