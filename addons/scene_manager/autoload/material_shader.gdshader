shader_type canvas_item;

uniform float completion: hint_range(0.0, 1.0) = 0.0;

uniform vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
uniform bool use_color_texture = false;
uniform sampler2D color_texture: hint_default_black;

uniform bool use_gradient = false;
uniform sampler2D gradient_texture;
uniform bool gradient_inverted = false;
uniform float gradient_smoothness: hint_range(0.0, 1.0, 0.1) = 0.1;
uniform bool gradient_flip_h = false;
uniform bool gradient_flip_v = false;

void fragment() {
	vec4 c;
	if (use_color_texture) c = texture(color_texture, UV);
	else c = color;
	
	float a;
	if (use_gradient) {
		vec2 uv = UV;
		if (gradient_flip_h) uv.x = 1.0 - uv.x;
		if (gradient_flip_v) uv.y = 1.0 - uv.y;
		
		//float alpha = smoothstep(cutoff, cutoff + smoothness, value * (1.0 - smoothness) + smoothness);
		
		float g = texture(gradient_texture, uv).r;
		if (gradient_inverted) g = 1.0 - g;
		a = 1.0 - smoothstep(completion, completion + gradient_smoothness, g * (1.0 - gradient_smoothness) + gradient_smoothness);
	} else {
		a = completion;
	}
	c.a *= a;
	
	COLOR = c;
}
