shader_type canvas_item;
#include "card_common.gdshaderinc"

// The Devil: hellfire licking up from the card's edges.

uniform vec4 hot_color : source_color = vec4(1.0, 0.85, 0.35, 1.0);  // right at the edge
uniform vec4 mid_color : source_color = vec4(1.0, 0.3, 0.05, 1.0);
uniform vec4 cool_color : source_color = vec4(0.45, 0.0, 0.02, 1.0); // flame tips
uniform float flame_height = 40.0; // pixels
uniform float speed = 1.6;

void fragment() {
	vec2 p = card_pos(UV);
	float d = card_dist(p);
	if (d < 0.0) {
		discard;
	}

	// Scroll the noise upward over time (screen y points down, so + moves it up).
	float n = fbm(vec2(p.x * 0.06, p.y * 0.04 + TIME * speed));

	// Flames reach further above the card than below it.
	float top = clamp(-p.y / (card_size.y * 0.5), -1.0, 1.0); // +1 at the top edge
	float height = flame_height * (1.0 + 0.5 * top);

	// heat: 1 at the card edge, 0 where the flame ends. Noise makes the tongues.
	float heat = clamp(1.0 - d / (height * (0.3 + n)), 0.0, 1.0);

	vec3 col = mix(cool_color.rgb, mid_color.rgb, smoothstep(0.0, 0.5, heat));
	col = mix(col, hot_color.rgb, smoothstep(0.65, 1.0, heat));
	float alpha = smoothstep(0.0, 0.35, heat) * edge_fade(p) * intensity;
	COLOR = vec4(col, alpha);
}
