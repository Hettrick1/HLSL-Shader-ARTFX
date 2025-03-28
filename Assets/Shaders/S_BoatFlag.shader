Shader "Custom/S_BoatFlag"
{
    Properties
    {
        _Color("Color", Color) = (1,0,0,1)
        _MainTex("Albedo (RGB)", 2D) = "white"{}
        _Glossiness ("Smoothness", Range(0,1)) = 0.0
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Speed("Speed", float) = 1
        _Frequency("Frequency", float) = 1
        _Amplitude("Amplitude", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow

        #pragma target 3.0

        uniform sampler2D _MainTex;
        uniform float _Speed;
        uniform float _Frequency;
        uniform float _Amplitude;

        struct Input
        {
        float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)
            
        float4 vertexAnimFlag(float4 pos, float2 uv)
        {
            if(pos.z < -0.2){
            pos.x = pos.x + (pos.x - 0.3) * sin((pos.x - 0.3 - _Time.y * _Speed) * _Frequency) * _Amplitude;
            }
            return pos;
        }

        void vert (inout appdata_full v)
        {
            v.vertex = vertexAnimFlag(v.vertex, v.texcoord.xy);
            //v.vertex = UnityObjectToClipPos(v.vertex);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
        fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
        o.Albedo = c.rgb;
        o.Metallic = _Metallic;
        o.Smoothness = _Glossiness;
        o.Alpha = c.a;
        }
        ENDCG
    }
}
