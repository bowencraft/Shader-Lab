Shader "examples/week 2/shaping"
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

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                uv = 2.0 * uv - 1;
                // uv *= 4;

                float x = uv.x;
                float y = uv.y;
                //
                // float c = x;
                // c = floor(x+1);

                float2 size =  float2(0.5,0.5);
                // float leftEdge = step(-size.x, uv.x);
                // float rightEdge = 1- step(size.x, uv.x);
                // float bottomEdge = step(-size.y, uv.y);
                // float topEdge = 1- step(size.y, uv.y);

                // float shape = leftEdge - 1 + rightEdge;
                // float shape = leftEdge * rightEdge * bottomEdge * topEdge;

                // make triangle shape
                float shape = 1 - step(size.x,uv.x - uv.y);


                return float4(shape.rrr, 1.0);
            }
            ENDCG
        }
    }
}
