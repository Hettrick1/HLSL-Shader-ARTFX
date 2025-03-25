Shader "Custom/S_Wave"
{
    Properties
    {
        _Color1("Color", Color) = (1,0,0,1)
        _Color2("Other Color", Color) = (1,0,0,1)
        _MainTex("noise Texture", 2D) = "white"{}
        _WaveDirection("Wind Direction", Vector) = (0, 0.1, 0, 0)
        _Speed("Big Wave Speed", float) = 1
        _Frequency("Big Wave Frequency", float) = 1
        _Amplitude("Big Wave Amplitude", float) = 1
        _Offset("Height Offset", float) = 0.6
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

            fixed4 _Color1;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            fixed4 _Color2;
            uniform float2 _WaveDirection;
            uniform float _Speed;
            uniform float _Frequency;
            uniform float _Amplitude;
            uniform float _Offset;

            struct vertexInput
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float4 texcoord: TEXCOORD0;
            };

            struct vertexOutput
            {
                float4 vertex : SV_POSITION;
                float4 texcoord: TEXCOORD0;
                float displacement : DISPLACEMENT;
            };

            float4 vertexAnimBigWave(float4 pos, float2 uv)
            {
                pos.y = pos.y + (sin((uv.x - _Time.y * _Speed) * _Frequency)/2 + _Offset) * _Amplitude;
                return pos;
            }

            vertexOutput vert (vertexInput v)
            {
                vertexOutput o;
                v.vertex = vertexAnimBigWave(v.vertex, v.texcoord.xy);
                v.texcoord.xy += _Time.x * _WaveDirection;
                float displacement = tex2Dlod(_MainTex, v.texcoord * _MainTex_ST);
                displacement *= v.vertex.y;
                o.displacement = displacement;
                o.vertex = UnityObjectToClipPos(v.vertex + (v.normal * displacement));
                o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
                return o;
            }

            fixed4 frag (vertexOutput i) : COLOR
            {
                float height = i.displacement;

                float4 color1 = height * _Color1;
                float4 color2 = (1 - height) * _Color2;
                
                return color1 + color2 + height;
            }
            ENDCG
        }
    }
}
