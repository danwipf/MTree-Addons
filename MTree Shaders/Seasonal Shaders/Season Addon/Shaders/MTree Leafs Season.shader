// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Mtree/Leaf Season"
{
	Properties
	{
		_MainTex("Winter", 2D) = "white" {}
		_BumpMap("Normal Winter", 2D) = "bump" {}
		_Texture1("Spring", 2D) = "white" {}
		_Texture3("Normal Spring", 2D) = "bump" {}
		_Texture0("Summer", 2D) = "white" {}
		_Texture4("Normal Summer", 2D) = "bump" {}
		_Texture2("Fall", 2D) = "white" {}
		_Texture5("Normal Fall", 2D) = "bump" {}
		_Season("Season", Range( 1 , 5)) = 1
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.1176471
		_BumpStrength("Normal Strength", Float) = 1
		_Hue("Hue", Range( -0.5 , 0.5)) = 0
		_Value("Value", Range( 0 , 3)) = 1
		_Saturation("Saturation", Range( 0 , 2)) = 1
		_ColorVariation("Color Variation", Range( 0 , 0.3)) = 0.15
		_Ao("AO strength", Range( 0 , 1)) = 0.6
		_Cutout("Cutout", Range( 0 , 1)) = 0.5
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_WindStrength("Wind Strength", Float) = 0
		_SnowTexture("SnowTexture", 2D) = "white" {}
		_SnowNormal("SnowNormalmap", 2D) = "bump" {}
		_SnowHeightmap("Snow Heightmap", 2D) = "white" {}
		_BumpStrength("Snow Normal Strength", Float) = 1
		_Threshold("SnowAmount", Range( 0 , 2)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" }
		Cull Off
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			half2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float4 vertexColor : COLOR;
			float3 worldPos;
		};

		uniform half _WindStrength;
		uniform sampler2D _SnowNormal;
		uniform half4 _SnowNormal_ST;
		uniform half _BumpStrength;
		uniform sampler2D _BumpMap;
		uniform half4 _BumpMap_ST;
		uniform sampler2D _Texture4;
		uniform half4 _Texture4_ST;
		uniform sampler2D _Texture3;
		uniform half4 _Texture3_ST;
		uniform sampler2D _Texture5;
		uniform half4 _Texture5_ST;
		uniform half _Season;
		uniform half _Threshold;
		uniform sampler2D _SnowHeightmap;
		uniform half4 _SnowHeightmap_ST;
		uniform sampler2D _SnowTexture;
		uniform half4 _SnowTexture_ST;
		uniform sampler2D _MainTex;
		uniform half4 _MainTex_ST;
		uniform sampler2D _Texture1;
		uniform half4 _Texture1_ST;
		uniform sampler2D _Texture0;
		uniform half4 _Texture0_ST;
		uniform sampler2D _Texture2;
		uniform half4 _Texture2_ST;
		uniform half _ColorVariation;
		uniform half _Hue;
		uniform half _Saturation;
		uniform half _Value;
		uniform half _Ao;
		uniform half _Smoothness;
		uniform half _Cutout;
		uniform float _Cutoff = 0.5;


		float3 MTreeWindLeaf1_g20( float3 vertex , float3 color , float _WindStrength )
		{
			float3 v_pos = vertex.xyz;
			float1 turbulence = sin(_Time * 40 - mul(unity_ObjectToWorld, vertex).z / 15) * .5f;
			float1 angle = _WindStrength * (1 + sin(_Time * 2 + turbulence - v_pos.z / 50 - color.x / 20)) * sqrt(color.x) * .02f;
			float1 y = v_pos.y;
			float1 z = v_pos.z;
			float1 cos_a = cos(angle);
			float1 sin_a = sin(angle);
			float1 leaf_turbulence = sin(_Time * 200 * (.2+color.g) + color.g * 10 + turbulence + v_pos.z/2) * color.z * (angle + _WindStrength /200);
			v_pos.y = y * cos_a - z * sin_a;
			v_pos.y += leaf_turbulence;
			v_pos.z = y * sin_a + z * cos_a;
			return v_pos;
		}


		float4 SeasonalLerp1_g17( float4 winter , float4 spring , float4 summer , float4 fall , float _Season )
		{
			fixed4 current;           
			if(_Season >= 1 && _Season < 2){
				float cl = lerp(0,1,_Season - 1);
				current = lerp(winter,spring,cl);
			}
			if(_Season >= 2 && _Season < 3){
				float cl = lerp(0,1,_Season - 2);
				current = lerp(spring,summer,cl);
			}
			if(_Season >= 3 && _Season < 4){
				float cl = lerp(0,1,_Season - 3);
				current = lerp(summer,fall,cl);
			}
			if(_Season >= 4 && _Season <= 5){
				float cl = lerp(0,1,_Season - 4);
				current = lerp(fall,winter,cl);
			}
			return current;
		}


		float SnowLerpValue25_g23( float diff , float3 wn , float _Threshold , out int intSwitch )
		{
			float lerpValue = 0;
			if (diff >= 0 && _Threshold != 0 && wn.y >= 0.1) {
				if (wn.y <= 0.6) {
					diff = diff - (1-((wn.y - 0.1) * 2));
					if (diff < 0)
						lerpValue = 0;
				}
				diff *= 4;
				if (diff > 0 && diff < 1) {
					
					if (_Threshold >= 0.5) {
						float val = 1 + (_Threshold - 0.5) * 2;
						lerpValue = diff*val*val;
						
					} else
						lerpValue = diff;
						
					if (lerpValue > 1)
						lerpValue = 1;
						
				}
				intSwitch = 0;
				
			}else{
				intSwitch = 1;
				lerpValue = 1;
			}
			return lerpValue;
		}


		half3 HSVToRGB( half3 c )
		{
			half4 K = half4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			half3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		float3 RGBToHSV(float3 c)
		{
			float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
			float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
			float d = q.x - min( q.w, q.y );
			float e = 1.0e-10;
			return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

		float4 SeasonalLerp1_g18( float4 winter , float4 spring , float4 summer , float4 fall , float _Season )
		{
			fixed4 current;           
			if(_Season >= 1 && _Season < 2){
				float cl = lerp(0,1,_Season - 1);
				current = lerp(winter,spring,cl);
			}
			if(_Season >= 2 && _Season < 3){
				float cl = lerp(0,1,_Season - 2);
				current = lerp(spring,summer,cl);
			}
			if(_Season >= 3 && _Season < 4){
				float cl = lerp(0,1,_Season - 3);
				current = lerp(summer,fall,cl);
			}
			if(_Season >= 4 && _Season <= 5){
				float cl = lerp(0,1,_Season - 4);
				current = lerp(fall,winter,cl);
			}
			return current;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 vertex1_g20 = ase_vertex3Pos;
			float3 color1_g20 = v.color.rgb;
			float _WindStrength1_g20 = _WindStrength;
			float3 localMTreeWindLeaf1_g20 = MTreeWindLeaf1_g20( vertex1_g20 , color1_g20 , _WindStrength1_g20 );
			v.vertex.xyz = localMTreeWindLeaf1_g20;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_SnowNormal = i.uv_texcoord * _SnowNormal_ST.xy + _SnowNormal_ST.zw;
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			float4 winter1_g17 = tex2D( _BumpMap, uv_BumpMap );
			float2 uv_Texture4 = i.uv_texcoord * _Texture4_ST.xy + _Texture4_ST.zw;
			float4 spring1_g17 = tex2D( _Texture4, uv_Texture4 );
			float2 uv_Texture3 = i.uv_texcoord * _Texture3_ST.xy + _Texture3_ST.zw;
			float4 summer1_g17 = tex2D( _Texture3, uv_Texture3 );
			float2 uv_Texture5 = i.uv_texcoord * _Texture5_ST.xy + _Texture5_ST.zw;
			float4 fall1_g17 = tex2D( _Texture5, uv_Texture5 );
			float _Season1_g17 = _Season;
			float4 localSeasonalLerp1_g17 = SeasonalLerp1_g17( winter1_g17 , spring1_g17 , summer1_g17 , fall1_g17 , _Season1_g17 );
			float4 break5_g17 = localSeasonalLerp1_g17;
			float4 appendResult6_g17 = (half4(break5_g17.x , break5_g17.y , break5_g17.z , 0.0));
			float2 uv_SnowHeightmap = i.uv_texcoord * _SnowHeightmap_ST.xy + _SnowHeightmap_ST.zw;
			float diff25_g23 = ( _Threshold - tex2D( _SnowHeightmap, uv_SnowHeightmap ).r );
			half3 ase_worldNormal = WorldNormalVector( i, half3( 0, 0, 1 ) );
			float3 normalizeResult19_g23 = normalize( ase_worldNormal );
			float3 wn25_g23 = normalizeResult19_g23;
			float _Threshold25_g23 = _Threshold;
			int intSwitch25_g23 = 0;
			float localSnowLerpValue25_g23 = SnowLerpValue25_g23( diff25_g23 , wn25_g23 , _Threshold25_g23 , intSwitch25_g23 );
			float4 lerpResult35_g23 = lerp( half4( UnpackScaleNormal( tex2D( _SnowNormal, uv_SnowNormal ), _BumpStrength ) , 0.0 ) , half4( UnpackScaleNormal( appendResult6_g17, _BumpStrength ) , 0.0 ) , localSnowLerpValue25_g23);
			o.Normal = lerpResult35_g23.rgb;
			float2 uv_SnowTexture = i.uv_texcoord * _SnowTexture_ST.xy + _SnowTexture_ST.zw;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 winter1_g18 = tex2D( _MainTex, uv_MainTex );
			float2 uv_Texture1 = i.uv_texcoord * _Texture1_ST.xy + _Texture1_ST.zw;
			float4 spring1_g18 = tex2D( _Texture1, uv_Texture1 );
			float2 uv_Texture0 = i.uv_texcoord * _Texture0_ST.xy + _Texture0_ST.zw;
			float4 summer1_g18 = tex2D( _Texture0, uv_Texture0 );
			float2 uv_Texture2 = i.uv_texcoord * _Texture2_ST.xy + _Texture2_ST.zw;
			float4 fall1_g18 = tex2D( _Texture2, uv_Texture2 );
			float _Season1_g18 = _Season;
			float4 localSeasonalLerp1_g18 = SeasonalLerp1_g18( winter1_g18 , spring1_g18 , summer1_g18 , fall1_g18 , _Season1_g18 );
			float4 break5_g18 = localSeasonalLerp1_g18;
			float4 appendResult6_g18 = (half4(break5_g18.x , break5_g18.y , break5_g18.z , 0.0));
			float3 hsvTorgb5_g19 = RGBToHSV( appendResult6_g18.rgb );
			float3 hsvTorgb13_g19 = HSVToRGB( half3(( hsvTorgb5_g19 + ( ( i.vertexColor.g - 0.5 ) * _ColorVariation ) + _Hue ).x,( hsvTorgb5_g19.y * _Saturation ),( hsvTorgb5_g19.z * _Value )) );
			float lerpResult14_g19 = lerp( 1.0 , i.vertexColor.a , _Ao);
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult21_g19 = normalize( ( ase_worldPos - _WorldSpaceCameraPos ) );
			float dotResult23_g19 = dot( ase_worldlightDir , normalizeResult21_g19 );
			float4 lerpResult33_g23 = lerp( tex2D( _SnowTexture, uv_SnowTexture ) , half4( ( hsvTorgb13_g19 + ( hsvTorgb13_g19 * lerpResult14_g19 * pow( ( ( dotResult23_g19 + 1.0 ) / 2.0 ) , 5.0 ) ) ) , 0.0 ) , localSnowLerpValue25_g23);
			o.Albedo = lerpResult33_g23.rgb;
			float lerpResult34_g23 = lerp( 0.0 , _Smoothness , localSnowLerpValue25_g23);
			o.Smoothness = lerpResult34_g23;
			o.Occlusion = lerpResult14_g19;
			o.Alpha = 1;
			clip( ( ( break5_g18.w - _Cutout ) + 0.5 ) - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows dithercrossfade vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				half4 color : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.vertexColor = IN.color;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16700
8;47;1432;762;1056.529;753.1414;2.183262;True;True
Node;AmplifyShaderEditor.CommentaryNode;52;-1269.794,-1176.406;Float;False;702.1204;926.2112;;8;50;51;47;46;49;48;31;30;Seasonal Textures;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;19;-1269.162,-142.9798;Float;False;727.1813;961.6958;;8;15;16;54;55;56;57;58;59;Seasonal Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;47;-1205.185,-670.6094;Float;True;Property;_Texture0;Summer;4;0;Create;False;0;0;False;0;None;ece7620c93d5f449dab40c90e86fbb11;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;49;-1205.186,-897.7703;Float;True;Property;_Texture1;Spring;2;0;Create;False;0;0;False;0;None;adc8141234fe0d240861fae4c0cb42c0;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;51;-1208.526,-480.195;Float;True;Property;_Texture2;Fall;6;0;Create;False;0;0;False;0;None;af24f528fe755a943885ba31e1196370;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;54;-1224.311,151.6895;Float;True;Property;_Texture3;Normal Spring;3;0;Create;False;0;0;False;0;None;6c128f470e70741498b476d08c0d8d87;False;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;15;-1219.162,-64.19012;Float;True;Property;_BumpMap;Normal Winter;1;0;Create;False;0;0;False;0;None;7e29cc5ed1d3b8a4e826d7a16bb9aa8e;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;58;-1218.378,580.0034;Float;True;Property;_Texture5;Normal Fall;7;0;Create;False;0;0;False;0;None;c4555830288c47c4ca5f2ecfe01f9e7d;False;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;56;-1222.008,365.8464;Float;True;Property;_Texture4;Normal Summer;5;0;Create;False;0;0;False;0;None;b002e549242e248268b0687fce1adf9c;False;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;30;-1219.794,-1124.167;Float;True;Property;_MainTex;Winter;0;0;Create;False;0;0;False;0;None;e4e88172f97ec884d92ecc52fc6d72bc;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;31;-899.9406,-1126.406;Float;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;46;-892.0137,-676.1893;Float;True;Property;_TextureSample2;Texture Sample 2;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;50;-888.6732,-482.434;Float;True;Property;_TextureSample4;Texture Sample 4;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;48;-896.615,-897.7089;Float;True;Property;_TextureSample3;Texture Sample 3;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;16;-968.1627,-62.67966;Float;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;57;-971.0086,367.3568;Float;True;Property;_TextureSample6;Texture Sample 6;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;55;-973.3117,153.1999;Float;True;Property;_TextureSample5;Texture Sample 5;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;59;-962.8631,581.5139;Float;True;Property;_TextureSample7;Texture Sample 7;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;18;-157.257,328.9249;Half;False;Property;_BumpStrength;Normal Strength;11;0;Create;False;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;71;-181.1854,159.4362;Float;False;MTree Seasonal Lerp;8;;17;0c893d94c338ce043afc13115a0006f8;0;4;3;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;9;FLOAT4;0,0,0,0;False;2;FLOAT4;0;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;70;-307.9651,-688.3612;Float;False;MTree Seasonal Lerp;8;;18;0c893d94c338ce043afc13115a0006f8;0;4;3;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;9;FLOAT4;0,0,0,0;False;2;FLOAT4;0;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;2;-161.4669,648.823;Float;False;Property;_WindStrength;Wind Strength;20;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;17;155.6757,183.0629;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;43;-15.23162,-688.9562;Float;False;MTree Color Correction;12;;19;6c5aafe48ab7578498d019eb4a859cc2;0;2;31;COLOR;0,0,0,0;False;30;FLOAT;0;False;3;FLOAT3;0;FLOAT;33;FLOAT;32
Node;AmplifyShaderEditor.RangedFloatNode;14;142.6269,337.0002;Float;False;Property;_Smoothness;Smoothness;10;0;Create;True;0;0;False;0;0.1176471;0.371;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;44;119.5132,652.2865;Float;False;MTree Wind Leaf;-1;;20;541c261dfbba8fb4e845aaeca46fad12;0;1;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;77;432.5839,-328.0837;Float;False;Snow;21;;23;48f251407bf51694e8d02e851087b90d;0;4;26;COLOR;0,0,0,0;False;27;COLOR;0,0,0,0;False;29;FLOAT;0;False;28;FLOAT;0;False;4;COLOR;0;COLOR;41;FLOAT;43;FLOAT;42
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;941.8487,-271.5921;Half;False;True;2;Half;ASEMaterialInspector;0;0;Standard;Mtree/Leaf Season;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;True;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;19;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;31;0;30;0
WireConnection;46;0;47;0
WireConnection;50;0;51;0
WireConnection;48;0;49;0
WireConnection;16;0;15;0
WireConnection;57;0;56;0
WireConnection;55;0;54;0
WireConnection;59;0;58;0
WireConnection;71;3;16;0
WireConnection;71;7;55;0
WireConnection;71;8;57;0
WireConnection;71;9;59;0
WireConnection;70;3;31;0
WireConnection;70;7;46;0
WireConnection;70;8;48;0
WireConnection;70;9;50;0
WireConnection;17;0;71;0
WireConnection;17;1;18;0
WireConnection;43;31;70;0
WireConnection;43;30;70;4
WireConnection;44;2;2;0
WireConnection;77;26;43;0
WireConnection;77;27;17;0
WireConnection;77;28;14;0
WireConnection;0;0;77;0
WireConnection;0;1;77;41
WireConnection;0;4;77;42
WireConnection;0;5;43;33
WireConnection;0;10;43;32
WireConnection;0;11;44;0
ASEEND*/
//CHKSM=6851CE6002193B83E6A1D4F15EF35E1DCA740B6D