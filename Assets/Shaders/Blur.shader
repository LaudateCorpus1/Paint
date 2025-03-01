﻿Shader "Paint/Blur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
	    [NoScaleOffset] _DiffusionTex ("Diffusion Texture", 2D) = "grey" {}
        _Radius("Radius", Range(1,10)) = 4
	    _Diffusion ("Diffusion", Range(0, 1)) = 0.5
        _DiffusionScale ("Diffusion Scale", Vector) = (1, 1, 1, 1)
    }
    
    CGINCLUDE
        #include "UnityCG.cginc"
        #pragma vertex vert

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
		float _Radius;
		float2 _MainTex_TexelSize;
        sampler2D _DiffusionTex;
        float _Diffusion;
        float2 _DiffusionScale;

        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            return o;
        }

        float4 gaussianBlur(float2 uv, float2 direction)
        {
			float4 sum = 0;
			const float2 blurOffset = _Radius * _MainTex_TexelSize * direction; 
		    		    
			//apply blurring, using a 9-tap filter with predefined gaussian weights
			sum += tex2D(_MainTex, uv - 4.0 * blurOffset) * 0.0162162162;
			sum += tex2D(_MainTex, uv - 3.0 * blurOffset) * 0.0540540541;
			sum += tex2D(_MainTex, uv - 2.0 * blurOffset) * 0.1216216216;
			sum += tex2D(_MainTex, uv - 1.0 * blurOffset) * 0.1945945946;
        	
			sum += tex2D(_MainTex, uv) * 0.2270270270;
			
			sum += tex2D(_MainTex, uv + 1.0 * blurOffset) * 0.1945945946;
			sum += tex2D(_MainTex, uv + 2.0 * blurOffset) * 0.1216216216;
			sum += tex2D(_MainTex, uv + 3.0 * blurOffset) * 0.0540540541;
			sum += tex2D(_MainTex, uv + 4.0 * blurOffset) * 0.0162162162;

			return sum;
        }
    ENDCG
    
    SubShader
    {
        Lighting Off
        Blend One Zero
        Cull Off
        ZWrite Off
        ZTest Always

        // Horizontal
        Pass
        {
            CGPROGRAM
            #pragma fragment frag
            
            float4 frag (v2f i) : SV_Target
            {
            	float2 diffusionUvs = i.uv + float2(1, 0) * _Diffusion * (tex2D(_DiffusionTex, i.uv * _DiffusionScale) - 0.5);
            	return gaussianBlur(diffusionUvs, float2(1, 0));
            }
            
            ENDCG
        }

        // Vertical
        Pass
        {
            CGPROGRAM
            #pragma fragment frag
            
            float4 frag (v2f i) : SV_Target
            {
            	float2 diffusionUvs = i.uv + float2(0, 1) * _Diffusion * (tex2D(_DiffusionTex, i.uv * _DiffusionScale) - 0.5);
            	return gaussianBlur(diffusionUvs, float2(0, 1));
            }
            
            ENDCG
        }
    }
}
