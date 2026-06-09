if (editor_mode == EditorMode.full_editor){
	if (!global.popup_active){
		if (goto_line_active){
			var _char = obj_input.last_char;
			var _key = obj_input.last_key;
		
			if (_key == vk_escape){
				goto_line_active = false;
				goto_line_number = "";
				exit;
			}
		
			if (_key == vk_enter){
				var _line = 0;
				if (goto_line_number != ""){
					_line = clamp(real(goto_line_number) - 1, 0, lines_count - 1);
				}
				current_line = _line;
				current_char = 0;
				prev_char = 0;
				lines_skip = _line;
				if (lines_skip > lines_count - lines_max_draw) lines_skip = max(0, lines_count - lines_max_draw);
				window.scroll_offset = lines_skip;
				update_text_surf();
				goto_line_active = false;
				goto_line_number = "";
				exit;
			}
		
			if (_key == vk_backspace && string_length(goto_line_number) > 0){
				goto_line_number = string_copy(goto_line_number, 1, string_length(goto_line_number) - 1);
				exit;
			}
		
			if (_char >= "0" && _char <= "9"){
				goto_line_number += _char;
				exit;
			}
		
			exit;
		}
	
		if (keyboard_check(vk_control) && keyboard_check_pressed(ord("G"))){
			goto_line_active = true;
			goto_line_number = "";
			exit;
		}
	}
	window.update_buttons(mouse_x, mouse_y);
	
	if (mouse_check_button_pressed(mb_left)){
		if (window.check_buttons_click(mouse_x, mouse_y)){
			exit;
		}
	}
	
	if (keyboard_check_pressed(vk_f11)){
		toggle_fullscreen();
		exit;
	}
}

if (editor_mode == EditorMode.full_editor && !global.popup_active && !goto_line_active){
	if (search_active){
		var _char = obj_input.last_char;
		var _key = obj_input.last_key;
		
		if (_key == vk_escape){
			search_active = false;
			search_text = "";
			search_results = [];
			search_index = -1;
			exit;
		}
		
		if (_key == vk_enter){
			search_active = false;
			exit;
		}
		
		if (_key == vk_backspace){
			if (string_length(search_text) > 0){
				search_text = string_copy(search_text, 1, string_length(search_text) - 1);
				perform_search();
				if (array_length(search_results) > 0){
					search_index = 0;
					jump_to_search_result();
				}
			}
			exit;
		}
		
		if (_key == vk_up && array_length(search_results) > 0){
			search_index--;
			if (search_index < 0) search_index = array_length(search_results) - 1;
			jump_to_search_result();
			exit;
		}
		
		if (_key == vk_down && array_length(search_results) > 0){
			search_index++;
			if (search_index >= array_length(search_results)) search_index = 0;
			jump_to_search_result();
			exit;
		}
		
		if (_char != "" && _key != vk_backspace && _key != vk_enter && _key != vk_escape && _key != vk_tab){
			search_text += _char;
			perform_search();
			if (array_length(search_results) > 0){
				search_index = 0;
				jump_to_search_result();
			}
			exit;
		}
		
		exit;
	}
	
	if (keyboard_check(vk_control) && keyboard_check_pressed(ord("F"))){
		search_active = true;
		search_text = "";
		search_results = [];
		search_index = -1;
		exit;
	}
}

if (editor_mode == EditorMode.full_editor && !search_active && keyboard_check_pressed(vk_f3) && search_text != ""){
	perform_search();
	if (array_length(search_results) > 0){
		search_index++;
		if (search_index >= array_length(search_results)) search_index = 0;
		jump_to_search_result();
	}
	exit;
}

if (keyboard_check_pressed(vk_escape) && multi_cursor_active){
	clear_cursors();
	exit;
}

