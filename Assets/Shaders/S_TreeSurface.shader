Shader "Custom/TreeSurface"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NoiseTex ("NoiseTex", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _BendFactor ("Bend factor", Range(0, 10)) = 1
        _Speed ("Bend speed", Range(0, 50)) = 10
        _BendOffset("Bend offset", Range (0, 10)) = 1.3
        _Direction ("Bend direction", vector) = (1.0, 1.0, 0.0, 0.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _NoiseTex;
        float _Speed;
        float3 _Direction;
        float _BendFactor;
        float _BendOffset;
        float4 _NoiseTex_ST;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv2_NoiseTex;
            float3 worldPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        float4 RotateAroundYInDegrees (float4 vertex, float degrees)
	    {
		    float alpha = degrees * UNITY_PI / 180.0;
		    float sina, cosa;
		    sincos(alpha, sina, cosa);
		    float2x2 m = float2x2(cosa, -sina, sina, cosa);
		    return float4(mul(m, vertex.xz), vertex.yw).xzyw;
	    }

        float4 RotateAroundXInDegrees(float4 vertex, float degrees)
        {
            float alpha = degrees * UNITY_PI / 180.0;
            float sina, cosa;
            sincos(alpha, sina, cosa);
            float2x2 m = float2x2(cosa, -sina, sina, cosa);
            return float4(vertex.x, mul(m, vertex.yz), vertex.w).xyzw;
        }
        float4 RotateAroundZInDegrees(float4 vertex, float degrees)
        {
            float alpha = degrees * UNITY_PI / 180.0;
            float sina, cosa;
            sincos(alpha, sina, cosa);
            float2x2 m = float2x2(cosa, -sina, sina, cosa);
            return float4(mul(m, vertex.xy), vertex.zw).xyzw;
        }

        float GetNoiseValue(float3 worldPos)
        {
            float2 uv = worldPos.xz;
            return tex2Dlod(_NoiseTex, float4(uv, 0, 0)).r;
        }

        void vert (inout appdata_full v)
        {
            float3 vertPos = v.vertex;
            float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

            float noiseSample = GetNoiseValue(_Time.x * _Speed) * _BendFactor / 5;
            noiseSample *= 2;
            noiseSample -= 0.5;
            float angle = noiseSample * vertPos.y;

            if(vertPos.y > _BendOffset){
                float4 rotZ = RotateAroundZInDegrees(v.vertex, angle  * _Direction.x);
                v.vertex = rotZ;
                float4 rotX = RotateAroundXInDegrees(v.vertex, angle * _Direction.y);
                v.vertex = rotX;
            }
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
    FallBack "Diffuse"
}
