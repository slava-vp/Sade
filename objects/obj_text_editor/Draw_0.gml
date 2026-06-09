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
	
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
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
	
	var _bracket_char = string_char_at(lines[current_line], current_char + 1);
	var _bracket_match = ds_map_find_value(bracket_pairs, _bracket_char);

	if (!is_undefined(_bracket_match)){
		var _cx = window.get_content_x();
		var _cy = window.get_content_y();
		
		var _bracket_col = c_white;
		var _bracket_alpha = 0.3;
		
		var _vi = current_line - lines_skip;
		if (_vi >= 0 && _vi < lines_max_draw){
			var _y = _cy + _vi * (char_h + 4);
			var _x = _cx + line_x_start + current_char * char_w - h_scroll_offset;
		
			draw_set_color(_bracket_col);
			draw_set_alpha(_bracket_alpha);
			draw_rectangle(_x, _y, _x + char_w, _y + char_h + 4, false);
			draw_set_alpha(1);
		}
	
		var _depth = 0;
		var _found_line = -1;
		var _found_char = -1;
	
		var _is_opening = (string_pos(_bracket_char, "([{") > 0);
	
		if (_is_opening){
			for (var i = current_line; i < lines_count; i++){
				var _line = lines[i];
				var _start = (i == current_line) ? current_char + 2 : 1;
			
				for (var j = _start; j <= string_length(_line); j++){
					var _ch = string_char_at(_line, j);
					if (_ch == _bracket_char){
						_depth++;
					}else if (_ch == _bracket_match){
						if (_depth == 0){
							_found_line = i;
							_found_char = j;
							break;
						}
						_depth--;
					}
				}
				if (_found_line != -1) break;
			}
		}else{
			for (var i = current_line; i >= 0; i--){
				var _line = lines[i];
				var _end = (i == current_line) ? current_char : string_length(_line);
			
				for (var j = _end; j >= 1; j--){
					var _ch = string_char_at(_line, j);
					if (_ch == _bracket_char){
						_depth++;
					}else if (_ch == _bracket_match){
						if (_depth == 0){
							_found_line = i;
							_found_char = j;
							break;
						}
						_depth--;
					}
				}
				if (_found_line != -1) break;
			}
		}
	
		if (_found_line != -1){
			var _vi2 = _found_line - lines_skip;
			if (_vi2 >= 0 && _vi2 < lines_max_draw){
				var _cy2 = window.get_content_y();
				var _y2 = _cy2 + _vi2 * (char_h + 4);
				var _x2 = _cx + line_x_start + (_found_char - 1) * char_w - h_scroll_offset;
			
				draw_set_color(_bracket_col);
				draw_set_alpha(_bracket_alpha);
				draw_rectangle(_x2, _y2, _x2 + char_w, _y2 + char_h + 4, false);
				draw_set_alpha(1);
			}
		}
		
		draw_set_color(c_white);
	}
	
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
		draw_set_color(c_white);
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
	
	if (goto_line_active){
		var _cx = window.get_content_x() + window.get_content_width() / 2;
		var _cy = window.get_content_y() + window.get_content_height() / 2;
	
		draw_set_color(c_black);
		draw_set_alpha(0.9);
		draw_rectangle(_cx - 100, _cy - 15, _cx + 100, _cy + 15, false);
		draw_set_alpha(1);
		draw_set_color(c_white);
		draw_rectangle(_cx - 100, _cy - 15, _cx + 100, _cy + 15, true);
	
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text(_cx, _cy - 25, "Go to line:");
		draw_text(_cx, _cy, goto_line_number + "|");
	}
	
	if (search_active){
		var _cx = window.get_content_x() + window.get_content_width() / 2;
		var _cy = window.get_content_y() + 30;
	
		var _info = "Find: " + search_text + "|";
		if (array_length(search_results) > 0){
			_info += "  (" + string(search_index + 1) + "/" + string(array_length(search_results)) + ")";
		}else if (search_text != ""){
			_info += "  (not found)";
		}
	
		var _max_w = 280;
		if (string_width(_info) > _max_w){
			var _prefix = "Find: ";
			var _suffix = "";
			if (array_length(search_results) > 0){
				_suffix = "  (" + string(search_index + 1) + "/" + string(array_length(search_results)) + ")";
			}else if (search_text != ""){
				_suffix = "  (not found)";
			}
		
			var _available = _max_w - string_width(_prefix + "|" + _suffix);
			var _text = search_text;
			while (string_width(_text) > _available && string_length(_text) > 0){
				_text = string_copy(_text, 2, string_length(_text) - 1);
			}
			_info = _prefix + _text + "|" + _suffix;
		}
	
		var _w = string_width(_info) + 20;
		draw_set_color(c_black);
		draw_set_alpha(0.9);
		draw_rectangle(_cx - _w/2, _cy - 12, _cx + _w/2, _cy + 12, false);
		draw_set_alpha(1);
		draw_set_color(c_white);
		draw_rectangle(_cx - _w/2, _cy - 12, _cx + _w/2, _cy + 12, true);
	
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text(_cx, _cy, _info);
	
		if (search_text != "" && array_length(search_results) > 0){
			var _cx = window.get_content_x();
			var _cy = window.get_content_y();
	
			for (var i = 0; i < array_length(search_results); i++){
				var _pos = search_results[i];
				var _vi = _pos.line - lines_skip;
		
				if (_vi >= 0 && _vi < lines_max_draw){
					var _y = _cy + _vi * (char_h + 4);
					var _sx = _cx + line_x_start + _pos.char * char_w - h_scroll_offset;
					var _ex = _sx + string_width(search_text);
			
					draw_set_color(i == search_index ? c_orange : c_yellow);
					draw_set_alpha(i == search_index ? 0.6 : 0.3);
					draw_rectangle(_sx, _y, _ex, _y + char_h + 4, false);
					draw_set_alpha(1);
				}
			}
		}
	}
	
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}