if (editor_mode == EditorMode.popup_input){
	input_enabled = true;
	
	var _char = obj_input.last_char;
	var _key = obj_input.last_key;
	
	if (keyboard_check_pressed(vk_enter)){
		if (!is_undefined(on_confirm)) on_confirm(get_text());
		instance_destroy();
		exit;
	}
	
	if (keyboard_check_pressed(vk_escape)){
		if (!is_undefined(on_cancel)) on_cancel();
		instance_destroy();
		exit;
	}
	
	if (_char != "" && _key != vk_backspace && _key != vk_delete &&
		_key != vk_left && _key != vk_right && _key != vk_enter){
		lines[0] = string_insert(_char, lines[0], current_char + 1);
		current_char++;
	}
	
	if (keyboard_check_pressed(vk_backspace) && current_char > 0){
		lines[0] = string_delete(lines[0], current_char, 1);
		current_char--;
	}
	
	if (keyboard_check_pressed(vk_delete) && current_char < string_length(lines[0])){
		lines[0] = string_delete(lines[0], current_char + 1, 1);
	}
	
	if (keyboard_check_pressed(vk_left) && current_char > 0) current_char--;
	if (keyboard_check_pressed(vk_right) && current_char < string_length(lines[0])) current_char++;
	
	exit;
}

if (global.popup_active) exit;
if (!input_enabled) exit;

var _char = obj_input.last_char;
var _key = obj_input.last_key;

if (_char != ""
&& _key != vk_left
&& _key != vk_right
&& _key != vk_up
&& _key != vk_down
&& _key != vk_backspace
&& _key != vk_escape
&& _key != vk_delete
&& _key != vk_enter
&& _key != vk_control
&& _key != vk_f1
&& _key != vk_f2
&& _key != vk_f3
&& _key != vk_f4
&& _key != vk_f5
&& _key != vk_f6
&& _key != vk_f7
&& _key != vk_f8
&& _key != vk_f9
&& _key != vk_f10
&& _key != vk_f11
&& _key != vk_f12
&& _key != vk_tab
&& !keyboard_check(vk_control)
){
	if (multi_cursor_active){
		multi_cursor_insert(_char);
	}else{
		save_undo_state();
	
		if (select_start_char != -1 && select_start_line != -1){
			delete_selection();
		}

		var _next = string_char_at(lines[current_line], current_char + 1);

		if (_char == "(" || _char == "[" || _char == "{" || _char == "\"" || _char == "'"){
			if (_next == ")" || _next == "]" || _next == "}" || _next == "\"" || _next == "'"){
				lines[current_line] = string_insert(_char, lines[current_line], current_char + 1);
				current_char++;
			}else{
				lines[current_line] = string_insert(_char, lines[current_line], current_char + 1);
				current_char++;
			
				if (_char == "(") { lines[current_line] = string_insert(")", lines[current_line], current_char + 1); }
				if (_char == "[") { lines[current_line] = string_insert("]", lines[current_line], current_char + 1); }
				if (_char == "{") { lines[current_line] = string_insert("}", lines[current_line], current_char + 1); }
				if (_char == "\"") { lines[current_line] = string_insert("\"", lines[current_line], current_char + 1); }
				if (_char == "'") { lines[current_line] = string_insert("'", lines[current_line], current_char + 1); }
			}
		}else if (_char == ")" || _char == "]" || _char == "}"){
			if ((_char == ")" && _next == ")") ||
				(_char == "]" && _next == "]") ||
				(_char == "}" && _next == "}")){
				current_char++;
			}else{
				lines[current_line] = string_insert(_char, lines[current_line], current_char + 1);
				current_char++;
			}
		}else{
			lines[current_line] = string_insert(_char, lines[current_line], current_char + 1);
			current_char++;
		}
	}
	
	surface_redraw_line();
	
	update_autocomplete_dictionary();
	show_autocomplete();
	
}

if (keyboard_check_pressed(vk_tab)){
	if (autocomplete_popup){
		apply_autocomplete();
		exit;
	}else{
		save_undo_state();
		lines[current_line] = string_insert("    ", lines[current_line], current_char + 1);
		current_char += 4;
		surface_redraw_line();
		exit;
	}
}

if (keyboard_check(vk_control) && _key == ord("C")){
	save_undo_state();
	
	var _text = copy_selection();
	if (_text != "") clipboard_set_text(_text);
	exit;
}

