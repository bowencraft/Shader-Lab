﻿Shader "examples/week 9/gradient skybox"
{
    Properties 
    {
        _colorHigh ("color high", Color) = (1, 1, 1, 1)
        _colorLow ("color low", Color) = (0, 0, 0, 1)
        _offset ("offset", Range(0, 1)) = 0
        _contrast ("contrast", Float) = 1
    }

    SubShader
    {
        Tags { }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float3 _colorHigh;
            float3 _colorLow;
            float _offset;
            float _contrast;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 uv : TEXCOORD0;
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
                float3 color = 0;

                

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}