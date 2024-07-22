Shader "Unlit/FlowLightWing"
{
	Properties
	{
		_MainTex ("MainTex", 2D) = "white" {} //主纹理图
		_MainColor("MainColor",COLOR)=(1,1,1,1) //颜色
		_Mask("Mask",2D)="white"{} //遮罩图
		_NoiseMask("NoiseMask",2D)="white"{}//遮罩噪波图
		_Noise("Noise",2D)="white"{}//主纹理噪波图
		_Reflective("Reflective",2D)="white"{}//波形曲线图，此效果图可不加，把下方相关代码部分去掉即可
		_RangeL("RangeL",Range(0,6))=4//亮度值
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Transparent"  "IgnoreProjector"="True"}
		LOD 100
 
 
	Pass
	{
		Blend One One
		Cull Off
		ZWrite Off
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
 
		#include "UnityCG.cginc"
 
 
		struct appdata
		{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		float4 vertexColor:COLOR;
		};
 
 
		struct v2f
		{
		float2 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
		float4 vertexColor:COLOR;
		};
 
 
		sampler2D _MainTex;
		float4 _MainTex_ST;
		float4 _MainColor;
		sampler2D _Mask;
		float4 _Mask_ST;
		sampler2D _NoiseMask;
		float4 _NoiseMask_ST;
		sampler2D _Noise;
		float4 _Noise_ST;
		sampler2D _Reflective;
		float4 _Reflective_ST;
		float _RangeL;
 
		v2f vert (appdata v)
		{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv =v.uv;
		o.vertexColor=v.vertexColor;
		return o;
		}
 
		fixed4 frag (v2f i) : SV_Target
		{
		// sample the texture
		float time=_Time.y;
		float2 noise_uv=float2(i.uv+time*float2(-0.8,-0.8));
		float4 noise_var=tex2D(_Noise,TRANSFORM_TEX(noise_uv,_Noise));
		float2 main_uv=float2(i.uv+time*float2(-0.3,-0.3)+noise_var.r*float2(0,0.4));
		float4 main_var=tex2D(_MainTex,TRANSFORM_TEX(main_uv,_MainTex));
		float2 noisemask_uv=float2(i.uv+time*float2(-0.5,-0.6));
		float4 noisemask_var=tex2D(_NoiseMask,TRANSFORM_TEX(noisemask_uv,_NoiseMask));
		float2 mask_uv=float2(i.uv+noisemask_var.r*(0,0.1));
		float4 mask_var=tex2D(_Mask,TRANSFORM_TEX(mask_uv,_Mask));
		float2 refl_uv=float2(i.uv+time*float2(-0.7,0));
		float4 refl_var=tex2D(_Reflective,TRANSFORM_TEX(refl_uv,_Reflective));
		float3 col=((main_var.rgb*_RangeL)*mask_var.rgb*refl_var.r)*_MainColor.rgb*i.vertexColor.rgb*2;
 
 
		return float4(col,1);
	}
	ENDCG
	}
	}
 
}