if (keyboard_check(vk_control) && _key == ord("X")){
	var _text = copy_selection();
	if (_text != ""){
		save_undo_state();
		
		clipboard_set_text(_text);
		delete_selection();
	}
	exit;
}

if (keyboard_check(vk_control) && _key == ord("V")){
	if (clipboard_has_text()){
		save_undo_state();
		
		if (select_start_line != -1){
			delete_selection();
		}
		
		var _clipboard = clipboard_get_text();
		var _paste_lines = string_split(_clipboard, "\n");
		var _paste_count = array_length(_paste_lines);
		
		if (_paste_count == 1){
			lines[current_line] = string_insert(_clipboard, lines[current_line], current_char + 1);
			current_char += string_length(_clipboard);
		}else{
			var _end_of_line = string_copy(lines[current_line], current_char + 1, string_length(lines[current_line]) - current_char);
			lines[current_line] = string_copy(lines[current_line], 1, current_char) + _paste_lines[0];
			
			for(var i = 1; i < _paste_count - 1; i++){
				current_line++;
				array_insert(lines, current_line, _paste_lines[i]);
			}
			
			current_line++;
			array_insert(lines, current_line, _paste_lines[_paste_count - 1] + _end_of_line);
			
			current_char = string_length(_paste_lines[_paste_count - 1]);
			lines_count = array_length(lines);
		}
		
		update_text_surf();
	}
	exit;
}

if (keyboard_check(vk_control) && _key == ord("S")){
	save_file();
	include_words = parse_includes(current_file);
	update_autocomplete_dictionary();
	exit;
}

if (keyboard_check(vk_control) && _key == ord("A")){
	select_start_line = 0;
	select_start_char = 0;
	select_end_line = lines_count - 1;
	select_end_char = string_length(lines[lines_count - 1]);
	is_select = true;
	current_line = lines_count - 1;
	current_char = select_end_char;
	exit;
}

if (keyboard_check(vk_control) && _key == ord("D")){
	save_undo_state();
	
	array_insert(lines, current_line + 1, lines[current_line]);
	lines_count++;
	current_line++;
	current_char = min(current_char, string_length(lines[current_line]));
	
	update_text_surf();
	exit;
}

if (keyboard_check(vk_control) && !keyboard_check(vk_shift) && _key == ord("Z")){
	undo();
	exit;
}

if (keyboard_check(vk_control) && keyboard_check(vk_shift) && _key == ord("Z")){
	redo();
	exit;
}

if (_key == vk_left){
	autocomplete_popup = false;
	
	if (multi_cursor_active){
		apply_to_all_cursors(function(){
			if (current_char > 0) current_char--;
		});
	}else{
		if (current_char > 0) current_char--;
		prev_char = current_char;
		line_col = 1;
	}
}

if (_key == vk_right){
	autocomplete_popup = false;
	
	if (multi_cursor_active){
		apply_to_all_cursors(function(){
			if (current_char < string_length(lines[current_line])) current_char++;
		});
	}else{
		if (current_char < string_length(lines[current_line])) current_char++;
		prev_char = current_char;
		line_col = 1;
	}
}

