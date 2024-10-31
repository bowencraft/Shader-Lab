Shader "examples/Combined/AnimatedWaveWater"
{
    Properties 
    {
        _albedo ("albedo", 2D) = "white" {}
        [NoScaleOffset] _normalMap ("normal map", 2D) = "bump" {}
        [NoScaleOffset] _displacementMap ("displacement map", 2D) = "white" {}
        _gloss ("gloss", Range(0,1)) = 1
        _normalIntensity ("normal intensity", Range(0, 1)) = 1
        _displacementIntensity ("displacement intensity", Range(0,1)) = 0.5
        _refractionIntensity ("refraction intensity", Range(0, 0.5)) = 0.1
        _opacity ("opacity", Range(0,1)) = 0.9
        _diffuseLightSteps ("diffuse light steps", Int) = 4
        _specularLightSteps ("specular light steps", Int) = 2
        _ambientColor ("ambient color", Color) = (0.7, 0.05, 0.15)
        _minLightColor ("min light color", Color) = (0, 0, 0)
        _maxLightColor ("max light color", Color) = (1, 1, 1)
        _waveFrequency ("Wave Frequency", Float) = 0.5
        _waveAmplitude ("Wave Amplitude", Float) = 0.3
        _waveSpeed ("Wave Speed", Float) = 1.0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "LightMode"="ForwardBase" }
        GrabPass { "_BackgroundTex" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc" 

            #define MAX_SPECULAR_POWER 256

            sampler2D _albedo; float4 _albedo_ST;
            sampler2D _normalMap;
            sampler2D _displacementMap;
            sampler2D _BackgroundTex;
            float _gloss;
            float _normalIntensity;
            float _displacementIntensity;
            float _refractionIntensity;
            float _opacity;
            int _diffuseLightSteps;
            int _specularLightSteps;
            float3 _ambientColor;
            float3 _minLightColor;
            float3 _maxLightColor;
            float _waveFrequency;
            float _waveAmplitude;
            float _waveSpeed;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 tangent : TEXCOORD2;
                float3 bitangent : TEXCOORD3;
                float3 posWorld : TEXCOORD4;
                float4 uvPan : TEXCOORD5;
                float4 screenUV : TEXCOORD6;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.uv = TRANSFORM_TEX(v.uv, _albedo);
                o.uvPan = float4(float2(0.9, 0.2) * _Time.x, float2(0.5, -0.2) * _Time.x);

                // 基于时间的波浪效果
                float wave = sin(_Time.x * _waveSpeed + v.uv.y * _waveFrequency) * _waveAmplitude;
                float height = tex2Dlod(_displacementMap, float4(o.uv + o.uvPan.xy, 0, 0)).r;
                v.vertex.xyz += v.normal * (height * _displacementIntensity + wave);

                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldNormal(v.tangent);
                o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenUV = ComputeGrabScreenPos(o.vertex);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;
                float2 screenUV = i.screenUV.xy / i.screenUV.w;

                float3 tangentSpaceNormal = UnpackNormal(tex2D(_normalMap, uv + i.uvPan.xy));
                float3 tangentSpaceDetailNormal = UnpackNormal(tex2D(_normalMap, (uv * 0.5) + i.uvPan.zw));
                tangentSpaceNormal = BlendNormals(tangentSpaceNormal, tangentSpaceDetailNormal);
                tangentSpaceNormal = normalize(lerp(float3(0, 0, 1), tangentSpaceNormal, _normalIntensity));
                
                float2 refractionUV = screenUV.xy + (tangentSpaceNormal.xy * _refractionIntensity);
                float3 background = tex2D(_BackgroundTex, refractionUV);

                float3x3 tangentToWorld = float3x3 
                (
                    i.tangent.x, i.bitangent.x, i.normal.x,
                    i.tangent.y, i.bitangent.y, i.normal.y,
                    i.tangent.z, i.bitangent.z, i.normal.z
                );

                float3 normal = mul(tangentToWorld, tangentSpaceNormal);
                float3 surfaceColor = tex2D(_albedo, uv + i.uvPan.xy).rgb;

                float3 lightDirection = _WorldSpaceLightPos0;
                float3 lightColor = _LightColor0;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
                float3 halfDirection = normalize(viewDirection + lightDirection);

                float diffuseFalloff = max(0, dot(normal, lightDirection));
                float specularFalloff = max(0, dot(normal, halfDirection));

                diffuseFalloff = floor(diffuseFalloff * _diffuseLightSteps) / _diffuseLightSteps;
                specularFalloff = floor(pow(specularFalloff, _gloss * MAX_SPECULAR_POWER + 0.0001) * _specularLightSteps) / _specularLightSteps;

                float3 diffuse = lerp(_minLightColor, _maxLightColor, diffuseFalloff) * surfaceColor * lightColor;
                float3 specular = lerp(_minLightColor, _maxLightColor, specularFalloff) * lightColor;

                float3 color = (diffuse * _opacity) + (background * (1 - _opacity)) + specular + _ambientColor;
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}