Shader "Custom/S_Line"
{
    Properties
    {
        _Color("Color", Color) = (1,0,0,1)
        _MainTex("Main Texture", 2D) = "white"{}
        _Width("Line Width", float) = 0.3
        _Amount("Line Count", int) = 1
    }
    SubShader
    {
        Tags 
        { 
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
            "IgnoreProjector" = "True" 
        }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 _Color;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float _Width;
            uniform int _Amount;

            struct vertexInput
            {
                float4 vertex : POSITION;
                float4 texcoord: TEXCOORD0;
            };

            struct vertexOutput
            {
                float4 vertex : SV_POSITION;
                float4 texcoord: TEXCOORD0;
            };

            vertexOutput vert (vertexInput v)
            {
                vertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
                return o;
            }

            float drawLine(float2 uv)
            {
                float cycle = (1.0 / _Amount);
                if((uv.x + (0.5 - cycle + _Width / 2) / _Amount) % cycle > 0  && (uv.x + (0.5 - cycle + _Width / 2) / _Amount) % cycle < _Width)
                    {
                    return 1;
                    }
                return 0;
            }

            half4 frag(vertexOutput i): COLOR 
            {
                 float4 color = tex2D(_MainTex, i.texcoord) * _Color;
                 color.a = drawLine(i.texcoord);
                 return color;
            }
            ENDCG
        }
    }
}
