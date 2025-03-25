Shader "Custom/S_Splash"
{
    Properties
    {
        _Color1("Color", Color) = (1,0,0,1)
        _Color2("Other Color", Color) = (1,0,0,1)
        _MainTex("noise Texture", 2D) = "white"{}
        _WaveDirection("Direction", Vector) = (0, 0.1, 0, 0)
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
            };

            vertexOutput vert (vertexInput v)
            {
                vertexOutput o;
                v.texcoord.xy += _Time.x * _WaveDirection;
                float displacement = tex2Dlod(_MainTex, v.texcoord * _MainTex_ST);
                o.vertex = UnityObjectToClipPos(v.vertex + (v.normal * displacement));
                o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
                return o;
            }

            fixed4 frag (vertexOutput i) : COLOR
            {
                float4 noise = tex2D(_MainTex, i.texcoord);
                float4 color1 = noise * _Color1;
                float4 color2 = (1 - noise) * _Color2;

                return color1 + color2;
            }
            ENDCG
        }
    }
}
