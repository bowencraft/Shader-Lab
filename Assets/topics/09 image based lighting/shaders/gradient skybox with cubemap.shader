Shader "examples/week 9/gradient skybox with cubemap blend"
{
    Properties 
    {
        _colorHigh ("color high", Color) = (1, 1, 1, 1)
        _colorLow ("color low", Color) = (0, 0, 0, 1)
        _offset ("offset", Range(0, 1)) = 0
        _contrast ("contrast", Float) = 1
        _CubeMap ("Cubemap", Cube) = "" {}
        _BlendFactor ("Blend Factor", Range(0, 1)) = 0.5
        _CubemapLOD ("Cubemap LOD", Range(0, 5)) = 0 // 控制LOD级别
    }

    SubShader
    {
        Tags {"Queue"="Background" "RenderType" = "Background" "PreviewType" = "Skybox"}
        Cull Off
        ZWrite Off

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
            samplerCUBE _CubeMap;
            float _BlendFactor;
            float _CubemapLOD;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;

                // 计算渐变颜色
                float3 coord = normalize(i.worldPos);
                float lerpValue = smoothstep(0, 1, pow(coord.y + _offset, _contrast));
                float3 gradientColor = lerp(_colorLow, _colorHigh, lerpValue);

                // 使用 texCUBElod 采样 Cubemap，带有 LOD 级别
                float3 cubemapColor = texCUBElod(_CubeMap, float4(coord, _CubemapLOD)).rgb;

                // 根据 _BlendFactor 混合渐变颜色和 Cubemap 颜色
                color = lerp(gradientColor, cubemapColor, _BlendFactor);

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
