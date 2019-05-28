// Upgrade NOTE: upgraded instancing buffer 'MtreeAmplifyLeaf' to new syntax.

// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Mtree/AmplifyLeaf"
{
	Properties
	{
		_MainTex("Albedo", 2D) = "white" {}
		_Hue("Hue", Range( -0.5 , 0.5)) = 0
		_Value("Value", Range( 0 , 3)) = 1
		_Saturation("Saturation", Range( 0 , 2)) = 1
		_ColorVariation("Color Variation", Range( 0 , 0.3)) = 0.15
		_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpStrength("Normal Strength", Float) = 1
		_Ao("AO strength", Range( 0 , 1)) = 0.6
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Cutout("Cutout", Range( 0 , 1)) = 0.5
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.1176471
		_WindStrength("Wind Strength", Float) = 0.1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows dithercrossfade vertex:vertexDataFunc 
		struct Input
		{
			half2 uv_texcoord;
			float4 vertexColor : COLOR;
			float3 worldPos;
		};

		uniform half MtreeWindStrength;
		uniform sampler2D _BumpMap;
		uniform half _BumpStrength;
		uniform sampler2D _MainTex;
		uniform half _ColorVariation;
		uniform half _Hue;
		uniform half _Saturation;
		uniform half _Value;
		uniform half _Ao;
		uniform half _Smoothness;
		uniform half _Cutout;
		uniform float _Cutoff = 0.5;

		UNITY_INSTANCING_BUFFER_START(MtreeAmplifyLeaf)
			UNITY_DEFINE_INSTANCED_PROP(half4, _BumpMap_ST)
#define _BumpMap_ST_arr MtreeAmplifyLeaf
			UNITY_DEFINE_INSTANCED_PROP(half4, _MainTex_ST)
#define _MainTex_ST_arr MtreeAmplifyLeaf
			UNITY_DEFINE_INSTANCED_PROP(half, _WindStrength)
#define _WindStrength_arr MtreeAmplifyLeaf
		UNITY_INSTANCING_BUFFER_END(MtreeAmplifyLeaf)


		float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
		{
			original -= center;
			float C = cos( angle );
			float S = sin( angle );
			float t = 1 - C;
			float m00 = t * u.x * u.x + C;
			float m01 = t * u.x * u.y - S * u.z;
			float m02 = t * u.x * u.z + S * u.y;
			float m10 = t * u.x * u.y + S * u.z;
			float m11 = t * u.y * u.y + C;
			float m12 = t * u.y * u.z - S * u.x;
			float m20 = t * u.x * u.z - S * u.y;
			float m21 = t * u.y * u.z + S * u.x;
			float m22 = t * u.z * u.z + C;
			float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
			return mul( finalMatrix, original ) + center;
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
			half3 _WindDirection = half3(1,0,1);
			float3 temp_output_37_0_g1 = mul( unity_WorldToObject, half4( _WindDirection , 0.0 ) ).xyz;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float dotResult15_g1 = dot( ( mul( unity_ObjectToWorld, half4( ase_vertex3Pos , 0.0 ) ).xyz / float3( 50,50,50 ) ) , _WindDirection );
			float _WindStrength_Instance = UNITY_ACCESS_INSTANCED_PROP(_WindStrength_arr, _WindStrength);
			float temp_output_107_0_g1 = ( ( MtreeWindStrength + _WindStrength_Instance ) * 0.2 );
			float temp_output_29_0_g1 = ( ( sin( ( ( ( _Time.y * 0.5 ) + ( sin( ( ( _Time.y * 4.0 ) - dotResult15_g1 ) ) * 0.4 ) ) - ( v.color.r / 5.0 ) ) ) + 1.5 ) * temp_output_107_0_g1 * ( pow( v.color.r , 0.3 ) * 0.1 ) );
			float3 rotatedValue53_g1 = RotateAroundAxis( float3( 0,0,0 ), ase_vertex3Pos, normalize( cross( float3( 0,1,0 ) , temp_output_37_0_g1 ) ), temp_output_29_0_g1 );
			float temp_output_108_0_g1 = ( v.color.b * 0.8 );
			float3 ase_vertexNormal = v.normal.xyz;
			float4 ase_vertexTangent = v.tangent;
			float temp_output_80_0_g1 = ( v.color.g * 3.14 );
			float temp_output_82_0_g1 = ( temp_output_108_0_g1 * -1.0 );
			float temp_output_106_0_g1 = ( temp_output_29_0_g1 + temp_output_107_0_g1 );
			v.vertex.xyz = ( rotatedValue53_g1 + ( temp_output_37_0_g1 * temp_output_29_0_g1 * pow( temp_output_108_0_g1 , 2.0 ) * 0.2 ) + ( ( ase_vertexNormal + ase_vertexTangent.xyz ) * ( sin( ( temp_output_80_0_g1 + ( _Time.y * 4.0 * ( temp_output_107_0_g1 + 1.0 ) ) + temp_output_82_0_g1 ) ) * 0.3 ) * temp_output_108_0_g1 * temp_output_106_0_g1 ) + ( cross( _WindDirection , ase_vertexNormal ) * ( cos( ( ( _Time.y * 15.0 ) + temp_output_82_0_g1 + temp_output_80_0_g1 ) ) * 0.04 ) * temp_output_108_0_g1 * temp_output_106_0_g1 ) );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 _BumpMap_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(_BumpMap_ST_arr, _BumpMap_ST);
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST_Instance.xy + _BumpMap_ST_Instance.zw;
			o.Normal = UnpackScaleNormal( tex2D( _BumpMap, uv_BumpMap ), _BumpStrength );
			float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(_MainTex_ST_arr, _MainTex_ST);
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
			half4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			float3 hsvTorgb19 = RGBToHSV( tex2DNode1.rgb );
			float3 hsvTorgb20 = HSVToRGB( half3(( hsvTorgb19 + ( ( i.vertexColor.g - 0.5 ) * _ColorVariation ) + _Hue ).x,( hsvTorgb19.y * _Saturation ),( hsvTorgb19.z * _Value )) );
			float lerpResult15 = lerp( 1.0 , i.vertexColor.a , _Ao);
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult34 = normalize( ( ase_worldPos - _WorldSpaceCameraPos ) );
			float dotResult29 = dot( ase_worldlightDir , normalizeResult34 );
			o.Albedo = ( hsvTorgb20 + ( hsvTorgb20 * lerpResult15 * pow( ( ( dotResult29 + 1.0 ) / 2.0 ) , 5.0 ) ) );
			o.Smoothness = _Smoothness;
			o.Occlusion = lerpResult15;
			o.Alpha = 1;
			clip( ( ( tex2DNode1.a - _Cutout ) + 0.5 ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16700
294;81;1078;637;173.5822;618.0128;1.608699;True;False
Node;AmplifyShaderEditor.CommentaryNode;142;-557.6992,851.4584;Float;False;1405.214;563.0626;Subsurface scattering;9;32;30;33;34;29;35;36;37;28;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;32;-507.6992,1235.521;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;30;-444.0939,1091.717;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;33;-200.7338,1155.323;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;34;-34.8066,1151.174;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;14;-217.5221,-413.3673;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;28;-464.5445,901.4584;Float;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;2;-613.0938,-171.6015;Float;True;Property;_MainTex;Albedo;0;0;Create;False;0;0;False;0;None;None;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;1;-293.2411,-173.8405;Float;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;24;140.921,-454.884;Float;False;Property;_ColorVariation;Color Variation;4;0;Create;True;0;0;False;0;0.15;0.104;0;0.3;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;29;184.2888,1031.593;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;214.6231,-573.071;Float;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;35;321.3739,1016.91;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;384.9785,-161.7666;Float;False;Property;_Value;Value;2;0;Create;True;0;0;False;0;1;1;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;19;448.7975,-405.3243;Float;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;422.911,-576.2756;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;289.5049,-761.3337;Half;False;Property;_Hue;Hue;1;0;Create;True;0;0;False;0;0;-0.064;-0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;271.8383,-861.4344;Float;False;Property;_Saturation;Saturation;3;0;Create;True;0;0;False;0;1;1.17;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;36;510.5968,995.6001;Float;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;712.1794,-464.3284;Float;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;773.8383,-683.4344;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-207.7548,-523.0773;Half;False;Property;_Ao;AO strength;8;0;Create;False;0;0;False;0;0.6;0.92;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;717.3875,-284.2332;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-285.7103,643.7152;Half;False;Property;_Cutout;Cutout;10;0;Create;True;0;0;False;0;0.5;0.202;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;20;870.8572,-379.9847;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;15;171.7295,-343.0081;Float;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;3;-610.2994,105.8287;Float;True;Property;_BumpMap;Normal Map;5;0;Create;False;0;0;False;0;None;None;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.PowerNode;37;667.5154,1111.948;Float;False;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;151;926.1409,-704.2393;Half;False;Global;MtreeWindStrength;MtreeWindStrength;13;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;962.5406,-557.8855;Float;False;InstancedProperty;_WindStrength;Wind Strength;12;0;Create;True;0;0;False;0;0.1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-337.2994,383.8287;Half;False;Property;_BumpStrength;Normal Strength;6;0;Create;False;0;0;False;0;1;1.28;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;10;156.5267,308.9601;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-359.2994,131.8288;Float;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;152;1272.574,-588.9614;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;1173.886,-184.948;Float;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;38;1380.159,-256.5844;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;154;1446.535,-579.4149;Float;False;MtreeWind;-1;;1;90cdcc9ecce991141bf9b10a98e8bbed;1,64,1;1;17;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;316.7759,301.0107;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;5;-9.699378,101.5287;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;25;904.6351,296.217;Float;False;Property;_Smoothness;Smoothness;11;0;Create;True;0;0;False;0;0.1176471;0.476;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;599.7479,117.9549;Half;False;Property;_transmission;transmission;7;0;Create;True;0;0;False;0;3;3.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1945.92,-200.3971;Half;False;True;2;Half;ASEMaterialInspector;0;0;Standard;Mtree/AmplifyLeaf;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;9;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;33;0;30;0
WireConnection;33;1;32;0
WireConnection;34;0;33;0
WireConnection;1;0;2;0
WireConnection;29;0;28;0
WireConnection;29;1;34;0
WireConnection;22;0;14;2
WireConnection;35;0;29;0
WireConnection;19;0;1;0
WireConnection;23;0;22;0
WireConnection;23;1;24;0
WireConnection;36;0;35;0
WireConnection;21;0;19;0
WireConnection;21;1;23;0
WireConnection;21;2;39;0
WireConnection;41;0;19;2
WireConnection;41;1;42;0
WireConnection;113;0;19;3
WireConnection;113;1;114;0
WireConnection;20;0;21;0
WireConnection;20;1;41;0
WireConnection;20;2;113;0
WireConnection;15;1;14;4
WireConnection;15;2;17;0
WireConnection;37;0;36;0
WireConnection;10;0;1;4
WireConnection;10;1;11;0
WireConnection;4;0;3;0
WireConnection;152;0;151;0
WireConnection;152;1;44;0
WireConnection;8;0;20;0
WireConnection;8;1;15;0
WireConnection;8;2;37;0
WireConnection;38;0;20;0
WireConnection;38;1;8;0
WireConnection;154;17;152;0
WireConnection;12;0;10;0
WireConnection;5;0;4;0
WireConnection;5;1;6;0
WireConnection;0;0;38;0
WireConnection;0;1;5;0
WireConnection;0;4;25;0
WireConnection;0;5;15;0
WireConnection;0;10;12;0
WireConnection;0;11;154;0
ASEEND*/
//CHKSM=DEF9DEBD6DD56860631CA63E56B20F221467A2F9