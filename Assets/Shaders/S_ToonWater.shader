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
        _WaveDirection("Direction", Vector) = (0, 0.1, 0, 0)
        _Speed("Big Wave Speed", float) = 1
        _Frequency("Big Wave Frequency", float) = 1
        _Amplitude("Big Wave Amplitude", float) = 1
        _Offset("Height Offset", float) = 0.6
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
            float2 _WaveDirection;

            float _Speed;
            float _Frequency;
            float _Amplitude;
            float _Offset;


            sampler2D _CameraDepthTexture;

            struct vertexInput
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float4 uv : TEXCOORD0;
            };

            struct vertexOutput
            {
                float4 vertex : SV_POSITION;
                float4 screenPosition : TEXCOORD2;
                float2 noiseUV : TEXCOORD0;
            };

            float4 vertexAnimBigWave(float4 pos, float2 uv)
            {
                pos.y = pos.y + (sin((uv.x - _Time.y * _Speed) * _Frequency)/2 + _Offset) * _Amplitude;
                return pos;
            }

            vertexOutput vert (vertexInput v)
            {
                vertexOutput o;
                v.uv.xy += _Time.x * _WaveDirection;
                v.vertex = vertexAnimBigWave(v.vertex, v.uv.xy);
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

                float foamDepthDifference01 = saturate(depthDifference / _FoamDistance);
                float surfaceNoiseCutoff = foamDepthDifference01 * _SurfaceNoiseCutoff;
                float surfaceNoise = noise > surfaceNoiseCutoff  ? 1 : 0;
                return waterColor + surfaceNoise;
            }
            ENDCG
        }
    }
}
