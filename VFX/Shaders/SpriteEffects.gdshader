shader_type canvas_item;

uniform vec4 outline_color : source_color;
uniform vec4 fill_color : source_color;
uniform float fill_amount;

uniform float desaturation;
uniform float darkness = 1;
uniform float transparency = 0.0;

vec4 diminish(vec4 input_color){
	float mean = (input_color.x + input_color.y + input_color.z)/3.0;
	vec4 new_color = vec4(0, 0, 0, input_color.a);
	new_color.r = (1.0-desaturation)*input_color.r + desaturation*mean;
	new_color.r /= darkness;
	new_color.g = (1.0-desaturation)*input_color.g + desaturation*mean;
	new_color.g /= darkness;
	new_color.b = (1.0-desaturation)*input_color.b + desaturation*mean;
	new_color.b /= darkness;
	return new_color;
}

void fragment(){
	float size_x = 1.0/float(textureSize(TEXTURE, 0).x);
	float size_y = 1.0/float(textureSize(TEXTURE, 0).y);
	vec4 sprite_color = texture(TEXTURE, UV);
	float alpha = -4.0 * sprite_color.a;
	alpha += texture(TEXTURE, UV + vec2(size_x, 0)).a;
	alpha += texture(TEXTURE, UV + vec2(-size_x, 0)).a;
	alpha += texture(TEXTURE, UV + vec2(0, size_y)).a;
	alpha += texture(TEXTURE, UV + vec2(0, -size_y)).a;
	//For outlining corners
	//Change the -4.0 to -8.0 in alpa if adding these lines
	/*alpha += texture(TEXTURE, UV + vec2(size_x, size_y)).a;
	alpha += texture(TEXTURE, UV + vec2(-size_x, size_y)).a;
	alpha += texture(TEXTURE, UV + vec2(-size_x, -size_y)).a;
	alpha += texture(TEXTURE, UV + vec2(size_x, -size_y)).a;*/
	vec4 final_color = mix(sprite_color, outline_color, clamp(alpha, 0.0, 1.0));
	//COLOR = vec4(final_color.rgb, clamp(abs(alpha) + sprite_color.a, 0.0, 1.0));
	if (final_color.a != 0.0) {
		final_color = mix(final_color, fill_color, fill_amount);
		final_color.a *= (1.0-transparency);
		COLOR = diminish(final_color);
	}
}
