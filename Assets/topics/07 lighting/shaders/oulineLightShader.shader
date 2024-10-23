Shader "Custom/OutlinedDarkmapShader"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
        _DarkTex ("Dark Texture", 2D) = "black" {} 
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1) 
        _OutlineThickness ("Outline Thickness", Range(0.01, 1)) = 0.05 
        _Threshold ("Shadow Threshold", Range(0,1)) = 0.5 
        _SurfaceColor ("Surface Color", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(0,1)) = 0.5
        _DiffuseLightSteps ("Diffuse Light Steps", Int) = 4
        _SpecularLightSteps ("Specular Light Steps", Int) = 2
        _AmbientColor ("Ambient Color", Color) = (0.2, 0.2, 0.2)
    }

    SubShader
    {
        Tags { "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include <UnityLightingCommon.cginc>

            #include "UnityCG.cginc"

            float4 _SurfaceColor;
            float _Gloss;
            int _DiffuseLightSteps;
            int _SpecularLightSteps;
            float3 _AmbientColor;
            sampler2D _MainTex;
            sampler2D _DarkTex;
            float _Threshold;
            float4 _OutlineColor;
            float _OutlineThickness;

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
                float3 viewDir : TEXCOORD2;
            };

            Interpolators vert(MeshData v)
            {
                Interpolators o;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.viewDir = normalize(_WorldSpaceCameraPos.xyz - o.posWorld.xyz);
                return o;
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float3 normal = normalize(i.normal);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float diffuseFalloff = max(0, dot(normal, lightDir));

                float stepFactor = floor(diffuseFalloff * _DiffuseLightSteps) / _DiffuseLightSteps;
                float nextStepFactor = floor((diffuseFalloff + 1.0 / _DiffuseLightSteps) * _DiffuseLightSteps) / _DiffuseLightSteps;

                float4 baseColor = tex2D(_MainTex, i.posWorld.xy);
                float3 ambientColor = _AmbientColor * _SurfaceColor.rgb;

                float4 darkColor = tex2D(_DarkTex, i.posWorld.xy);
                float3 combinedDarkAmbient = ambientColor + darkColor.rgb * (1.0 - diffuseFalloff);

                float edgeFactor = smoothstep(stepFactor - _OutlineThickness, stepFactor + _OutlineThickness, diffuseFalloff);
                float3 outlineColor = _OutlineColor.rgb * (1 - edgeFactor);

                float3 finalColor = lerp(combinedDarkAmbient, baseColor.rgb * stepFactor, step(diffuseFalloff, _Threshold));
                finalColor += outlineColor; 

                finalColor = finalColor + combinedDarkAmbient + _LightColor0;

                return float4(finalColor, 1.0);
            }
            ENDCG
        }
    }
}