Shader "Custom/SharpEdgeBumpDarkmapShader"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
        _DarkTex ("Dark Texture", 2D) = "black" {} // 用于暗部的叠加贴图
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1) // 勾线颜色
        _OutlineThickness ("Outline Thickness", Range(0.01, 1)) = 0.05 // 勾线粗细
        _Threshold ("Shadow Threshold", Range(0,1)) = 0.5 // 分界点
        _SurfaceColor ("Surface Color", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(0,1)) = 0.5
        _DiffuseLightSteps ("Diffuse Light Steps", Int) = 4
        _SpecularLightSteps ("Specular Light Steps", Int) = 2
        _AmbientColor ("Ambient Color", Color) = (0.2, 0.2, 0.2)
        _BlendMode ("Blend Mode", Range(0, 2)) = 0 // 0 = Normal, 1 = Additive, 2 = Multiply
        _BumpScale ("Bump Scale", Range(0, 1)) = 0.1 // 描边影响的凹凸程度
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
            int _BlendMode;
            float _BumpScale;

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

            float3 ApplyBlendMode(float3 baseColor, float3 darkColor, float blendMode)
            {
                if (blendMode == 0)
                    return baseColor; 
                else if (blendMode == 1)
                    return baseColor + darkColor; 
                else if (blendMode == 2)
                    return baseColor * darkColor; 
                else
                    return baseColor; 
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float3 normal = normalize(i.normal);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float diffuseFalloff = max(0, dot(normal, lightDir));

                float stepFactor = floor(diffuseFalloff * _DiffuseLightSteps) / _DiffuseLightSteps;
                float nextStepFactor = floor((diffuseFalloff + 1.0 / _DiffuseLightSteps) * _DiffuseLightSteps) / _DiffuseLightSteps;

                float4 baseColor = tex2D(_MainTex, i.posWorld.xy);
                float4 darkColor = tex2D(_DarkTex, i.posWorld.xy);
                float3 ambientColor = _AmbientColor * _SurfaceColor.rgb;

                float3 blendedColor = ApplyBlendMode(baseColor.rgb, darkColor.rgb, _BlendMode);

                float edgeFactor = abs(stepFactor - nextStepFactor) < _OutlineThickness ? 1 : 0;
                float3 outlineColor = _OutlineColor.rgb * edgeFactor;

                float3 modifiedNormal = normalize(normal + edgeFactor * _BumpScale * normal);

                float3 finalColor = lerp(blendedColor, baseColor.rgb * stepFactor, step(diffuseFalloff, _Threshold));
                
                if (diffuseFalloff > _Threshold && diffuseFalloff < 1.0)
                {
                    finalColor += outlineColor; 
                }

                finalColor = finalColor + ambientColor + _LightColor0;

                return float4(finalColor, 1.0);
            }
            ENDCG
        }
    }
}