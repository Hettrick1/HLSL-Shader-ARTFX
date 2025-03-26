Shader "Custom/S_Tree"
{
    Properties
    {
        _Color("Color", Color) = (1,0,0,1)
        _MainTex("Main Texture", 2D) = "white"{}
    }
    SubShader
    {
        Tags 
        { 
            "Queue" = "Transparent"
            "RenderType"="Opaque" 
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

            fixed4 frag (vertexOutput i) : SV_Target
            {
                return tex2D(_MainTex, i.texcoord) * _Color;
            }
            ENDCG
        }
    }
}
