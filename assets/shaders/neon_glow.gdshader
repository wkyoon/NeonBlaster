shader_type canvas_item;

// Neon glow shader for sprites - adds bloom-like edge glow.
// Apply to Polygon2D or Sprite2D material.

uniform vec4 glow_color : source_color = vec4(0.3, 0.9, 1.0, 1.0);
uniform float glow_intensity : hint_range(0.0, 3.0) = 1.5;
uniform float pulse_speed : hint_range(0.0, 5.0) = 2.0;
uniform float pulse_amount : hint_range(0.0, 1.0) = 0.2;

void fragment() {
	vec4 base_color = texture(TEXTURE, UV);
	
	// Pulse effect
	float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
	float intensity = glow_intensity * (1.0 + pulse * pulse_amount);
	
	// Add glow to the color
	vec3 glowing = mix(base_color.rgb, glow_color.rgb, 0.3);
	glowing *= intensity;
	
	// Output with alpha
	COLOR = vec4(glowing, base_color.a);
}