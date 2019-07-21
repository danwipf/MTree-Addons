// Upgrade NOTE: upgraded instancing buffer 'MtreeAmplifyBark' to new syntax.

// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Mtree/AmplifyBark"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,0)
		_MainTex("Albedo", 2D) = "white" {}
		_BumpMap("Normal", 2D) = "bump" {}
		_BumpStrength("Normal Strength", Float) = 1
		[Toggle(_BASEDETAIL_ON)] _BaseDetail("Base Detail", Float) = 0
		_DetailColor("Detail Color", Color) = (1,1,1,0)
		_Detail("Detail", 2D) = "white" {}
		_DetailNormal("Detail Normal", 2D) = "bump" {}
		_Height("Height", Range( 0 , 1)) = 0
		_TextureInfluence("Texture Influence", Range( 0 , 1)) = 0.5
		_Smooth("Smooth", Range( 0.01 , 0.5)) = 0.02
		_Ao("AO strength", Range( 0 , 1)) = 0.6
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.1
		_WindStrength("Wind Strength", Float) = 0.1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma shader_feature _BASEDETAIL_ON
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			half2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		uniform half MtreeWindStrength;
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
		uniform half4 _DetailColor;
		uniform sampler2D _Detail;
		uniform float4 _Detail_ST;
		uniform half4 _Color;
		uniform half _Smoothness;
		uniform half _Ao;

		UNITY_INSTANCING_BUFFER_START(MtreeAmplifyBark)
			UNITY_DEFINE_INSTANCED_PROP(half, _WindStrength)
