Shader "Unlit/HealthBar"
{
    Properties
    {
        _ColorBackground ("ColorBack", Color) = (0,0,0,1)
        _ColorFullHp ("ColorFullHP", Color) = (0,1,0,1)
        _ColorLowHp ("ColorLowHp", Color) = (1,0,0,1)
        _Lerp ("lerp", Range(0,1)) = 1
        _BorderSize ("borderSize", Range(0,.5)) = .1
        _HealthBarTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
//            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"


            float4 _ColorBackground;
            float4 _ColorFullHp;
            float4 _ColorLowHp;
            float _Lerp;
            float _BorderSize;
            sampler2D _HealthBarTex;

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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // float InverseLerp(float a, float b, float v)
            // {
            //     return (v - a) / (b - a);
            // }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 coords = i.uv;
                coords.x *= 8;
                float2 pointOnLineSeg = float2(clamp(coords.x, 0.5, 7.5), .5);
                float sdf = distance(coords, pointOnLineSeg)*2-1;
                clip(-sdf);

                float borderSDF = sdf + _BorderSize;
                float pd = fwidth(borderSDF);
                float borderMask = 1 - saturate(borderSDF / pd);
                
                float3 health = tex2D(_HealthBarTex, float2(_Lerp, i.uv.y));
                if (_Lerp < .2)
                    health *= cos(_Time.y * 10) * .2 + 1;
                return lerp(_ColorBackground, float4(health * borderMask, 1), i.uv.x < _Lerp);
                
            }
            ENDCG
        }
    }
}