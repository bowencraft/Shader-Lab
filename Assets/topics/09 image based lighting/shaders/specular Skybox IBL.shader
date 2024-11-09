Shader "examples/week 9/specular IBL with UNITY_SAMPLE_TEXCUBE_LOD"
{
    Properties 
    {
        _albedo ("albedo", 2D) = "white" {}
        [NoScaleOffset] _normalMap ("normal map", 2D) = "bump" {}
        [NoScaleOffset] _displacementMap ("displacement map", 2D) = "gray" {}
//        [NoScaleOffset] _IBL ("IBL cube map", Cube) = "black" {}

        _gloss ("gloss", Range(0,1)) = 1
        _reflectivity ("reflectivity", Range(0,1)) = 0.5
        _normalIntensity ("normal intensity", Range(0, 1)) = 1
        _displacementIntensity ("displacement intensity", Range(0, 0.5)) = 0
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }

        // calling another shader pass here that adds this object to shadow casting
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #define DIFFUSE_MIP_LEVEL 5
            #define SPECULAR_MIP_STEPS 4
            #define MAX_SPECULAR_POWER 256

            sampler2D _albedo; float4 _albedo_ST;
            sampler2D _normalMap;
            sampler2D _displacementMap;
            // samplerCUBE _IBL;
            float _gloss;
            float _reflectivity;
            float _normalIntensity;
            float _displacementIntensity;

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
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.uv = TRANSFORM_TEX(v.uv, _albedo);
                
                float height = tex2Dlod(_displacementMap, float4(o.uv, 0, 0)).r * 2 - 1;
                v.vertex.xyz += v.normal * height * _displacementIntensity;

                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldNormal(v.tangent);
                o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float3 color = 0;
                float2 uv = i.uv;

                float3 tangentSpaceNormal = UnpackNormal(tex2D(_normalMap, uv));
                tangentSpaceNormal = normalize(lerp(float3(0, 0, 1), tangentSpaceNormal, _normalIntensity));
                
                float3x3 tangentToWorld = float3x3 
                (
                    i.tangent.x, i.bitangent.x, i.normal.x,
                    i.tangent.y, i.bitangent.y, i.normal.y,
                    i.tangent.z, i.bitangent.z, i.normal.z
                );

                float3 normal = mul(tangentToWorld, tangentSpaceNormal);

                float3 surfaceColor = lerp(0, tex2D(_albedo, uv).rgb, 1 - _reflectivity);

                float3 lightDirection = _WorldSpaceLightPos0;
                float3 lightColor = _LightColor0;

                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
                float3 viewReflection = reflect(-viewDirection, normal);

                float mip = (1 - _gloss) * SPECULAR_MIP_STEPS;
                float3 indirectSpecular = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, viewReflection, mip);

                float3 halfDirection = normalize(viewDirection + lightDirection);
                float directDiffuse = max(0, dot(normal, lightDirection));
                float specularFalloff = max(0, dot(normal, halfDirection));
                
                float3 directSpecular = pow(specularFalloff, _gloss * MAX_SPECULAR_POWER + 0.0001) * lightColor * _gloss;

                float3 specular = directSpecular + indirectSpecular * _reflectivity;

                float3 indirectDiffuse = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, normal, DIFFUSE_MIP_LEVEL);
                float3 diffuse = surfaceColor * (directDiffuse * lightColor + indirectDiffuse);

                color = diffuse + specular;
                return float4(color, 1.0);
            }
            ENDCG
        }
    }
}
