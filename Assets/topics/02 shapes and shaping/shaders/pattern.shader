Shader "examples/week 2/pattern"
{
    Properties
    {
        patternColor ("patternColor", Color) = (0.86, 0.78, 0.48, 1)
        _gridSize ("gridSize", Range(1, 100)) = 24
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
            uniform float3 patternColor;
            uniform int _gridSize;

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

            float4 frag (Interpolators i) : SV_Target
            {
                float output = 0;

                int gridSize = _gridSize;
                float2 uv = i.uv * gridSize;
                float2 gridUV = frac(uv) * 2 -1;

                // 确定线段的起点和终点
                float2 startPoint = float2(0.0, 0.0); // 网格的中心
                float2 endPoint = float2(0.5, 0.5); 

                // 计算两点之间的距离和角度
                float distance = length(endPoint - startPoint);
                float angle = atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x);

                // 根据距离和角度绘制线段
                float2 lineUV = gridUV - startPoint;
                float lineLength = length(lineUV);
                float lineAngle = atan2(lineUV.y, lineUV.x);
                float lineMask = step(0.05, abs(lineAngle - angle)) * step(lineLength, distance);

                // output = 1 - lineMask;

                float indexX = sin(floor(uv.x)); // different in diff cell
                float indexY = sin(floor(uv.y));

                float time = _Time.z;
                gridUV.x += sin(time) * 0.5f * indexX * indexY;
                gridUV.y += cos(time) * 0.5f * indexY * indexX;

                output = 1- step((abs(sin(time)) + 1) * 0.3, length(gridUV));

                return float4( output * patternColor.x, lineUV.x * output * patternColor.y * 3, lineUV.y * output * patternColor.z * 3, 1.0);
            }
            ENDCG
        }
    }
}
