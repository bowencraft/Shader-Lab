Shader "Custom/PerlinNoiseAndBlendingCircles"
{
    Properties
    {
        _BlendFactor ("Blend Factor", Range(0.0, 1.0)) = 0.1
        _CircleCount ("Circle Count", Range(1, 10)) = 2
        _DisplacementHeight ("Displacement Height", Range(0, 1)) = 0.2 
        _DisplacementRadius ("Displacement Radius", Range(0, 1)) = 0.3 
        _TimeScale ("Time Scale", Range(0, 10)) = 0.5                 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            float4 _CirclePositions[10]; // 圆的位置数组
            float _CircleRadii[10];      // 圆的半径数组
            float4 _CircleColors[10];    // 圆的颜色数组
            float _CircleCount;          // 圆的数量
            float _BlendFactor;          // 融合因子
            float _DisplacementHeight;   // 顶点抬起的最大高度
            float _DisplacementRadius;   // 顶点抬起的影响范围
            float _TimeScale;            

            // float perlinNoise(float2 pos, float time)
            // {
            //     return (snoise(float3(pos * 10.0, time)) + 1.0) * 0.5; // 柏林噪声生成 0-1 值
            // }
            
            float perlinNoise(float2 pos)
            {
                return frac(sin(dot(pos.xy, float2(12.9898,78.233))) * 43758.5453);
            }

            v2f vert (appdata v)
            {
                v2f o;
                float3 worldPos = v.vertex.xyz; 
                float time = _TimeScale * _Time.y; 

                float noiseDisplacement = perlinNoise(worldPos.xy);
                worldPos.z += noiseDisplacement * 0.1; 

                for (int j = 0; j < _CircleCount; j++)
                {
                    float2 circlePos = _CirclePositions[j].xy; 
                    float dist = length(worldPos.xy - circlePos);
                    float4 circleColor = _CircleColors[j];

                    float brightness = dot(circleColor.rgb, float3(0.299, 0.587, 0.114));

                    if (dist < _DisplacementRadius)
                    {
                        float liftFactor = smoothstep(_DisplacementRadius, 0.0, dist); 
                        float displacement = liftFactor * _DisplacementHeight * brightness;

                        if (j == 0)
                        {
                            displacement *= 1.5; 
                        }

                        worldPos.z += displacement;
                    }
                }

                o.pos = UnityObjectToClipPos(float4(worldPos, 1.0));
                o.uv = v.uv;
                return o;
            }

            float smoothMin(float d1, float d2, float k)
            {
                float h = max(k - abs(d1 - d2), 0.0);
                return min(d1, d2) - h * h * 0.25 / k;
            }

            fixed4 blendColors(float4 color1, float4 color2, float factor)
            {
                return lerp(color1, color2, factor); 
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float dist = 1.0;
                float totalWeight = 0.0;
                float4 finalColor = float4(0, 0, 0, 1); 
                
                for (int j = 0; j < _CircleCount; j++)
                {
                    float2 circlePos = _CirclePositions[j].xy;
                    float circleRadius = _CircleRadii[j];
                    float4 circleColor = _CircleColors[j];

                    float currentDist = length(i.uv - circlePos) - circleRadius;

                    if (j == 0)
                    {
                        dist = currentDist;
                        finalColor = circleColor;
                    }
                    else
                    {
                        dist = smoothMin(dist, currentDist, _BlendFactor);
                    }

                    float weight = smoothstep(circleRadius + _BlendFactor, circleRadius, currentDist);
                    totalWeight += weight;
                    finalColor += circleColor * weight;
                }

                if (totalWeight > 0.0)
                {
                    finalColor /= totalWeight;
                }

                if (dist < 0.0)
                {
                    return finalColor;
                }
                else
                {
                    return fixed4(0, 0, 0, 1); 
                }
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}