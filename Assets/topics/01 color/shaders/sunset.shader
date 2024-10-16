Shader "homework/assignment 1"
{
    Properties
    {
        _sunColorSky ("Sun Color in Sky", Color) = (0.86, 0.78, 0.48, 1)
        _sunColorSea ("Sun Color in Sea", Color) = (0.6, 0.6, 0.6, 1) // 灰色
        _seaColor ("Sea Color", Color) = (0.18, 0.3, 0.49, 1)
        _skyColor ("Sky Color", Color) = (0.9, 0.38, 0.15, 1)
        _sunCenterColor ("Sun Center Color", Color) = (1, 1, 1, 1) // 白色
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
            #define PI 3.141592653
            
            uniform float3 _sunColorSky;
            uniform float3 _sunColorSea;
            uniform float3 _seaColor;
            uniform float3 _skyColor;
            uniform float3 _sunCenterColor; // 中间的白色
            
            float circle (float2 uv, float2 offset, float size) {
                return smoothstep(0.0, 0.005, 1 - length(uv - offset) / size);
            }
            
            struct MeshData {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Interpolators vert (MeshData v) {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target {
                
                float2 uv = i.uv; // UV坐标
                float2 sunUV = i.uv * 2 - 1; // 太阳的UV计算
                
                // 创建太阳的形状
                float sunMask = circle(sunUV, float2(0.0, -0.1), 0.3);

                // 太阳颜色渐变，从中心的白色到四周的橙色
                float distanceFromCenter = length(sunUV); // 距离太阳中心的距离
                
                
                float3 sunGradient = lerp(_sunCenterColor, _sunColorSky, distanceFromCenter / 0.15); // 0.5是太阳半径
                float timeDelta = smoothstep(0, 1, sin(_Time.y ) * 0.5 + 0.5);
                float sunBlur = lerp(sunGradient, timeDelta, distanceFromCenter / 0.15);
                
                // 天空中的太阳颜色（暖黄色）
                float3 sunSkyColor = sunBlur * sunGradient;
                
                // 海水中的太阳颜色（灰色）
                float3 sunSeaColor = sunBlur * _sunColorSea;
                
                // 使用smoothstep计算天空与海洋的渐变
                float wave = 0.04 * sin(_Time.y * 0.3 * PI); // 创建一个随时间变化的波浪形状
                float gradient1Driver = smoothstep(0.32 + wave, 0.35 + wave, uv.y); // 将波浪形状添加到渐变计算中
                                
                // 使用Y轴的UV坐标判断海水和天空区域
                bool isSky = i.uv.y <= gradient1Driver;
                
                // 基础颜色混合，天空和海水之间的渐变
                float3 base = lerp(_seaColor, _skyColor, gradient1Driver);

                // 根据是否在天空中选择不同的太阳颜色
                float3 sun = isSky ? sunSkyColor : sunSeaColor;

                // 将基础颜色与太阳颜色进行混合
                float3 finalColor = base + sun;

                return float4(finalColor, 1.0);
            }
            ENDCG
        }
    }
}
