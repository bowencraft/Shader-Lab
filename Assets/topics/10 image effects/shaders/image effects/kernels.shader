Shader "examples/week 10/kernels"
{
    Properties
    {
        _MainTex ("render texture", 2D) = "white"{}
    }

    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            sampler2D _MainTex; float4 _MainTex_TexelSize;

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
            
            float3 convolution (float2 uv, float3x3 kernel) {
                float2 ts = _MainTex_TexelSize.xy;
                float3 result = 0;
                
                for(int x = -1; x <= 1; x++) {
                    for(int y = -1; y <= 1; y++) {
                        float2 offset = float2(x, y) * ts;
                        float3 sample = tex2D(_MainTex, uv + offset);
                        result += sample * kernel[x+1][y+1];
                    }
                }

                return result;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3x3 boxBlurKernel = float3x3 (
                    // box
                    0.11, 0.11, 0.11,
                    0.11, 0.11, 0.11,
                    0.11, 0.11, 0.11
                );

                float3x3 gaussianBlurKernel = float3x3 (
                    // gaussian
                    0.0625, 0.125, 0.0625,
                    0.1250, 0.250, 0.1250,
                    0.0625, 0.125, 0.0625
                );

                float3x3 sharpenKernel = float3x3 (
                    // sharpen
                     0, -1,  0,
                    -1,  5, -1,
                     0, -1,  0
                );

                float3x3 embossKernel = float3x3 (
                    // emboss
                    -2, -1,  0,
                    -1,  1,  1,
                     0,  1,  2
                );

                float3x3 edgeDetectionKernel = float3x3 (
                    // edge detection (kind of a bad one. better edge detection using sobel requires two kernels, one for each x and y dimension)
                     1,  0, -1,
                     0,  0,  0,
                    -1,  0,  1
                );
                
                float3 color = convolution(i.uv, edgeDetectionKernel);
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}