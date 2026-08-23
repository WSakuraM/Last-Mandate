shader_type canvas_item;
// 风格化后处理：暗调厚涂 / 版画质感。
// 色彩量化 + 暖褐色调 + 暗角 + 微颗粒噪声。
// 由 StylizedPostProcess.gd 以全屏 ColorRect 叠加。

// 色彩分级步数（越小越"版画"）
uniform float color_steps : hint_range(2.0, 16.0) = 4.0;
// 分级强度 (0 = 原始, 1 = 全量化)
uniform float posterize_strength : hint_range(0.0, 1.0) = 0.6;
// 暗角
uniform float vignette_intensity : hint_range(0.0, 1.5) = 0.4;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.35;
// 颗粒噪声
uniform float grain_intensity : hint_range(0.0, 0.3) = 0.06;
uniform float grain_speed : hint_range(0.0, 2.0) = 0.5;
// 色调（暖褐基调）
uniform vec4 tint_color : source_color = vec4(0.95, 0.88, 0.78, 1.0);
uniform float tint_strength : hint_range(0.0, 0.5) = 0.12;

// 关键修复：用 hint_screen_texture 采样屏幕背后的实际渲染画面
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// 伪随机 hash（无纹理依赖）
float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

void fragment() {
	// 用 screen_texture + SCREEN_UV 采样实际画面，而非 TEXTURE + UV（空白）
	vec4 tex = texture(screen_texture, SCREEN_UV);

	// === 色彩量化（版画 / 厚涂感） ===
	float levels = max(color_steps, 2.0);
	vec3 quantized = floor(tex.rgb * levels + 0.5) / levels;
	vec3 result = mix(tex.rgb, quantized, posterize_strength);

	// === 暖褐色调偏移 ===
	result = mix(result, result * tint_color.rgb, tint_strength);

	// === 暗角 ===
	vec2 vig_uv = UV * (1.0 - UV);
	float vig = vig_uv.x * vig_uv.y * 15.0;
	vig = pow(max(vig, 0.0), vignette_intensity);
	result *= mix(1.0, vig, vignette_opacity);

	// === 微颗粒噪声（随时间微变，模拟胶片颗粒） ===
	float grain = hash(UV * 1000.0 + TIME * grain_speed);
	grain = (grain - 0.5) * 2.0;
	result += grain * grain_intensity;

	COLOR = vec4(clamp(result, 0.0, 1.0), 1.0);
}
