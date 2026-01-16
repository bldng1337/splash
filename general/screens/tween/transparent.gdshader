shader_type canvas_item;

void vertex() {
}

void fragment() {
    vec4 col = texture(TEXTURE, UV);
    if (length(col.rgb) < 0.1) {
    	COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    } else {
    	COLOR = col;
    }
}