if (autocomplete_popup){
	if (_key == vk_up){
		autocomplete_index = max(0, autocomplete_index - 1);
		exit;
	}
	if (_key == vk_down){
		autocomplete_index = min(array_length(autocomplete_suggestions) - 1, autocomplete_index + 1);
		exit;
	}
	if (_key == vk_escape){
		autocomplete_popup = false;
		exit;
	}
}else{
	if (_key == vk_down){
		if (multi_cursor_active){
			apply_to_all_cursors(function(){
				if (current_line < lines_count - 1){
					current_line++;
					var _len = string_length(lines[current_line]);
					if (current_char > _len) current_char = _len;
				}
			});
		}else{
			if (current_line < array_length(lines) - 1){
				current_line++;
			}
			
			var _len = string_length(lines[current_line]);
			if (prev_char > _len) current_char = _len;
			else current_char = prev_char;
			
			line_col = 1;
			
			if (current_line - lines_skip >= lines_max_draw - 1){
				lines_skip = current_line - lines_max_draw + 2;
				window.scroll_offset = lines_skip;
				window.max_scroll = max(0, lines_count - lines_max_draw + 1);
				update_text_surf();
			}
		}
	}
	
	if (_key == vk_up){
		if (multi_cursor_active){
			apply_to_all_cursors(function(){
				if (current_line > 0){
					current_line--;
					var _len = string_length(lines[current_line]);
					if (current_char > _len) current_char = _len;
				}
			});
		}else{
			if (current_line > 0) current_line--;
			
			var _len = string_length(lines[current_line]);
			if (prev_char > _len) current_char = _len;
			else current_char = prev_char;
			
			line_col = 1;
			
			if (current_line - lines_skip < 0){
				lines_skip = current_line;
				if (lines_skip < 0) lines_skip = 0;
				window.scroll_offset = lines_skip;
				update_text_surf();
			}
		}
	}
}

if (_key == vk_enter){
	autocomplete_popup = false;
	var _char_before = current_char;
	var _original = lines[current_line];
	
	if (select_start_char != -1 && select_start_line != -1){
		delete_selection();
	}
	
	save_undo_state();
	surface_redraw_line();
	
	if (current_char == string_length(_original)){
		array_insert(lines, current_line + 1, "");
	}else{
		var _rest = string_copy(_original, current_char + 1, string_length(_original) - current_char);
		lines[current_line] = string_copy(_original, 1, current_char);
		array_insert(lines, current_line + 1, _rest);
	}
	
	lines_count = array_length(lines);
	current_line++;
	
	var _left = lines[current_line - 1];
	var _indent = "";
	for(var i = 1; i <= string_length(_left); i++){
		if (string_char_at(_left, i) == " ") _indent += " ";
		else break;
	}
	
	if (_char_before < string_length(_indent)){
		_indent = "";
	}
	
	lines[current_line] = _indent + lines[current_line];
	
	var _trim_left = _left;
	while (string_length(_trim_left) > 0 && string_char_at(_trim_left, 1) == " "){
		_trim_left = string_copy(_trim_left, 2, string_length(_trim_left) - 1);
	}
	while (string_length(_trim_left) > 0 && string_char_at(_trim_left, string_length(_trim_left)) == " "){
		_trim_left = string_copy(_trim_left, 1, string_length(_trim_left) - 1);
	}
	var _left_ends_brace = (string_length(_trim_left) > 0 && string_char_at(_trim_left, string_length(_trim_left)) == "{");
	
	var _right = lines[current_line];
	var _trim_right = _right;
	while(string_length(_trim_right) > 0 && string_char_at(_trim_right, 1) == " "){
		_trim_right = string_copy(_trim_right, 2, string_length(_trim_right) - 1);
	}
	var _right_starts_brace = (string_length(_trim_right) > 0 && string_char_at(_trim_right, 1) == "}");
	
	if (_left_ends_brace && _right_starts_brace){
		lines[current_line] = _indent + "    ";
		array_insert(lines, current_line + 1, _indent + "}");
		lines_count = array_length(lines);
		current_char = string_length(_indent) + 4;
		prev_char = current_char;
	}else if (_left_ends_brace){
		lines[current_line] = _indent + "    " + lines[current_line];
		current_char = string_length(_indent) + 4;
		prev_char = current_char;
	}else{
		current_char = string_length(_indent);
		prev_char = current_char;
	}
	
	line_col = 1;
	update_text_surf();
	
	if (current_line - lines_skip >= lines_max_draw - 1){
		lines_skip = current_line - lines_max_draw + 2;
		window.scroll_offset = lines_skip;
		window.max_scroll = max(0, lines_count - lines_max_draw + 1);
	}
}

