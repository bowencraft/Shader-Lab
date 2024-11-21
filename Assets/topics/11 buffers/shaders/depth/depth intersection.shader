Shader "examples/week 11/depth intersection"
{
    Properties {
        _size ("intersection size", Range(0.1, 1)) = 0.2
    }

    SubShader
    {
        Tags{"Queue"="Transparent"}
        Cull Off
        ZWrite Off
        
        // blend source + destination
        Blend One One
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // declare depth texture
            sampler2D _CameraDepthTexture;
            float _size;


            struct MeshData
            {
                float4 vertex : POSITION;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                float surfZ : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);

                o.surfZ = (-UnityObjectToViewPos(v.vertex)).z;
                
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;

                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                float depth = Linear01Depth(tex2D(_CameraDepthTexture, screenUV));

                depth /= _ProjectionParams.w; // 1 / far plane
                
                float difference = abs(depth - i.surfZ);
                // color = 1-step(_size, difference);
                color = smoothstep(_size, 0, difference);
                return float4(color, 1);
            }
            ENDCG
        }
    }
}