#define _WindStrength_arr MtreeAmplifyBark
		UNITY_INSTANCING_BUFFER_END(MtreeAmplifyBark)


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


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			half3 _WindDirection = half3(1,0,1);
			float3 temp_output_37_0_g1 = mul( unity_WorldToObject, half4( _WindDirection , 0.0 ) ).xyz;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float dotResult15_g1 = dot( ( mul( unity_ObjectToWorld, half4( ase_vertex3Pos , 0.0 ) ).xyz / float3( 50,50,50 ) ) , _WindDirection );
			half _WindStrength_Instance = UNITY_ACCESS_INSTANCED_PROP(_WindStrength_arr, _WindStrength);
			float temp_output_107_0_g1 = ( ( _WindStrength_Instance + MtreeWindStrength ) * 0.2 );
			float temp_output_29_0_g1 = ( ( sin( ( ( ( _Time.y * 0.5 ) + ( sin( ( ( _Time.y * 4.0 ) - dotResult15_g1 ) ) * 0.4 ) ) - ( v.color.r / 5.0 ) ) ) + 1.5 ) * temp_output_107_0_g1 * ( pow( v.color.r , 0.3 ) * 0.1 ) );
			float3 rotatedValue53_g1 = RotateAroundAxis( float3( 0,0,0 ), ase_vertex3Pos, normalize( cross( float3( 0,1,0 ) , temp_output_37_0_g1 ) ), temp_output_29_0_g1 );
			v.vertex.xyz = rotatedValue53_g1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			float2 uv_DetailNormal = i.uv_texcoord * _DetailNormal_ST.xy + _DetailNormal_ST.zw;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			half4 tex2DNode44 = tex2D( _MainTex, uv_MainTex );
			float4 break72 = tex2DNode44;
			float clampResult67 = clamp( ( ( ( i.vertexColor.r - _Height ) + ( ( ( break72.r + break72.g + break72.b ) - 0.5 ) * _TextureInfluence ) ) / _Smooth ) , 0.0 , 1.0 );
			float3 lerpResult82 = lerp( UnpackScaleNormal( tex2D( _DetailNormal, uv_DetailNormal ), _BumpStrength ) , UnpackScaleNormal( tex2D( _BumpMap, uv_BumpMap ), _BumpStrength ) , clampResult67);
			#ifdef _BASEDETAIL_ON
				float3 staticSwitch60 = lerpResult82;
			#else
				float3 staticSwitch60 = UnpackScaleNormal( tex2D( _BumpMap, uv_BumpMap ), _BumpStrength );
			#endif
			o.Normal = staticSwitch60;
			float2 uv_Detail = i.uv_texcoord * _Detail_ST.xy + _Detail_ST.zw;
			float4 lerpResult80 = lerp( ( _DetailColor * tex2D( _Detail, uv_Detail ) ) , ( tex2DNode44 * _Color ) , clampResult67);
			#ifdef _BASEDETAIL_ON
				float4 staticSwitch54 = lerpResult80;
			#else
				float4 staticSwitch54 = tex2DNode44;
			#endif
			o.Albedo = staticSwitch54.rgb;
			o.Smoothness = _Smoothness;
			float lerpResult47 = lerp( 1.0 , i.vertexColor.a , _Ao);
			o.Occlusion = lerpResult47;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "MtreeBarkInspector"
}
/*ASEBEGIN
Version=16600
204;92;1362;655;3012.254;1381.881;3.912467;True;True
Node;AmplifyShaderEditor.CommentaryNode;85;-1329.56,-1420.165;Float;False;1513.586;813.0795;Albedo;9;54;80;56;55;44;45;86;88;89;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;45;-1179.498,-917.6981;Float;True;Property;_MainTex;Albedo;1;0;Create;False;0;0;False;0;None;9e2bd545dcb51d645bc6ad55a98bf40f;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;44;-910.6936,-961.196;Float;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;76;-2840.497,-1206.127;Float;False;1251.466;754.8342;Bark Damage Blend;12;69;72;67;64;71;63;68;74;66;75;62;73;;1,1,1,1;0;0
Node;AmplifyShaderEditor.BreakToComponentsNode;72;-2756.926,-843.951;Float;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;73;-2469.455,-839.6368;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-2552.642,-599.4325;Half;False;Property;_Height;Height;8;0;Create;True;0;0;False;0;0;0.058;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;69;-2355.008,-1150.103;Float;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;62;-2440.118,-785.0497;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;75;-2533.27,-1032.846;Half;False;Property;_TextureInfluence;Texture Influence;9;0;Create;True;0;0;False;0;0.5;0.777;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;68;-2235.309,-722.0981;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-2176.937,-1051.547;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;84;-2061.768,-403.8276;Float;False;1548.867;573.6572;Normals;9;49;57;52;50;58;59;51;82;60;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;71;-2070.465,-711.1181;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-2354.555,-901.0359;Half;False;Property;_Smooth;Smooth;10;0;Create;True;0;0;False;0;0.02;0.075;0.01;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;57;-2011.767,-332.3268;Float;True;Property;_DetailNormal;Detail Normal;7;0;Create;True;0;0;False;0;None;d2dc7536aa6a547429a63578273e514b;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;49;-2005.581,-145.4024;Float;True;Property;_BumpMap;Normal;2;0;Create;False;0;0;False;0;None;d2dc7536aa6a547429a63578273e514b;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;55;-1155.683,-1205.104;Float;True;Property;_Detail;Detail;6;0;Create;True;0;0;False;0;None;874120e7f6d062442a131836cdfec782;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.ColorNode;88;-850.0541,-768.7626;Float;False;Property;_Color;Color;0;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;50;-1720.786,-60.17057;Float;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;86;-1112.167,-1408.434;Float;False;Property;_DetailColor;Detail Color;5;0;Create;True;0;0;False;0;1,1,1,0;0.6725702,0.7279412,0.3265028,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;64;-1890.252,-700.1354;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;56;-917.5314,-1201.632;Float;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;52;-1543.911,-154.1816;Half;False;Property;_BumpStrength;Normal Strength;3;0;Create;False;0;0;False;0;1;0.74;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;58;-1704.805,-353.8276;Float;True;Property;_TextureSample3;Texture Sample 3;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;5;-499.5341,379.7688;Half;False;InstancedProperty;_WindStrength;Wind Strength;14;0;Create;True;0;0;False;0;0.1;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;67;-1745.756,-926.3078;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-479.1616,-917.7403;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;59;-1311.86,-262.3304;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-494.6804,-1315.014;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;51;-1309.07,-89.26041;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;95;-509.558,541.0116;Half;False;Global;MtreeWindStrength;MtreeWindStrength;15;0;Create;True;0;0;False;0;0;6.72;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;80;-235.2422,-1059.704;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;82;-963.0834,-350.5527;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;94;-243.558,456.0115;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-1135.352,340.2948;Half;False;Property;_Ao;AO strength;11;0;Create;False;0;0;False;0;0.6;0.893;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;48;-1163.3,437.9648;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;47;-800.2986,333.6308;Float;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;60;-774.9012,-164.6306;Float;False;Property;_Keyword0;Keyword 0;13;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Reference;54;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;54;4.007927,-927.7547;Float;False;Property;_BaseDetail;Base Detail;4;0;Create;True;0;0;False;0;0;0;1;True;;Toggle;2;Key0;Key1;Create;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-130.6934,161.1174;Half;False;Property;_Smoothness;Smoothness;12;0;Create;True;0;0;False;0;0.1;0.108;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;97;-66.2908,311.5185;Float;False;MtreeWind;-1;;1;90cdcc9ecce991141bf9b10a98e8bbed;1,64,0;1;17;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;845.9057,-24.26468;Half;False;True;2;Half;MtreeBarkInspector;0;0;Standard;Mtree/AmplifyBark;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;44;0;45;0
WireConnection;72;0;44;0
WireConnection;73;0;72;0
WireConnection;73;1;72;1
WireConnection;73;2;72;2
WireConnection;69;0;73;0
WireConnection;68;0;62;1
WireConnection;68;1;66;0
WireConnection;74;0;69;0
WireConnection;74;1;75;0
WireConnection;71;0;68;0
WireConnection;71;1;74;0
WireConnection;50;0;49;0
WireConnection;64;0;71;0
WireConnection;64;1;63;0
WireConnection;56;0;55;0
WireConnection;58;0;57;0
WireConnection;67;0;64;0
WireConnection;89;0;44;0
WireConnection;89;1;88;0
WireConnection;59;0;58;0
WireConnection;59;1;52;0
WireConnection;87;0;86;0
WireConnection;87;1;56;0
WireConnection;51;0;50;0
WireConnection;51;1;52;0
WireConnection;80;0;87;0
WireConnection;80;1;89;0
WireConnection;80;2;67;0
WireConnection;82;0;59;0
WireConnection;82;1;51;0
WireConnection;82;2;67;0
WireConnection;94;0;5;0
WireConnection;94;1;95;0
WireConnection;47;1;48;4
WireConnection;47;2;46;0
WireConnection;60;1;51;0
WireConnection;60;0;82;0
WireConnection;54;1;44;0
WireConnection;54;0;80;0
WireConnection;97;17;94;0
WireConnection;0;0;54;0
WireConnection;0;1;60;0
WireConnection;0;4;53;0
WireConnection;0;5;47;0
WireConnection;0;11;97;0
ASEEND*/
//CHKSM=EE4870430DE2BBBF707AA7F3EE764FD8303D1D66