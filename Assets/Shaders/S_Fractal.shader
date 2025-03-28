Shader "Custom/S_Fractal"
{
    Properties
    {
        _Zoom ("Zoom", Float) = 1.0
        _OffsetX ("Offset X", Float) = 0.0
        _OffsetY ("Offset Y", Float) = 0.0
        _MaxIter ("Max Iterations", Int) = 100
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull off
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

            float _Zoom;
            float _OffsetX;
            float _OffsetY;
            int _MaxIter;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 c = (i.uv / _Zoom) + float2(_OffsetX, _OffsetY);
                float2 z = c;
                int iter = 0;

                for (int n = 0; n < _MaxIter; n++)
                {
                    float x = (z.x * z.x - z.y * z.y) + c.x;
                    float y = (2.0 * z.x * z.y) + c.y;
                    z = float2(x, y);

                    if (dot(z, z) > 4.0) break;
                    iter++;
                }

                float color = iter / (float)_MaxIter;
                return fixed4(color, color * 0.5, color * 0.8, 1.0);
            }
            ENDCG
        }
    }
}