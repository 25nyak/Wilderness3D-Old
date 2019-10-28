// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SNB_Nature/SNB_Foliage"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_EmissionRMetallicGSmoothnessB("Emission (R), Metallic (G), Smoothness (B)", 2D) = "black" {}
		_Shininess("Shininess", Range( 0.01 , 1)) = 0.1
		_Specularity("Specularity", Range( 0 , 3)) = 1.5
		[Normal]_NormalMap("Normal Map", 2D) = "bump" {}
		_Cutoff( "Mask Clip Value", Float ) = 0.75
		_NormalStrength("Normal Strength", Float) = 1
		_EmissionStrength("Emission Strength", Float) = 0
		_TranslucencyTint("Translucency Tint", Color) = (1,0.9937924,0.3820755,0)
		_TranslucencyForce("Translucency Force", Float) = 0.4
		_DirectionalShadows("Directional Shadows", Range( 0 , 1)) = 0.2
		_PointLightTranslucency("Point Light Translucency", Range( 0 , 10)) = 1
		_WindFoliageAmplitude("Wind Foliage Amplitude", Range( 0 , 1)) = 0
		_WindFoliageSpeed("Wind Foliage Speed", Range( 0 , 1)) = 0
		_WindTrunkAmplitude("Wind Trunk Amplitude", Range( 0 , 1)) = 0
		_WindTrunkSpeed("Wind Trunk Speed", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "DisableBatching" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityStandardUtils.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile _ LOD_FADE_CROSSFADE
		#pragma instancing_options procedural:setup
		#pragma multi_compile GPU_FRUSTUM_ON__
		#include "VS_indirect.cginc"
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
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _WindTrunkSpeed;
		uniform float _WindTrunkAmplitude;
		uniform float _WindFoliageSpeed;
		uniform float _WindFoliageAmplitude;
		uniform sampler2D _EmissionRMetallicGSmoothnessB;
		uniform float4 _EmissionRMetallicGSmoothnessB_ST;
		uniform float _EmissionStrength;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _Specularity;
		uniform float _NormalStrength;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _Shininess;
		uniform float _DirectionalShadows;
		uniform float _PointLightTranslucency;
		uniform float4 _TranslucencyTint;
		uniform float _TranslucencyForce;
		uniform float _Cutoff = 0.75;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float temp_output_130_0 = ( _Time.y * ( 2.0 * _WindTrunkSpeed ) );
			float4 appendResult141 = (float4(( ( sin( temp_output_130_0 ) * _WindTrunkAmplitude ) * v.color.b ) , 0.0 , ( v.color.b * ( ( _WindTrunkAmplitude * 0.5 ) * cos( temp_output_130_0 ) ) ) , 0.0));
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float4 appendResult149 = (float4(ase_worldPos.x , ase_worldPos.y , ase_worldPos.z , 0.0));
			float2 panner93 = ( ( _Time.y * _WindFoliageSpeed ) * float2( 2,2 ) + appendResult149.xy);
			float simplePerlin2D101 = snoise( panner93 );
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( appendResult141 + float4( ( simplePerlin2D101 * _WindFoliageAmplitude * ase_vertexNormal * v.color.r ) , 0.0 ) ).rgb;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode36 = tex2D( _MainTex, uv_MainTex );
			float2 uv_EmissionRMetallicGSmoothnessB = i.uv_texcoord * _EmissionRMetallicGSmoothnessB_ST.xy + _EmissionRMetallicGSmoothnessB_ST.zw;
			float4 tex2DNode106 = tex2D( _EmissionRMetallicGSmoothnessB, uv_EmissionRMetallicGSmoothnessB );
			float4 temp_cast_1 = (( tex2DNode106.b * _Specularity )).xxxx;
			float4 temp_output_43_0_g1 = temp_cast_1;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult4_g2 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 normalizeResult64_g1 = normalize( (WorldNormalVector( i , UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalStrength ) )) );
			float dotResult19_g1 = dot( normalizeResult4_g2 , normalizeResult64_g1 );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 temp_output_40_0_g1 = ( ase_lightColor.rgb * ase_lightAtten );
			float dotResult14_g1 = dot( normalizeResult64_g1 , ase_worldlightDir );
			UnityGI gi34_g1 = gi;
			float3 diffNorm34_g1 = normalizeResult64_g1;
			gi34_g1 = UnityGI_Base( data, 1, diffNorm34_g1 );
			float3 indirectDiffuse34_g1 = gi34_g1.indirect.diffuse + diffNorm34_g1 * 0.0001;
			float4 temp_output_42_0_g1 = tex2DNode36;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float dotResult4 = dot( ase_worldViewDir , -( ase_worldlightDir + ( ase_worldNormal * 0.5 ) ) );
			float dotResult46 = dot( pow( dotResult4 , 1.0 ) , 1.0 );
			float temp_output_39_0 = saturate( dotResult46 );
			float isPointLight52 = _WorldSpaceLightPos0.w;
			c.rgb = ( float4( ( ( (temp_output_43_0_g1).rgb * (temp_output_43_0_g1).a * pow( max( dotResult19_g1 , 0.0 ) , ( _Shininess * 128.0 ) ) * temp_output_40_0_g1 ) + ( ( ( temp_output_40_0_g1 * max( dotResult14_g1 , 0.0 ) ) + indirectDiffuse34_g1 ) * (temp_output_42_0_g1).rgb ) ) , 0.0 ) + ( ( ( ( temp_output_39_0 * saturate( ( ase_lightAtten + ( 1.0 - _DirectionalShadows ) ) ) * ( 1.0 - isPointLight52 ) ) + ( temp_output_39_0 * _PointLightTranslucency * isPointLight52 * ase_lightAtten ) ) * 1.0 ) * ( tex2DNode36 * _TranslucencyTint * ase_lightColor * _TranslucencyForce ) ) ).rgb;
			c.a = 1;
			clip( tex2DNode36.a - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
			float2 uv_EmissionRMetallicGSmoothnessB = i.uv_texcoord * _EmissionRMetallicGSmoothnessB_ST.xy + _EmissionRMetallicGSmoothnessB_ST.zw;
			float4 tex2DNode106 = tex2D( _EmissionRMetallicGSmoothnessB, uv_EmissionRMetallicGSmoothnessB );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode36 = tex2D( _MainTex, uv_MainTex );
			o.Emission = ( tex2DNode106.r * _EmissionStrength * tex2DNode36 ).rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows dithercrossfade vertex:vertexDataFunc 

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
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
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
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
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
Version=16100
7;1109;1906;1004;5303.216;1744.461;3.6868;True;True
Node;AmplifyShaderEditor.CommentaryNode;31;-4028.75,-44.69436;Float;False;925.5469;667.5338;Based on Edward del Villar free tutorial;8;3;14;13;12;11;2;1;4;Translucency Base;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;11;-3989.278,338.8313;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;12;-3993.522,513.4276;Float;False;Constant;_TranslucencyModifier;Translucency Modifier;8;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-3675.907,425.8846;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;2;-3990.476,180.6532;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-3514.366,280.9351;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;1;-3985.641,4.804679;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;3;-3388.215,290.2666;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;67;-2137.112,-214.0102;Float;False;607.4456;256.4624;Outputs 0 for Point, 1 for Dir;2;52;51;Is Point Light ?;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;69;-2146.685,116.3443;Float;False;991.063;415.0306;Adjustable Light Attenuation (directional light shadow tweaking);8;56;53;58;57;60;59;55;54;Translucency Directional Lights (shadow control);1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;84;-2964.328,29.59824;Float;False;718.8501;473.0243;Useful tweakings for round objects with spherical normals;5;39;46;45;44;43;Translucency Power;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-2098.592,248.5341;Float;False;Property;_DirectionalShadows;Directional Shadows;13;0;Create;True;0;0;False;0;0.2;0.324;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-2908.452,344.5844;Float;False;Constant;_TranslucencyPower;Translucency Power;9;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;144;-2741.2,967.8284;Float;False;1821.23;666.407;Vertex offset using Blue Vertex Color channel;14;140;141;137;135;134;136;138;139;133;130;143;131;129;148;Wind Trunk;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;4;-3272.991,56.71107;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;51;-2064.294,-105.6563;Float;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightAttenuation;53;-1918.952,146.4021;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;45;-2788.68,197.6838;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-2732.779,348.184;Float;False;Constant;_TranslucencyScale;Translucency Scale;11;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;131;-2752.534,1253.118;Float;False;Property;_WindTrunkSpeed;Wind Trunk Speed;18;0;Create;True;0;0;False;0;0;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;55;-1715.462,283.8927;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-1788.118,-97.91716;Float;False;isPointLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;66;-2154.749,614.1623;Float;False;748.0724;269.9816;Light attenuation required for Point Lights;4;64;63;62;61;Translucency Point Lights;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;-2465.337,1233.448;Float;False;2;2;0;FLOAT;2;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;102;-2736.908,1722.336;Float;False;1715.196;801.9376;Vertex offset using Red Vertex Color channel base on panning noise;11;97;149;85;99;132;101;98;93;95;94;96;Wind Foliage;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;129;-2650.948,1040.889;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-2003.671,414.1907;Float;False;52;isPointLight;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;46;-2611.878,198.9837;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;54;-1551.007,155.7763;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;39;-2477.232,204.8831;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;62;-2112.337,646.4864;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;-2128.667,775.3057;Float;False;52;isPointLight;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;85;-2688.708,1877.548;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;96;-2624.162,2292.17;Float;False;Property;_WindFoliageSpeed;Wind Foliage Speed;16;0;Create;True;0;0;False;0;0;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-2187.593,1232.33;Float;False;Property;_WindTrunkAmplitude;Wind Trunk Amplitude;17;0;Create;True;0;0;False;0;0;0.06;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;94;-2656.373,2122.75;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-2133.11,704.5453;Float;False;Property;_PointLightTranslucency;Point Light Translucency;14;0;Create;True;0;0;False;0;1;3;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-2310.304,1109.096;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;59;-1767.081,419.5862;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;57;-1394.274,147.6729;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-1319.712,375.1357;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-1921.291,1277.47;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;147;-1146.565,-187.7297;Float;False;675.6133;476.7519;;4;82;47;81;83;Translucency Control;1,1,1,1;0;0
Node;AmplifyShaderEditor.SinOpNode;133;-2021.105,1103.079;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-2317.532,2151.384;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;149;-2404.188,1890.61;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-1658.749,704.5461;Float;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;140;-2137.852,1457.162;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;146;-2117.948,-977.7754;Float;False;1272.888;652.4158;;8;104;107;106;36;105;108;163;164;Base Textures;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;36;-1824.937,-545.4274;Float;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;False;0;None;fcbd578e80a32e8469fe6fecd607d8aa;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-1057.286,389.316;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;93;-2052.715,1902.058;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;2,2;False;1;FLOAT;0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;163;-1456.925,-489.9608;Float;False;Property;_Specularity;Specularity;6;0;Create;True;0;0;False;0;1.5;1.5;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;136;-1676.265,1199.925;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;138;-1774.092,1446.277;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;47;-1103.474,-167.1122;Float;False;Property;_TranslucencyTint;Translucency Tint;11;0;Create;True;0;0;False;0;1,0.9937924,0.3820755,0;1,0.9640312,0.1839599,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;83;-1103.184,211.539;Float;False;Property;_TranslucencyForce;Translucency Force;12;0;Create;True;0;0;False;0;0.4;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;-1840.604,1074.578;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;81;-1097.365,14.19401;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;105;-2044.889,-869.4987;Float;False;Property;_NormalStrength;Normal Strength;9;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;106;-1834.936,-750.888;Float;True;Property;_EmissionRMetallicGSmoothnessB;Emission (R), Metallic (G), Smoothness (B);1;0;Create;True;0;0;False;0;None;b40e4f8e896e21344a3d5ca84d541ca5;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-889.7081,386.2962;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;97;-1659.045,2187.266;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;164;-1127.313,-512.7728;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;98;-1658.111,2094.45;Float;False;Property;_WindFoliageAmplitude;Wind Foliage Amplitude;15;0;Create;True;0;0;False;0;0;0.05;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;101;-1632.069,1838.173;Float;True;Simplex2D;1;0;FLOAT2;1,1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;132;-1649.823,2350.62;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;-1446.229,1433.917;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-621.9359,-64.91644;Float;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;104;-1830.615,-929.0303;Float;True;Property;_NormalMap;Normal Map;7;1;[Normal];Create;True;0;0;False;0;None;fc84c738c0737df418cb63cacdcb9f84;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;-1399.146,1088.823;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-1437.427,-667.9239;Float;False;Property;_EmissionStrength;Emission Strength;10;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;150;-364.4373,-548.6221;Float;False;Blinn-Phong Light;2;;1;cf814dba44d007a4e958d2ddd5813da6;0;3;42;COLOR;0,0,0,0;False;52;FLOAT3;0,0,0;False;43;COLOR;0,0,0,0;False;2;FLOAT3;0;FLOAT;57
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-1177.592,2071.092;Float;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;141;-1099.605,1343.745;Float;False;COLOR;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-334.8125,388.5482;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;-1195.656,-694.6724;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;142;-113.758,1364.8;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;38;-35.71759,3.367065;Float;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;353.0061,-358.2258;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;SNB_Nature/SNB_Foliage;False;False;False;False;False;False;False;False;False;False;False;False;True;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;6;Custom;0.75;True;True;0;True;TransparentCutout;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;8;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;4;Pragma;multi_compile _ LOD_FADE_CROSSFADE;False;;Pragma;instancing_options procedural:setup;False;;Pragma;multi_compile GPU_FRUSTUM_ON__;False;;Include;VS_indirect.cginc;False;;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;13;0;11;0
WireConnection;13;1;12;0
WireConnection;14;0;2;0
WireConnection;14;1;13;0
WireConnection;3;0;14;0
WireConnection;4;0;1;0
WireConnection;4;1;3;0
WireConnection;45;0;4;0
WireConnection;45;1;43;0
WireConnection;55;0;56;0
WireConnection;52;0;51;2
WireConnection;148;1;131;0
WireConnection;46;0;45;0
WireConnection;46;1;44;0
WireConnection;54;0;53;0
WireConnection;54;1;55;0
WireConnection;39;0;46;0
WireConnection;130;0;129;0
WireConnection;130;1;148;0
WireConnection;59;0;58;0
WireConnection;57;0;54;0
WireConnection;60;0;39;0
WireConnection;60;1;57;0
WireConnection;60;2;59;0
WireConnection;139;0;143;0
WireConnection;133;0;130;0
WireConnection;95;0;94;0
WireConnection;95;1;96;0
WireConnection;149;0;85;1
WireConnection;149;1;85;2
WireConnection;149;2;85;3
WireConnection;64;0;39;0
WireConnection;64;1;63;0
WireConnection;64;2;61;0
WireConnection;64;3;62;0
WireConnection;140;0;130;0
WireConnection;65;0;60;0
WireConnection;65;1;64;0
WireConnection;93;0;149;0
WireConnection;93;1;95;0
WireConnection;138;0;139;0
WireConnection;138;1;140;0
WireConnection;134;0;133;0
WireConnection;134;1;143;0
WireConnection;40;0;65;0
WireConnection;164;0;106;3
WireConnection;164;1;163;0
WireConnection;101;0;93;0
WireConnection;137;0;136;3
WireConnection;137;1;138;0
WireConnection;82;0;36;0
WireConnection;82;1;47;0
WireConnection;82;2;81;0
WireConnection;82;3;83;0
WireConnection;104;5;105;0
WireConnection;135;0;134;0
WireConnection;135;1;136;3
WireConnection;150;42;36;0
WireConnection;150;52;104;0
WireConnection;150;43;164;0
WireConnection;99;0;101;0
WireConnection;99;1;98;0
WireConnection;99;2;97;0
WireConnection;99;3;132;1
WireConnection;141;0;135;0
WireConnection;141;2;137;0
WireConnection;41;0;40;0
WireConnection;41;1;82;0
WireConnection;108;0;106;1
WireConnection;108;1;107;0
WireConnection;108;2;36;0
WireConnection;142;0;141;0
WireConnection;142;1;99;0
WireConnection;38;0;150;0
WireConnection;38;1;41;0
WireConnection;0;2;108;0
WireConnection;0;10;36;4
WireConnection;0;13;38;0
WireConnection;0;11;142;0
ASEEND*/
//CHKSM=958BAF6A554B491346650D6B6C397D59C7D222F4