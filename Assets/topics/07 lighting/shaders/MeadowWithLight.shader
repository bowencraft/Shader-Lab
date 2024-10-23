Shader "Custom/WaterSurface3D"
{
    Properties 
    {
        _SurfaceColor ("Surface Color", Color) = (0.0, 0.5, 0.7, 1.0)
        _Gloss ("Gloss", Range(0,1)) = 1
        _DiffuseLightSteps ("Diffuse Light Steps", Int) = 4
        _SpecularLightSteps ("Specular Light Steps", Int) = 2
        _AmbientColor ("Ambient Color", Color) = (0.1, 0.1, 0.1, 1.0)
        _WaveSpeed ("Wave Speed", Range(0.1, 5.0)) = 1.0
        _WaveHeight ("Wave Height", Range(0.1, 5.0)) = 1.0
        _TimeFactor ("Time Factor", Range(0.1, 5.0)) = 1.0
        _NoiseScale ("Noise Scale", Range(0.1, 10.0)) = 1.0
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            float4 _SurfaceColor;
            float _Gloss;
            int _DiffuseLightSteps;
            int _SpecularLightSteps;
            float4 _AmbientColor;
            float _WaveSpeed;
            float _WaveHeight;
            float _TimeFactor;
            float _NoiseScale;

            #define MAX_SPECULAR_POWER 256

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float3 posWorld : TEXCOORD1;
            };

            // 3D Perlin Noise function for wave deformation
            float PerlinNoise3D(float3 pos)
            {
                return sin(pos.x * _NoiseScale + _Time.y * _TimeFactor) * 
                       sin(pos.y * _NoiseScale + _Time.y * _TimeFactor) * 
                       sin(pos.z * _NoiseScale + _Time.y * _TimeFactor);
            }

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                // Transform vertex position to world space for 3D noise calculation
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                
                // Apply 3D Perlin noise to the y-axis based on world position
                float waveOffset = PerlinNoise3D(worldPos * _WaveSpeed) * _WaveHeight;
                v.vertex.y += waveOffset;

                o.normal = UnityObjectToWorldNormal(v.normal);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.posWorld = worldPos;

                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float3 normal = normalize(i.normal);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0;
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
                float3 halfDir = normalize(viewDir + lightDir);

                // Diffuse and specular light calculations
                float diffuseFalloff = max(0, dot(normal, lightDir));
                float specularFalloff = max(0, dot(normal, halfDir));
                
                // Apply glossiness and step the lighting for posterization effect
                specularFalloff = pow(specularFalloff, _Gloss * MAX_SPECULAR_POWER + 0.0001) * _Gloss;
                diffuseFalloff = floor(diffuseFalloff * _DiffuseLightSteps) / _DiffuseLightSteps;
                specularFalloff = floor(specularFalloff * _SpecularLightSteps) / _SpecularLightSteps;

                float3 diffuse = diffuseFalloff * _SurfaceColor.rgb * lightColor;
                float3 specular = specularFalloff * lightColor;

                // Enhance specular reflection on wave peaks
                float wavePeakFactor = saturate(specularFalloff + 0.3 * PerlinNoise3D(i.posWorld));
                specular *= wavePeakFactor;

                float3 color = diffuse + specular + _AmbientColor.rgb;

                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}