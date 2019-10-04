// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Mtree/Bark 2.2"
{
	Properties
	{
		[Header(Albedo Texture)]_Color("Color", Color) = (1,1,1,0)
		_MainTex("Albedo", 2D) = "white" {}
		[Header(Normal Texture)]_BumpMap("Normal", 2D) = "bump" {}
		_BumpStrength("Normal Strength", Float) = 1
		[Header(Detail Settings)][Toggle(_BASEDETAIL_ON)] _BaseDetail("Base Detail", Float) = 0
		_DetailColor("Detail Color", Color) = (1,1,1,0)
		_Detail("Detail", 2D) = "white" {}
		_DetailNormal("Detail Normal", 2D) = "bump" {}
		_Height("Height", Range( 0 , 1)) = 0
		_TextureInfluence("Texture Influence", Range( 0 , 1)) = 0.5
		_Smooth("Smooth", Range( 0.01 , 0.5)) = 0.02
		[Header(Wind)]_WindStrength("Wind Strength", Float) = 0.1
		[Header(Other)]_Ao("AO strength", Range( 0 , 1)) = 0.6
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.1
		[Header(Translucency)]
		_Translucency("Strength", Range( 0 , 50)) = 1
		_TransNormalDistortion("Normal Distortion", Range( 0 , 1)) = 0.1
		_TransScattering("Scaterring Falloff", Range( 1 , 50)) = 2
		_TransDirect("Direct", Range( 0 , 1)) = 1
		_TransAmbient("Ambient", Range( 0 , 1)) = 0.2
		_TransShadow("Shadow", Range( 0 , 1)) = 0.9
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Off
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _BASEDETAIL_ON
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
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		struct SurfaceOutputStandardCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			half3 Translucency;
		};

		uniform float _WindStrength;
		uniform sampler2D _BumpMap;
		uniform float4 _BumpMap_ST;
		uniform half _BumpStrength;
		uniform sampler2D _DetailNormal;
		uniform float4 _DetailNormal_ST;
		uniform half _Height;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform half _TextureInfluence;
		uniform half _Smooth;
		uniform float4 _DetailColor;
		uniform sampler2D _Detail;
		uniform float4 _Detail_ST;
		uniform float4 _Color;
		uniform half _Smoothness;
		uniform half _Ao;
		uniform half _Translucency;
		uniform half _TransNormalDistortion;
		uniform half _TransScattering;
		uniform half _TransDirect;
		uniform half _TransAmbient;
		uniform half _TransShadow;


		float3 MyCustomExpression7_g22( float3 VertexPos , float3 VertexCol , float MtreeWindStrength , int IsLeaf )
		{
			float3 v_pos = VertexPos.xyz;
			float1 turbulence = sin(_Time * 40 - mul(UNITY_MATRIX_M, VertexPos).z / 15) * .5f;
			float3 dir = float3(1, 0, 0);
			float1 angle = MtreeWindStrength * (1 + sin(_Time * 2 + turbulence - v_pos.z / 50 - VertexCol.x / 20)) * sqrt(VertexCol.x) * .02f;
			float1 y = v_pos.y;
			float1 z = v_pos.z;
			float1 cos_a = cos(angle);
			float1 sin_a = sin(angle);
			float1 leaf_turbulence = sin(_Time * 200 * (.2+VertexCol.g) + VertexCol.g * 10 + turbulence + v_pos.z/2) * VertexCol.z * (angle + MtreeWindStrength /200);
			v_pos.y = y * cos_a - z * sin_a;
			if(IsLeaf == 1){
				v_pos.y += leaf_turbulence;
			}
			v_pos.z = y * sin_a + z * cos_a;
			return v_pos;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 VertexPos7_g22 = ase_vertex3Pos;
			float3 VertexCol7_g22 = v.color.rgb;
			float MtreeWindStrength7_g22 = _WindStrength;
			int IsLeaf7_g22 = 0;
			float3 localMyCustomExpression7_g22 = MyCustomExpression7_g22( VertexPos7_g22 , VertexCol7_g22 , MtreeWindStrength7_g22 , IsLeaf7_g22 );
			v.vertex.xyz = localMyCustomExpression7_g22;
		}

		inline half4 LightingStandardCustom(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi )
		{
			#if !DIRECTIONAL
			float3 lightAtten = gi.light.color;
			#else
			float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, _TransShadow );
			#endif
			half3 lightDir = gi.light.dir + s.Normal * _TransNormalDistortion;
			half transVdotL = pow( saturate( dot( viewDir, -lightDir ) ), _TransScattering );
			half3 translucency = lightAtten * (transVdotL * _TransDirect + gi.indirect.diffuse * _TransAmbient) * s.Translucency;
			half4 c = half4( s.Albedo * translucency * _Translucency, 0 );

			SurfaceOutputStandard r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Metallic = s.Metallic;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandard (r, viewDir, gi) + c;
		}

		inline void LightingStandardCustom_GI(SurfaceOutputStandardCustom s, UnityGIInput data, inout UnityGI gi )
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
			#else
				UNITY_GLOSSY_ENV_FROM_SURFACE( g, s, data );
				gi = UnityGlobalIllumination( data, s.Occlusion, s.Normal, g );
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardCustom o )
		{
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			float2 uv_DetailNormal = i.uv_texcoord * _DetailNormal_ST.xy + _DetailNormal_ST.zw;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode19_g20 = tex2D( _MainTex, uv_MainTex );
			float4 break3_g20 = tex2DNode19_g20;
			float clampResult30_g20 = clamp( ( ( ( i.vertexColor.r - _Height ) + ( ( ( break3_g20.r + break3_g20.g + break3_g20.b ) - 0.5 ) * _TextureInfluence ) ) / _Smooth ) , 0.0 , 1.0 );
			float3 lerpResult33_g20 = lerp( UnpackScaleNormal( tex2D( _DetailNormal, uv_DetailNormal ), _BumpStrength ) , UnpackScaleNormal( tex2D( _BumpMap, uv_BumpMap ), _BumpStrength ) , clampResult30_g20);
			#ifdef _BASEDETAIL_ON
				float3 staticSwitch34_g20 = lerpResult33_g20;
			#else
				float3 staticSwitch34_g20 = UnpackScaleNormal( tex2D( _BumpMap, uv_BumpMap ), _BumpStrength );
			#endif
			o.Normal = staticSwitch34_g20;
			float2 uv_Detail = i.uv_texcoord * _Detail_ST.xy + _Detail_ST.zw;
			float4 lerpResult16_g20 = lerp( ( _DetailColor * tex2D( _Detail, uv_Detail ) ) , ( tex2DNode19_g20 * _Color ) , clampResult30_g20);
			#ifdef _BASEDETAIL_ON
				float4 staticSwitch17_g20 = lerpResult16_g20;
			#else
				float4 staticSwitch17_g20 = tex2DNode19_g20;
			#endif
			float4 temp_output_44_0 = staticSwitch17_g20;
			o.Albedo = temp_output_44_0.rgb;
			o.Smoothness = _Smoothness;
			float lerpResult40 = lerp( 1.0 , i.vertexColor.a , _Ao);
			o.Occlusion = lerpResult40;
			float4 break38_g21 = temp_output_44_0;
			float3 appendResult41_g21 = (float3(break38_g21.x , break38_g21.y , break38_g21.z));
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 color31_g21 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
			float3 appendResult77_g21 = (float3(color31_g21.rgb));
			float temp_output_32_0_g21 = ( 1 * 2.0 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 normalizeResult11_g21 = normalize( ase_worldViewDir );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult12_g21 = normalize( ase_worldlightDir );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float dotResult23_g21 = dot( normalizeResult11_g21 , ( ( ( normalizeResult12_g21 + ase_worldNormal ) * 0.42 ) * -1.0 ) );
			float dotResult50_g21 = dot( ase_worldNormal , normalizeResult12_g21 );
			float4 color69_g21 = IsGammaSpace() ? float4(0.5,0.5,0.5,1) : float4(0.2140411,0.2140411,0.2140411,1);
			float3 appendResult71_g21 = (float3(color69_g21.rgb));
			float3 normalizeResult46_g21 = normalize( ( normalizeResult12_g21 + normalizeResult11_g21 ) );
			float dotResult54_g21 = dot( ase_worldNormal , normalizeResult46_g21 );
			float temp_output_61_0_g21 = ( pow( max( 0.0 , dotResult54_g21 ) , ( 0.0 * 128.0 ) ) * 0.0 );
			float4 appendResult75_g21 = (float4(( ( ( appendResult41_g21 * ase_lightColor.rgb ) * ( appendResult77_g21 * ( ( temp_output_32_0_g21 * ( pow( max( 0.0 , dotResult23_g21 ) , 0.5711765 ) * 0.96 ) ) * break38_g21.w ) ) ) + ( ( ( ( ( ( appendResult41_g21 * ase_lightColor.rgb ) * max( 0.0 , dotResult50_g21 ) ) + ase_lightColor.rgb ) * appendResult71_g21 ) * temp_output_61_0_g21 ) * temp_output_32_0_g21 ) ) , ( ( ( ase_lightColor.a * color69_g21.a ) * temp_output_61_0_g21 ) * 1 )));
			o.Translucency = appendResult75_g21.xyz;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustom keepalpha fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

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
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
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
				SurfaceOutputStandardCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardCustom, o )
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
Version=17000
0;23;1440;802;2360.99;1060.462;2.851252;True;True
Node;AmplifyShaderEditor.VertexColorNode;39;-1004.416,289.3006;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;38;-976.4683,191.6306;Half;False;Property;_Ao;AO strength;15;0;Create;False;0;0;False;1;Header(Other);0.6;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;44;-566.9995,-81.27278;Float;False;Albedo & Normal Bark;0;;20;13cb1a628350848cbb6959025f61f0d1;0;0;2;COLOR;0;FLOAT3;35
Node;AmplifyShaderEditor.RangedFloatNode;24;-663.9895,-363.5679;Float;False;Constant;_TransNormalDistortion;_TransNormalDistortion;11;1;[HideInInspector];Create;False;0;0;True;0;0.96;0.96;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-672.6059,-284.0517;Float;False;Constant;_Translucency;_Translucency;12;1;[HideInInspector];Create;False;0;0;False;0;0.5711765;0.83;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-662.2482,-202.3715;Float;False;Constant;_TransShadow;_TransShadow;11;1;[HideInInspector];Create;False;0;0;False;0;0.42;0.42;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-764.0663,94.59955;Half;False;Property;_Smoothness;Smoothness;16;0;Create;True;0;0;False;0;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;40;-641.4149,184.9666;Float;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;43;-496.5096,437.3972;Float;False;MTree Wind_2.1;13;;22;dbf2c0851f02249ca91c33b169d6b611;0;1;3;INT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;25;-294.6725,-325.0548;Float;False;Translucent;-1;;21;c0e629466385a4e74aff3d64b8a83f0a;0;6;87;FLOAT;0;False;88;FLOAT;0;False;86;FLOAT;0;False;37;FLOAT4;0,0,0,0;False;62;FLOAT;0;False;58;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Mtree/Bark 2.2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0;True;True;0;False;Opaque;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;17;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;40;1;39;4
WireConnection;40;2;38;0
WireConnection;25;87;24;0
WireConnection;25;88;23;0
WireConnection;25;86;20;0
WireConnection;25;37;44;0
WireConnection;0;0;44;0
WireConnection;0;1;44;35
WireConnection;0;4;41;0
WireConnection;0;5;40;0
WireConnection;0;7;25;0
WireConnection;0;11;43;0
ASEEND*/
//CHKSM=6B5A91FB759D69BA51B315C016CD386191CA1109