if (editor_mode == EditorMode.popup_input){
	window.title = editor_title;
	window.draw_frame();
	
	var _px = window.x + 10;
	var _py = window.get_content_y() + 5;
	var _pw = window.get_content_width() - 20;
	var _ph = 25;
	
	draw_set_color(c_ltgray);
	draw_rectangle(_px, _py, _px + _pw, _py + _ph, false);
	draw_set_color(c_black);
	draw_rectangle(_px, _py, _px + _pw, _py + _ph, true);
	
	if (lines_count > 0){
		draw_set_color(c_black);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		draw_text(_px + 5, _py + _ph / 2, lines[0]);
		
		var _cx = _px + 5 + string_width(string_copy(lines[0], 1, current_char));
		draw_line(_cx, _py + 5, _cx, _py + _ph - 5);
	}
	
	draw_set_color(c_gray);
	draw_set_halign(fa_center);
	draw_text(window.x + window.width / 2, window.y + window.height - 18, "Enter - OK, Esc - Cancel");
	
	exit;
}

if (editor_mode == EditorMode.full_editor){
	window.title = (current_file != "") ? filename_name(current_file) : "Untitled";
	window.draw_frame();
	
	if (!surface_exists(text_surface)){
		text_surface = surface_create(width, height);
		update_text_surf();
	}
	
	draw_surface(text_surface, window.get_content_x(), window.get_content_y());
	
	if (select_start_char != -1 && select_start_line != -1){
		var _cx = window.get_content_x();
		var _cy = window.get_content_y();
		
		draw_set_alpha(0.25);
		var _start_line = min(select_start_line, select_end_line);
		var _end_line = max(select_start_line, select_end_line);
		var _start_char, _end_char;
		
		if (select_start_line < select_end_line){
			_start_char = select_start_char;
			_end_char = select_end_char;
		} else if (select_start_line > select_end_line){
			_start_char = select_end_char;
			_end_char = select_start_char;
		}else{
			_start_char = min(select_start_char, select_end_char);
			_end_char = max(select_start_char, select_end_char);
		}
		
		for(var i = _start_line; i <= _end_line; i++){
			var _vi = i - lines_skip;
			if (_vi >= 0 && _vi < lines_max_draw){
				var _y = _cy + _vi * (char_h + 4);
				var _sx = _cx + line_x_start - h_scroll_offset;
				var _ex = _cx + width;
				
				if (i == _start_line){
					_sx = _cx + line_x_start + (_start_char * char_w) - h_scroll_offset;
				}
				
				if (i == _end_line){
					_ex = _cx + line_x_start + (_end_char * char_w) - h_scroll_offset;
				}
				
				draw_set_color(c_blue);
				draw_rectangle(_sx, _y, _ex, _y + char_h + 4, false);
			}
		}
		draw_set_alpha(1);
	}
	
	var _vi = current_line - lines_skip;
	if (_vi >= 0 && _vi < lines_max_draw){
		var _cx = window.get_content_x();
		var _cy = window.get_content_y();
		var _y = _cy + _vi * (char_h + 4);
		var _x = _cx + line_x_start + current_char * char_w - h_scroll_offset;
		
		line_col += 0.02;
		if (line_col % 2){
			draw_set_color(c_white);
			draw_line(_x, _y, _x, _y + char_h + 4);
		}
	}
	
	if (multi_cursor_active){
		for(var i = 0; i < array_length(cursors); i++){
			var _c = cursors[i];
			var _vi = _c.line - lines_skip;
			
			if (_vi >= 0 && _vi < lines_max_draw){
				var _cx = window.get_content_x();
				var _cy = window.get_content_y();
				var _y = _cy + _vi * (char_h + 4);
				var _x = _cx + line_x_start + _c.char * char_w - h_scroll_offset;
				
				draw_set_color(c_yellow);
				draw_set_alpha(0.8);
				draw_line(_x, _y, _x, _y + char_h + 4);
				draw_set_alpha(1);
			}
		}
	}
	
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
}