Shader "Custom/S_Flag"
{
    Properties
    {
        _Color("Color", Color) = (1,0,0,1)
        _MainTex("Main Texture", 2D) = "white"{}
        _Speed("Speed", float) = 1
        _Frequency("Frequency", float) = 1
        _Amplitude("Amplitude", float) = 1
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
            uniform float _Speed;
            uniform float _Frequency;
            uniform float _Amplitude;

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

            
            float4 vertexAnimFlag(float4 pos, float2 uv)
            {
                pos.z = pos.z + uv.x * sin((uv.x - _Time.y * _Speed) * _Frequency) * _Amplitude;
                return pos;
            }

            vertexOutput vert (vertexInput v)
            {
                vertexOutput o;
                v.vertex = vertexAnimFlag(v.vertex, v.texcoord.xy);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
                return o;
            }

            fixed4 frag (vertexOutput i) : SV_Target
            {
                return tex2D(_MainTex, i.texcoord) * _Color;
            }
            ENDCG
        }
    }
}
