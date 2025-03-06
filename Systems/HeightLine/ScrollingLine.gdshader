shader_type canvas_item;
uniform float scroll_speed = 1.0;
uniform float transparency = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float alpha = 1.0-transparency;
	vec2 scrolling_uv = vec2(UV.x-scroll_speed*TIME, UV.y);
	vec4 in_tex = texture(TEXTURE, scrolling_uv);
	COLOR = vec4(in_tex.rgb, in_tex.a*alpha);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
