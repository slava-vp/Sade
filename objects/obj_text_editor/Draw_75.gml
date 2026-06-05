if (editor_mode == EditorMode.full_editor){
	if (autocomplete_popup && array_length(autocomplete_suggestions) > 0){
		var _cx = window.get_content_x() + line_x_start + current_char * char_w;
		var _cy = window.get_content_y() + (current_line - lines_skip) * (char_h + 4) + char_h + 8;
		
		var _max_w = 0;
		for(var i = 0; i < array_length(autocomplete_suggestions); i++){
			var _w = string_width(autocomplete_suggestions[i]) + 20;
			if (_w > _max_w) _max_w = _w;
		}
		
		var _h = array_length(autocomplete_suggestions) * 18 + 4;
		
		draw_set_color(c_black);
		draw_set_alpha(0.9);
		draw_rectangle(_cx, _cy, _cx + _max_w, _cy + _h, false);
		draw_set_alpha(1);
		
		draw_set_color(c_white);
		draw_rectangle(_cx, _cy, _cx + _max_w, _cy + _h, true);
		
		draw_set_font(fo_text_editor);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		
		for(var i = 0; i < array_length(autocomplete_suggestions); i++){
			var _iy = _cy + 2 + i * 18;
			
			if (i == autocomplete_index){
				draw_set_color(c_blue);
				draw_rectangle(_cx + 1, _iy, _cx + _max_w - 1, _iy + 18, false);
			}
			
			draw_set_color(c_white);
			draw_text(_cx + 8, _iy + 9, autocomplete_suggestions[i]);
		}
	}
	
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}