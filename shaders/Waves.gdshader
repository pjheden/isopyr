shader_type canvas_item;

uniform float wave_amount : hint_range(0, 100);

void fragment() {
	COLOR = texture(TEXTURE, UV);
//	COLOR.a = abs(sin(TIME));
}

void vertex() {
	VERTEX.y += sin(UV.x * TIME) * wave_amount;
//	VERTEX.x += UV.x * abs(sin(TIME)) * 8.0;
}