shader_type canvas_item;

// Glow + light rays around a card. Put it on a ColorRect that is
// bigger than the card by `margin` on every side, behind the card art.

uniform vec4 glow_color : source_color = vec4(1.0, 0.85, 0.4, 1.0);
uniform float intensity : hint_range(0.0, 1.0) = 0.0; // 0 = hidden, 1 = full (tween this)
uniform vec2 card_size = vec2(110.0, 160.0);          // size of the card in pixels
uniform float margin = 60.0;                          // how far the effect reaches past the card
uniform float corner_radius = 8.0;
uniform float glow_falloff = 10.0;                    // how quickly the soft glow fades
uniform float ray_count = 14.0;                       // rays around the card
uniform float ray_length = 30.0;                      // how far the rays reach
uniform float ray_sharpness = 6.0;                    // higher = thinner rays
uniform float speed = 0.4;                            // how fast the rays turn

// Distance from point p to a rounded rectangle (negative = inside).
float rounded_box(vec2 p, vec2 half_size, float r) {
	vec2 q = abs(p) - half_size + r;
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void fragment() {
	vec2 full_size = card_size + 2.0 * margin;
	vec2 p = (UV - 0.5) * full_size;                // pixels from the card centre
	float d = rounded_box(p, card_size * 0.5, corner_radius);
	if (d < 0.0) {
		discard;                                    // inside the card: draw nothing
	}

	// Soft glow hugging the edge.
	float glow = exp(-d / glow_falloff);

	// Rays: two sets of stripes by angle, turning in opposite directions.
	float angle = atan(p.y, p.x);
	float a = pow(abs(sin(angle * ray_count * 0.5 + TIME * speed)), ray_sharpness);
	float b = pow(abs(sin(angle * ray_count * 0.35 - TIME * speed * 1.3)), ray_sharpness);
	float rays = max(a, b * 0.7) * exp(-d / ray_length);

	// Gentle pulse.
	float pulse = 0.85 + 0.15 * sin(TIME * 3.0);

	// Fade out before the edge of the ColorRect so the rays never look cut off.
	float to_edge = min(full_size.x * 0.5 - abs(p.x), full_size.y * 0.5 - abs(p.y));
	float edge_fade = smoothstep(0.0, margin * 0.6, to_edge);

	float alpha = clamp((glow + rays * 0.8) * pulse, 0.0, 1.0) * edge_fade * intensity;
	COLOR = vec4(glow_color.rgb, alpha * glow_color.a);
}