if (_key == vk_backspace){
	if (multi_cursor_active){
		multi_cursor_delete(false);
	}else{
		if (select_start_char != -1 && select_start_line != -1){
			delete_selection();
		}else{
			surface_redraw_line();
			
			if (current_char > 0){
				if (current_char >= 4){
					var _check = string_copy(lines[current_line], current_char - 3, 4);
					if (_check == "    "){
						lines[current_line] = string_delete(lines[current_line], current_char - 3, 4);
						current_char -= 4;
					}else{
						lines[current_line] = string_delete(lines[current_line], current_char, 1);
						current_char--;
					}
				}else{
					lines[current_line] = string_delete(lines[current_line], current_char, 1);
					current_char--;
				}
				surface_redraw_line();
			}else{
				if (current_line > 0){
					var _old_line = current_line;
					
					if (current_line - lines_skip < 1){
						lines_skip = current_line - 1;
						window.scroll_offset = lines_skip;
					}
					
					current_line--;
					current_char = string_length(lines[current_line]);
					lines[current_line] += lines[_old_line];
					array_delete(lines, _old_line, 1);
					lines_count--;
					update_text_surf();
				}
			}
		}
	}
	
	if (current_char * char_w < h_scroll_offset){
		h_scroll_offset = max(0, current_char * char_w - char_w * 2);
		window.h_scroll_offset = h_scroll_offset;
		update_text_surf();
	}
	
	line_col = 1;
	
	if (autocomplete_popup){
		show_autocomplete();
	}
}

if (_key == vk_delete){
	if (multi_cursor_active){
		multi_cursor_delete(true);
	}else{
		if (select_start_char != -1 && select_start_line != -1){
			delete_selection();
		}else{
			surface_redraw_line();
			
			if (current_char < string_length(lines[current_line])){
				lines[current_line] = string_delete(lines[current_line], current_char + 1, 1);
			}else if (current_line < lines_count - 1){
				lines[current_line] += lines[current_line + 1];
				array_delete(lines, current_line + 1, 1);
				lines_count--;
			}
			
			line_col = 1;
			surface_redraw_line();
		}
	}
	
	if (autocomplete_popup){
		show_autocomplete();
	}
}

line_col += 0.02;

if (!keyboard_check(vk_shift) && window.handle_scroll(mouse_x, mouse_y)){
	lines_skip = window.scroll_offset;
	update_text_surf();
}

if (window.handle_h_scroll(mouse_x, mouse_y)){
	h_scroll_offset = window.h_scroll_offset;
	update_text_surf();
}

if (_key == vk_left && current_char == 0 && h_scroll_offset > 0){
	h_scroll_offset = max(0, h_scroll_offset - h_scroll_step);
	window.h_scroll_offset = h_scroll_offset;
	update_text_surf();
}
if (_key == vk_right && current_char >= string_length(lines[current_line]) && h_scroll_offset < h_scroll_max){
	h_scroll_offset = min(h_scroll_max, h_scroll_offset + h_scroll_step);
	window.h_scroll_offset = h_scroll_offset;
	update_text_surf();
}

if (mouse_check_button_pressed(mb_left)){
	autocomplete_popup = false;
	click_timer = 15;
	
	var _rel_x = mouse_x - window.get_content_x() - line_x_start + h_scroll_offset;
	var _char_x = round(_rel_x / char_w);
	var _line = round((mouse_y - window.get_content_y() - (char_h / 2)) / (char_h + 4)) + lines_skip;
	
	_line = clamp(_line, 0, lines_count - 1);
	_char_x = clamp(_char_x, 0, string_length(lines[_line]));
	
	click_x = mouse_x;
	click_y = mouse_y;
	click_start_line = _line;
	click_start_char = _char_x;
	
	if (keyboard_check(vk_alt)){
		add_cursor(_line, _char_x);
		exit;
	}
	
	if (!keyboard_check(vk_shift)) clear_cursors();
	
	if (abs(mouse_x - click_x) < 5 && abs(mouse_y - click_y) < 5 && click_timer > 0){
		click_count++;
	}else{
		click_count = 1;
	}
	
	current_line = _line;
	current_char = _char_x;
	prev_char = current_char;
	
	is_select = false;
	select_start_char = -1;
	select_start_line = -1;
	select_end_char = -1;
	select_end_line = -1;
}

