shader_type canvas_item;

uniform float speed = 1.0 ;


void fragment() {
	vec2 moving_uv = vec2(UV.x - (TIME*speed),UV.y);
	moving_uv = fract(moving_uv);
	vec4 in_tex = texture(TEXTURE,moving_uv);
	COLOR = vec4(COLOR.r,COLOR.g,COLOR.b,in_tex.a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
