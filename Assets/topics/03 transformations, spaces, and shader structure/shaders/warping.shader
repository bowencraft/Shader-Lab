﻿Shader "examples/week 3/warping"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
        
            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            float circle (float2 uv, float size) {
                return smoothstep(0.0, 0.005, 1 - length(uv) / size);
            }
            
            float rectangle (float2 uv, float2 scale) {
                float2 s = scale * 0.5;
                float2 shaper = float2(step(-s.x, uv.x), step(-s.y, uv.y));
                shaper *= float2(1-step(s.x, uv.x), 1-step(s.y, uv.y));
                return shaper.x * shaper.y;
            }


            float2x2 rotate2D (float angle) {
                return float2x2 (
                    cos(angle), -sin(angle),
                    sin(angle),  cos(angle)
                );
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv * 2 - 1;
                float time = _Time.y;
                float3 color = 0;

                float warpStrength = 0.33;
                float2 warp = 0;
                warp += cos(uv.yx + float2(time, 1.5) ) * warpStrength;
                warp += sin(uv.yx + float2(0, time * 3) ) * warpStrength;

                uv += warp;
                    // creating a rectangle with our uniquely transformed uv space
                    color = rectangle(uv, float2(0.4, 0.4 * 1.618)); 

                // color = circle(uv, 0.5);
                
                // color += float3(uv.x, 0, uv.y);
                
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
