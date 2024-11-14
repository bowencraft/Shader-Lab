Shader "Custom/AsciiChar"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Toggle] _EnableAscii ("Enable Ascii", float) = 1
        _Ascii ("Ascii Texture", 2D) = "white" {}
        _AsciiSplit ("Ascii Split", float) = 18
        _Strength ("Strength", Range(1, 100)) = 10
        _steps ("steps", Range(1, 16)) = 16
        _Recolor ("Recolor Reference", 2D) = "gray" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _Ascii;
            sampler2D _Recolor;

            float4 _MainTex_ST;
            float _EnableAscii;
            float _Strength;
            float _AsciiSplit;
            int _steps;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float u = i.uv.x;
                float v = i.uv.y;

                float width = 1 / _Strength;
                u = (1 / _Strength) * (int)(u / (1 / _Strength));
                v = (1 / _Strength) * (int)(v / (1 / _Strength));

                float4 color = tex2D(_MainTex, float2(u, v));
                float grey = 1 - dot(color.rgb, float3(0.299, 0.587, 0.114));

                grey = floor(grey * _steps) / _steps;

                float3 posterizedColor = tex2D(_Recolor, float2(1 - grey, 0.5)).rgb;

                if (_EnableAscii > 0.5)
                {
                    float u_offset = (i.uv.x - u) / width;
                    float v_offset = (i.uv.y - v) / width;

                    float g_index = round(grey * (_AsciiSplit - 1));
                    float ascii_offset = (1 / _AsciiSplit) * g_index;

                    float2 ascii_uv = float2(ascii_offset + u_offset / _AsciiSplit - 0.0001, v_offset);
                    float4 ascii_color = tex2D(_Ascii, ascii_uv);

                    return float4(ascii_color.rgb * posterizedColor, 1.0);
                }

                return float4(posterizedColor, 1.0);
            }
            ENDCG
        }
    }
}