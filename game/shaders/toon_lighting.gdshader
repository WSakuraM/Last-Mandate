shader_type spatial;
// 简易 toon 着色器（可选，用于未来精模角色的色阶光照）。
// 当前灰盒阶段不挂载；精模替换后在材质中使用。

uniform vec4 albedo_color : source_color = vec4(0.5, 0.4, 0.35, 1.0);
uniform float shadow_threshold : hint_range(-1.0, 1.0) = 0.2;
uniform vec4 shadow_color : source_color = vec4(0.2, 0.15, 0.12, 1.0);
uniform float steps : hint_range(2.0, 6.0) = 3.0;

void light() {
	float NdotL = dot(NORMAL, LIGHT);
	// 色阶量化：将连续光照离散为 steps 级
	float toon = floor((NdotL * 0.5 + 0.5) * steps + 0.5) / steps;
	toon = clamp(toon, 0.0, 1.0);
	// 明暗混合
	vec3 lit = albedo_color.rgb;
	vec3 shaded = shadow_color.rgb;
	vec3 final_color = mix(shaded, lit, toon);
	DIFFUSE_LIGHT += final_color * ATTENUATION * LIGHT_COLOR;
}
