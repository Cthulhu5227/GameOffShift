shader_type canvas_item;
#include "card_common.gdshaderinc"

// Glow + light rays around a card. Put it on a ColorRect that is
// bigger than the card by `margin` on every side, behind the card art.

uniform vec4 glow_color : source_color = vec4(1.0, 0.85, 0.4, 1.0);
uniform float glow_falloff = 10.0;                    // how quickly the soft glow fades
uniform float ray_count = 14.0;                       // rays around the card
uniform float ray_length = 30.0;                      // how far the rays reach
uniform float ray_sharpness = 6.0;                    // higher = thinner rays
uniform float speed = 0.4;                            // how fast the rays turn

void fragment() {
	vec2 p = card_pos(UV);                          // pixels from the card centre
	float d = card_dist(p);
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

	float alpha = clamp((glow + rays * 0.8) * pulse, 0.0, 1.0) * edge_fade(p) * intensity;
	COLOR = vec4(glow_color.rgb, alpha * glow_color.a);
}
