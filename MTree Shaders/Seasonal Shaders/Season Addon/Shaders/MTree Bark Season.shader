// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Mtree/Bark Season"
{
	Properties
	{
		_MainTex("Albedo", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpStrength("Normal Strength", Float) = 1
		_Hue("Hue", Range( -0.5 , 0.5)) = 0
		_Value("Value", Range( 0 , 3)) = 1
		_Saturation("Saturation", Range( 0 , 2)) = 1
		_ColorVariation("Color Variation", Range( 0 , 0.3)) = 0.15
		_Ao("AO strength", Range( 0 , 1)) = 0.6
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
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
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
		uniform half _Threshold;
		uniform sampler2D _SnowHeightmap;
		uniform half4 _SnowHeightmap_ST;
		uniform sampler2D _SnowTexture;
		uniform half4 _SnowTexture_ST;
		uniform sampler2D _MainTex;
		uniform half4 _MainTex_ST;
		uniform half _ColorVariation;
		uniform half _Hue;
		uniform half _Saturation;
		uniform half _Value;
		uniform half _Ao;


		half3 MTreeWindBark( half3 vertex , half3 color , half _WindStrength )
		{
			float3 v_pos = vertex.xyz;
			float1 turbulence = sin(_Time * 40 - mul(unity_ObjectToWorld, vertex).z / 15) * .5f;
			float1 angle = _WindStrength * (1 + sin(_Time * 2 + turbulence - v_pos.z / 50 - color.x / 20)) * sqrt(color.x) * .02f;
			float1 y = v_pos.y;
			float1 z = v_pos.z;
			float1 cos_a = cos(angle);
			float1 sin_a = sin(angle);
			v_pos.y = y * cos_a - z * sin_a;
			v_pos.z = y * sin_a + z * cos_a;
			return v_pos;
		}


		float SnowLerpValue25_g18( float diff , float3 wn , float _Threshold , out int intSwitch )
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

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			half3 vertex1_g23 = ase_vertex3Pos;
			half3 color1_g23 = v.color.rgb;
			half _WindStrength1_g23 = _WindStrength;
			half3 localMTreeWindBark1_g23 = MTreeWindBark( vertex1_g23 , color1_g23 , _WindStrength1_g23 );
			v.vertex.xyz = localMTreeWindBark1_g23;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_SnowNormal = i.uv_texcoord * _SnowNormal_ST.xy + _SnowNormal_ST.zw;
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			float2 uv_SnowHeightmap = i.uv_texcoord * _SnowHeightmap_ST.xy + _SnowHeightmap_ST.zw;
			float diff25_g18 = ( _Threshold - tex2D( _SnowHeightmap, uv_SnowHeightmap ).r );
			half3 ase_worldNormal = WorldNormalVector( i, half3( 0, 0, 1 ) );
			float3 normalizeResult19_g18 = normalize( ase_worldNormal );
			float3 wn25_g18 = normalizeResult19_g18;
			float _Threshold25_g18 = _Threshold;
			int intSwitch25_g18 = 0;
			float localSnowLerpValue25_g18 = SnowLerpValue25_g18( diff25_g18 , wn25_g18 , _Threshold25_g18 , intSwitch25_g18 );
			float4 lerpResult35_g18 = lerp( half4( UnpackScaleNormal( tex2D( _SnowNormal, uv_SnowNormal ), _BumpStrength ) , 0.0 ) , half4( UnpackScaleNormal( tex2D( _BumpMap, uv_BumpMap ), _BumpStrength ) , 0.0 ) , localSnowLerpValue25_g18);
			o.Normal = lerpResult35_g18.rgb;
			float2 uv_SnowTexture = i.uv_texcoord * _SnowTexture_ST.xy + _SnowTexture_ST.zw;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float3 hsvTorgb5_g12 = RGBToHSV( tex2D( _MainTex, uv_MainTex ).rgb );
			float3 hsvTorgb13_g12 = HSVToRGB( half3(( hsvTorgb5_g12 + ( ( i.vertexColor.g - 0.5 ) * _ColorVariation ) + _Hue ).x,( hsvTorgb5_g12.y * _Saturation ),( hsvTorgb5_g12.z * _Value )) );
			float lerpResult14_g12 = lerp( 1.0 , i.vertexColor.a , _Ao);
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult21_g12 = normalize( ( ase_worldPos - _WorldSpaceCameraPos ) );
			float dotResult23_g12 = dot( ase_worldlightDir , normalizeResult21_g12 );
			float4 lerpResult33_g18 = lerp( tex2D( _SnowTexture, uv_SnowTexture ) , half4( ( hsvTorgb13_g12 + ( hsvTorgb13_g12 * lerpResult14_g12 * pow( ( ( dotResult23_g12 + 1.0 ) / 2.0 ) , 5.0 ) ) ) , 0.0 ) , localSnowLerpValue25_g18);
			o.Albedo = lerpResult33_g18.rgb;
			float lerpResult34_g18 = lerp( 0.0 , 0.0 , localSnowLerpValue25_g18);
			o.Smoothness = lerpResult34_g18;
			o.Occlusion = lerpResult14_g12;
			o.Alpha = 1;
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
263;81;966;637;925.6195;-31.85594;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;1;-2113.694,69.33443;Float;False;914.6;395.6914;;4;9;5;4;2;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;3;-1789.28,-158.6486;Float;True;Property;_MainTex;Albedo;0;0;Create;False;0;0;False;0;None;None;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;2;-2063.694,123.6344;Float;True;Property;_BumpMap;Normal Map;1;0;Create;False;0;0;False;0;None;None;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;6;-1469.427,-160.8876;Float;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-1812.694,149.6345;Float;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;5;-1758.746,350.0257;Half;False;Property;_BumpStrength;Normal Strength;2;0;Create;False;0;0;False;0;1;1.28;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;9;-1463.094,119.3344;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;11;-1026.746,-156.2632;Float;False;MTree Color Correction;3;;12;6c5aafe48ab7578498d019eb4a859cc2;0;2;31;COLOR;0,0,0,0;False;30;FLOAT;0;False;3;FLOAT3;0;FLOAT;33;FLOAT;32
Node;AmplifyShaderEditor.RangedFloatNode;8;-904.9028,202.9033;Float;False;Property;_Smoothness;Smoothness;10;0;Create;True;0;0;False;0;0.1176471;0.476;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1092.939,339.5262;Float;False;Property;_WindStrength;Wind Strength;11;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;17;-579.385,93.5747;Float;False;Snow;12;;18;48f251407bf51694e8d02e851087b90d;0;4;26;COLOR;0,0,0,0;False;27;COLOR;0,0,0,0;False;29;FLOAT;0;False;28;FLOAT;0;False;4;COLOR;0;COLOR;41;FLOAT;43;FLOAT;42
Node;AmplifyShaderEditor.FunctionNode;23;-613.8769,336.9293;Float;False;MTree Wind Bark;-1;;23;72f93049a07299f40a9f062589409c91;0;1;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;222.9734,-73.16267;Half;False;True;2;Half;ASEMaterialInspector;0;0;Standard;Mtree/Bark Season;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;True;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;20;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;3;0
WireConnection;4;0;2;0
WireConnection;9;0;4;0
WireConnection;9;1;5;0
WireConnection;11;31;6;0
WireConnection;17;26;11;0
WireConnection;17;27;9;0
WireConnection;17;29;8;0
WireConnection;23;2;7;0
WireConnection;0;0;17;0
WireConnection;0;1;17;41
WireConnection;0;4;17;42
WireConnection;0;5;11;33
WireConnection;0;11;23;0
ASEEND*/
//CHKSM=9BE9299BC30B2AF921E3A4F94BD74D3389E2680D