Shader "examples/week 3/homework template"
{
    Properties 
    {
        // Hour properties
        _hour ("Hour", Float) = 0
        _HourRadius ("Hour Radius", Range(0, 1)) = 0.1
        _HourSpeed ("Hour Speed", Range(0, 10)) = 1
        _HourParabolaSharpness ("Hour Parabola Sharpness", Float) = 1.0
        _HourColor ("Hour Color", Color) = (1, 0, 0, 1) // Red

        // Minute properties
        _minute ("Minute", Float) = 0
        _MinuteRadius ("Minute Radius", Range(0, 1)) = 0.08
        _MinuteSpeed ("Minute Speed", Range(0, 10)) = 2
        _MinuteParabolaSharpness ("Minute Parabola Sharpness", Float) = 1.0
        _MinuteColor ("Minute Color", Color) = (0, 1, 0, 1) // Green

        // Second properties
        _second ("Second", Float) = 0
        _SecondRadius ("Second Radius", Range(0, 1)) = 0.06
        _SecondSpeed ("Second Speed", Range(0, 10)) = 3
        _SecondParabolaSharpness ("Second Parabola Sharpness", Float) = 1.0
        _SecondColor ("Second Color", Color) = (0, 0, 1, 1) // Blue

        // General properties
        _BackgroundColor ("Background Color", Color) = (0, 0, 0, 1)
        _CurveOffset ("Curve Offset (Y)", Float) = 0.5
        _CurveXOffset ("Curve Offset (X)", Float) = 0.5

        // Polar chart properties
        _PolarRangeStart ("Polar Range Start", Range(0, 1)) = 0
        _PolarRangeEnd ("Polar Range End", Range(0, 1)) = 1
        _PolarColor ("Polar Chart Color", Color) = (1, 1, 0, 1) // Yellow

        // Black rectangle properties
        _RectHeight ("Rectangle Height", Range(0, 0.5)) = 0.1
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float _hour, _minute, _second;
            float _HourRadius, _MinuteRadius, _SecondRadius;
            float _HourSpeed, _MinuteSpeed, _SecondSpeed;
            float _HourParabolaSharpness, _MinuteParabolaSharpness, _SecondParabolaSharpness;
            float4 _HourColor, _MinuteColor, _SecondColor;
            float4 _BackgroundColor;
            float _CurveOffset, _CurveXOffset;
            float _PolarRangeStart, _PolarRangeEnd;
            float4 _PolarColor;
            float _RectHeight;

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

            float4 renderCircle(float2 uv, float2 center, float radius, float speed, float parabolaSharpness, float4 color)
            {
                // Calculate the position based on time (controls horizontal movement)
                float xPos = lerp(-0.6, 0.6, frac(speed)) + _CurveXOffset;

                // Parabolic curve: y = -a * (x - h)^2 + k
                float yPos = -parabolaSharpness * (xPos * xPos) + center.y + _CurveOffset;

                // New movement based on parabola
                float2 movement = float2(xPos, yPos);

                // Calculate the distance from the center of the movement
                float dist = distance(uv, movement + center);

                // Calculate soft edge (blur)
                float edge = smoothstep(radius, radius - 0.005, dist); // 0.02 is the blur radius

                // Return the color with alpha based on the edge calculation
                return color * (edge);
            }

            float4 renderPolarChart(float2 uv)
            {
                float time = _Time.z;

                // Convert coordinates to polar
                float2 polarCoord = uv * 2 - 1;
                float polar = (atan2(polarCoord.y, polarCoord.x) / 6.28318530718) + 0.5;

                // Create polar-based hand rotations
                float rangeLength = _PolarRangeEnd - _PolarRangeStart;
                float hA = frac((polar + (_hour / 12) + 0.25 - _PolarRangeStart) / rangeLength);
                float mA = frac((polar + (_minute / 60) + 0.25 - _PolarRangeStart) / rangeLength);
                float sA = frac((polar + (_second / 60) + 0.25 - _PolarRangeStart) / rangeLength);

                // Combine the values by blending with different weights
                float3 color =   (sA * 1);

                // Ensure only a specific range is shown
                float inRange = step(_PolarRangeStart, polar) * step(polar, _PolarRangeEnd);

                // Return the custom polar chart color multiplied by the blended color
                return float4(_PolarColor.rgb * color * inRange, 1.0);
            }

            float4 renderBlackRectangle(float2 uv)
            {
                // Check if UV coordinate is in the lower portion of the screen
                if (uv.y < _RectHeight)
                {
                    // Return black color
                    return float4(0, 0, 0, 1);
                }

                // Return transparent for other areas
                return float4(0, 0, 0, 0);
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 uv = i.uv;

                // Screen center in UV space
                float2 center = float2(0.5, 0.5);

                // Render each circle: hour, minute, second
                float4 hourCircle = renderCircle(uv, center, _HourRadius, _hour * _HourSpeed, _HourParabolaSharpness, _HourColor);
                float4 minuteCircle = renderCircle(uv, center, _MinuteRadius, _minute * _MinuteSpeed, _MinuteParabolaSharpness, _MinuteColor);
                float4 secondCircle = renderCircle(uv, center, _SecondRadius, _second * _SecondSpeed, _SecondParabolaSharpness, _SecondColor);

                // Additively blend the three circles
                float4 finalColor = hourCircle + minuteCircle ;

                // Blend the polar chart into the final output
                float4 polarChart = renderPolarChart(uv);
                finalColor += polarChart;

                // Add the black rectangle at the bottom
                float4 blackRect = renderBlackRectangle(uv);
                finalColor = lerp(finalColor, blackRect, blackRect.a);

                // Ensure alpha is 1 for solid background
                finalColor.a = 1.0;

                return finalColor;
            }
            ENDCG
        }
    }
}
