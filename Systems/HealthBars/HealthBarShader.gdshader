shader_type canvas_item;

uniform float fill_amount;
uniform sampler2D full_texture : filter_nearest;
uniform sampler2D empty_texture : filter_nearest;

void fragment() {
	float snapped_fill_amount = floor(fill_amount * 34.0)/34.0;
	if (UV.x < snapped_fill_amount)
		COLOR = texture(full_texture, UV);
	else
		COLOR = texture(empty_texture, UV);
}
