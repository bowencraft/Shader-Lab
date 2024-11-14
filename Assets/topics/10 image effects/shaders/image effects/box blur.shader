Shader "examples/week 10/box blur"
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

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                float3 color = 0;

                float3x3 boxBlurKernel = float3x3 (
                    .11, .11, .11,
                    .11, .11, .11,
                    .11, .11, .11
                );

                float2 ts = _MainTex_TexelSize.xy; 

                for(int x = -1; x <= 1; x++)
                {
                    for(int y = -1; y <= 1; y++)
                    {
                        float2 offset = float2(x,y) * ts;
                        float3 sample = tex2D(_MainTex, uv + offset);
                        color += sample * boxBlurKernel[x + 1][y + 1];
                    }
                }
                
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
