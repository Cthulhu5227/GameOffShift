shader_type canvas_item;
#include "card_common.gdshaderinc"

// The High Priestess: moonlight rippling outward like water,
// with slow-orbiting stars that twinkle.

uniform vec4 glow_color : source_color = vec4(0.55, 0.75, 1.0, 1.0);
uniform vec4 star_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float glow_falloff = 14.0;  // pixels
uniform float ripple_speed = 1.0;
uniform float star_density = 0.18;  // 0..1, share of grid cells holding a star
uniform float star_spacing = 14.0;  // pixels between grid cells

void fragment() {
	vec2 p = card_pos(UV);
	float d = card_dist(p);
	if (d < 0.0) {
		discard;
	}

	// Soft glow, with rings travelling outward from the edge.
	float ripple = 0.5 + 0.5 * sin(d * 0.35 - TIME * ripple_speed * 3.0);
	float glow = exp(-d / glow_falloff) * (0.55 + 0.45 * ripple);

	// Stars: rotate the space slowly, cut it into a grid, and let some cells hold a star.
	float a = TIME * 0.08;
	vec2 q = mat2(vec2(cos(a), -sin(a)), vec2(sin(a), cos(a))) * p;
	vec2 cell = floor(q / star_spacing);
	vec2 local = fract(q / star_spacing) - 0.5;
	float h = hash(cell);
	float star = 0.0;
	if (h > 1.0 - star_density) {
		vec2 offset = (vec2(hash(cell + 3.1), hash(cell + 7.7)) - 0.5) * 0.6;
		float twinkle = 0.5 + 0.5 * sin(TIME * 3.0 + h * 40.0);
		star = smoothstep(0.16, 0.0, length(local - offset)) * twinkle * exp(-d / 40.0);
	}

	vec3 col = mix(glow_color.rgb, star_color.rgb, clamp(star, 0.0, 1.0));
	float alpha = clamp(glow + star, 0.0, 1.0) * edge_fade(p) * intensity;
	COLOR = vec4(col, alpha);
}
