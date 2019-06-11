Shader "Mtree/Normal" {
	Properties{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "white" {}
		_Cutoff("Alpha Clip", Range(0,1)) = 0.4
	}
	SubShader{
		Tags{ "RenderType" = "Opaque" }
		Cull off
		CGPROGRAM

		#pragma target 3.0
		#pragma surface surf Standard



		struct Input {
			float2 uv_MainTex;
		};


		sampler2D _MainTex;
		sampler2D _BumpMap;
		half _Cutoff;

		void surf(Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            fixed4 n = tex2D(_BumpMap, IN.uv_MainTex);

			o.Albedo = n.rgb;
			o.Alpha = c.a;
			clip(c.a - _Cutoff);
		}


		ENDCG
	}
	FallBack "Diffuse"
}
