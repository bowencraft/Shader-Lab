﻿Shader "examples/week 7/lambert"
{
    Properties 
    {

    }
    SubShader
    {
        Tags {}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct MeshData
            {
                float4 vertex : POSITION;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
