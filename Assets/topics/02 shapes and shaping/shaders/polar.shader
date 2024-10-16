Shader "examples/week 2/polar"
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
            #define TAU 6.28318530718

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

            float zigzag(float density, float height, float offset, float2 uv)
            {
                float shape = 0;
                shape = frac(uv.x * density + offset);
                shape = min(shape, 1-shape);
                return smoothstep(0,0.002,shape*height + offset - uv.y);

                return shape;
            }
            
            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                uv = uv * 2 - 1;
                float2 polarUV = float2(atan2(uv.y,uv.x), length(uv));

                polarUV.x = (polarUV.x /TAU) + 0.5;

                float time = _Time.y;

                polarUV.x = frac(polarUV.x + time);
                
                float output = 0;
                output = polarUV.x;

                output = zigzag(10, 0.5, 0.5, polarUV);
                
                return float4(output.rrr, 1.0);
            }
            ENDCG
        }
    }
}
