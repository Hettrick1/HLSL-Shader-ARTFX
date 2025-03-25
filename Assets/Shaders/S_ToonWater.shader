Shader "Custom/S_ToonWater"
{
    Properties
    {
        _NoiseTex("Noise Texture", 2D) = "white" {}
        _ShallowColor("Depth Color Shallow", Color) = (0.325, 0.807, 0.971, 0.725)
        _DeepColor("Depth Color Deep", Color) = (0.086, 0.407, 1, 0.749)
        _DepthMaxDistance("Depth Maximum Distance", Float) = 1
        _SurfaceNoiseCutoff("Surface Noise Cutoff", Range(0, 1)) = 0.777
        _FoamDistance("Foam Depth", float) = 1
    }
    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque" 
        }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            uniform float4 _ShallowColor;
            uniform float4 _DeepColor;
            uniform float _DepthMaxDistance;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float _SurfaceNoiseCutoff;
            float _FoamDistance;

            sampler2D _CameraDepthTexture;

            struct vertexInput
            {
                float4 vertex : POSITION;
                float4 texcoord: TEXCOORD0;
                float4 uv : TEXCOORD0;
            };

            struct vertexOutput
            {
                float4 vertex : SV_POSITION;
                float4 screenPosition : TEXCOORD2;
                float2 noiseUV : TEXCOORD0;
            };

            vertexOutput vert (vertexInput v)
            {
                vertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPosition = ComputeScreenPos(o.vertex);
                o.noiseUV.xy = (v.uv.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw);
                o.noiseUV = TRANSFORM_TEX(v.uv, _NoiseTex);
                return o;
            }

            fixed4 frag (vertexOutput i) : SV_Target
            {
                float4 noise = tex2D(_NoiseTex, i.noiseUV);
                float existingDepth01 = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPosition)).r;
                float existingDepthLinear = LinearEyeDepth(existingDepth01);
                float depthDifference = existingDepthLinear - i.screenPosition.w;

                float waterDepthDifference01 = saturate(depthDifference / _DepthMaxDistance);
                float4 waterColor = lerp(_ShallowColor, _DeepColor, waterDepthDifference01);

                float foamDepthDifference01 = 1 - _FoamDistance;

                float surfaceNoiseCutoff = foamDepthDifference01 * _SurfaceNoiseCutoff;
                float surfaceNoise = noise > surfaceNoiseCutoff  ? 1 : 0;
                return waterColor + surfaceNoise;
            }
            ENDCG
        }
    }
}