if (click_timer > 0){
	click_timer--;
	if (click_timer <= 0) click_count = 0;
}

if (mouse_check_button(mb_left) && !mouse_check_button_pressed(mb_left)){
	var _rel_x = mouse_x - window.get_content_x() - line_x_start + h_scroll_offset;
	var _char_x = round(_rel_x / char_w);
	var _line = round((mouse_y - window.get_content_y() - (char_h / 2)) / (char_h + 4)) + lines_skip;
	
	_line = clamp(_line, 0, lines_count - 1);
	_char_x = clamp(_char_x, 0, string_length(lines[_line]));
	
	if (keyboard_check(vk_alt)){
		var _start_l = min(click_start_line, _line);
		var _end_l = max(click_start_line, _line);
		
		cursors = [];
		multi_cursor_active = false;
		current_line = _line;
		current_char = _char_x;
		
		for (var i = _start_l; i <= _end_l; i++){
			if (i == _line) continue;
			add_cursor(i, min(_char_x, string_length(lines[i])));
		}
		multi_cursor_active = array_length(cursors) > 0;
	}else{
		if (abs(mouse_x - click_x) > 3 || abs(mouse_y - click_y) > 3){
			if (select_start_line == -1){
				select_start_line = click_start_line;
				select_start_char = click_start_char;
			}
			
			select_end_line = _line;
			select_end_char = _char_x;
			is_select = true;
			current_line = _line;
			current_char = _char_x;
		}
	}
}

if (mouse_check_button_released(mb_left)){
	if (click_timer > 0 && click_count == 2){
		var _text = lines[current_line];
		var _s = current_char;
		var _e = current_char;
	
		if (_s > 0) _s--;
	
		while(_s >= 0){
			var _ch = string_char_at(_text, _s + 1);
			if (_ch == " " || _ch == "." || _ch == "," || _ch == "(" || _ch == ")" || 
				_ch == "[" || _ch == "]" || _ch == "{" || _ch == "}" || _ch == ":" || 
				_ch == ";" || _ch == "\"" || _ch == "'" || _ch == "!" || _ch == "?" ||
				_ch == "+" || _ch == "-" || _ch == "*" || _ch == "/" || _ch == "=" ||
				_ch == "<" || _ch == ">" || _ch == "&" || _ch == "|" || _ch == "^" ||
				_ch == "%" || _ch == "$" || _ch == "#" || _ch == "@" || _ch == "~" ||
				_ch == "`" || _ch == "\t" || _ch == "\n" || _ch == "\r"){
				_s++;
				break;
			}
			_s--;
		}
	
		var _len = string_length(_text);
		while(_e < _len){
			var _ch = string_char_at(_text, _e + 1);
			if (_ch == " " || _ch == "." || _ch == "," || _ch == "(" || _ch == ")" || 
				_ch == "[" || _ch == "]" || _ch == "{" || _ch == "}" || _ch == ":" || 
				_ch == ";" || _ch == "\"" || _ch == "'" || _ch == "!" || _ch == "?" ||
				_ch == "+" || _ch == "-" || _ch == "*" || _ch == "/" || _ch == "=" ||
				_ch == "<" || _ch == ">" || _ch == "&" || _ch == "|" || _ch == "^" ||
				_ch == "%" || _ch == "$" || _ch == "#" || _ch == "@" || _ch == "~" ||
				_ch == "`" || _ch == "\t" || _ch == "\n" || _ch == "\r"){
				break;
			}
			_e++;
		}
	
		if (_s < 0) _s = 0;
	
		select_start_line = current_line;
		select_start_char = _s;
		select_end_line = current_line;
		select_end_char = _e;
		is_select = true;
		current_char = _e;
	}
	
	if (click_timer > 0 && click_count >= 3){
		select_start_line = current_line;
		select_start_char = 0;
		select_end_line = current_line;
		select_end_char = string_length(lines[current_line]);
		is_select = true;
		current_char = select_end_char;
		click_count = 0;
	}
}