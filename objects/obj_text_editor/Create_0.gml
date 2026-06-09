editor_title = "";
on_confirm = undefined;
on_cancel = undefined;
auto_close_on_enter = false;
auto_close_on_escape = false;

current_file = "";
lines = [""];
lines_count = 1;
current_line = 0;
lines_skip = 0;

h_scroll_offset = 0;
h_scroll_max = 0;
h_scroll_step = 20;
has_h_scrollbar = true;
h_scrollbar_height = 12;

current_char = 0;
prev_char = 0;

is_select = false;
select_start_line = -1;
select_end_line = -1;
select_start_char = -1;
select_end_char = -1;

height = room_height - obj_file_manager.file_manager_height;
width = room_width;
x = 0;
y = 0;

click_count = 0;
click_timer = 0;
click_x = 0;
click_y = 0;

draw_set_font(fo_text_editor);
char_w = string_width("A");
char_h = string_height("A");
lines_max_draw = height div char_h + 1;
line_x_start = char_w * 6;
line_col = 1;

click_start_line = 0;
click_start_char = 0;

goto_line_active = false;
goto_line_number = "";

bracket_pairs = ds_map_create();
ds_map_add(bracket_pairs, "(", ")");
ds_map_add(bracket_pairs, "[", "]");
ds_map_add(bracket_pairs, "{", "}");
ds_map_add(bracket_pairs, ")", "(");
ds_map_add(bracket_pairs, "]", "[");
ds_map_add(bracket_pairs, "}", "{");

if (editor_mode == EditorMode.full_editor){
	console_check();
	
	run_code = function(){
		console_log($"=== SADE {SADE_LANG_VER} ===");
		var _prep = Preprocessor(lines);
		var _len = array_length(_prep);
	
		var _code = "";
		for(var i = 0; i < _len; i++){
			_code += _prep[i] + "\n";
		}
	
		if (_code == ""){
			console_log("No code to run");
			return;
		}
	
		console_log("=== Running code ===");
		run(_code);
		console_log("=== Finished ===");
	}

	window = new Window(0, 0, room_width - 320, room_height - obj_file_manager.file_manager_height, "");
	window.can_close = false;
	window.can_drag = false;
	window.can_resize = false;
	window.colors.bg = c_black;
	window.colors.title_bg = c_dkgray;
	window.colors.title_bg_focused = c_dkgray;
	window.has_scrollbar = true;
	window.has_h_scrollbar = true;
	window.scrollbar_step = 3;
	window.h_scroll_step = 40;
	
	window.add_button("run", function(){
		run_code();
	}, c_green, 30);
	window.add_button("full scr", function(){
		toggle_fullscreen();
	}, c_gray);
	
	height = window.get_content_height();
	width = window.get_content_width();
	lines_max_draw = height div (char_h + 4);
}else if (editor_mode == EditorMode.popup_input){
	window = new Window(room_width / 2 - 200, room_height / 2 - 50, 400, 100, "");
	window.colors.bg = c_white;
	window.colors.title_bg = c_blue;
	window.can_resize = false;
	window.has_scrollbar = false;
	
	height = window.get_content_height();
	width = window.get_content_width();
	lines_max_draw = 1;
	line_x_start = 20;
	depth = -9999;
}

text_surface = -1;

undo_stack = [];
redo_stack = [];
max_undo_steps = 100;
undo_active = false;

autocomplete_words = [];
autocomplete_popup = false;
autocomplete_suggestions = [];
autocomplete_index = 0;
autocomplete_max = 5;

cursors = [];
multi_cursor_active = false;

include_words = [];

search_active = false;
search_text = "";
search_results = [];
search_index = -1;

fullscreen = false;
fullscreen_x = 0;
fullscreen_y = 0;
fullscreen_width = 0;
fullscreen_height = 0;

toggle_fullscreen = function(){
	if (fullscreen){
		window.x = fullscreen_x;
		window.y = fullscreen_y;
		window.width = fullscreen_width;
		window.height = fullscreen_height;
		window.can_drag = false;
		window.can_resize = false;
		window.has_scrollbar = true;
		window.has_h_scrollbar = true;
		fullscreen = false;
		
		depth = TEDITFS_DEPTH;
	}else{
		fullscreen_x = window.x;
		fullscreen_y = window.y;
		fullscreen_width = window.width;
		fullscreen_height = window.height;
		window.x = 0;
		window.y = 0;
		window.width = room_width;
		window.height = room_height;
		window.can_drag = false;
		window.can_resize = false;
		window.has_scrollbar = true;
		window.has_h_scrollbar = true;
		fullscreen = true;
		
		depth = TEDITOR_DEPTH;
	}
	
	width = window.get_content_width();
	height = window.get_content_height();
	lines_max_draw = height div (char_h + 4) + 1;
	
	if (surface_exists(text_surface)) surface_free(text_surface);
	text_surface = surface_create(width, height);
	update_text_surf();
}

perform_search = function(){
	search_results = [];
	if (search_text == "") return;
	
	var _search = string_lower(search_text);
	
	for (var i = 0; i < lines_count; i++){
		var _line = string_lower(lines[i]);
		var _pos = 1;
		while (_pos <= string_length(_line)){
			var _found = string_pos(_search, string_copy(_line, _pos, string_length(_line) - _pos + 1));
			if (_found == 1){
				array_push(search_results, { line: i, char: _pos - 1 });
				_pos += string_length(_search);
			}else{
				_pos++;
			}
		}
	}
}

jump_to_search_result = function(){
	if (search_index < 0 || search_index >= array_length(search_results)) return;
	
	var _pos = search_results[search_index];
	current_line = _pos.line;
	current_char = _pos.char;
	prev_char = current_char;
	
	lines_skip = max(0, current_line - lines_max_draw div 2);
	if (lines_skip > lines_count - lines_max_draw) lines_skip = max(0, lines_count - lines_max_draw);
	window.scroll_offset = lines_skip;
	
	select_start_char = -1;
	select_start_line = -1;
	select_end_char = -1;
	select_end_line = -1;
	is_select = false;
	
	update_text_surf();
}

add_cursor = function(_line, _char){
	for(var i = 0; i < array_length(cursors); i++){
		if (cursors[i].line == _line && cursors[i].char == _char){
			return;
		}
	}
	array_push(cursors, { line: _line, char: _char });
	multi_cursor_active = true;
}

clear_cursors = function(){
	cursors = [];
	multi_cursor_active = false;
}

get_all_cursors = function(){
	var _all = [];
	array_push(_all, { line: current_line, char: current_char });
	for(var i = 0; i < array_length(cursors); i++){
		array_push(_all, cursors[i]);
	}
	return _all;
}

apply_to_all_cursors = function(_func){
	var _all = [];
	array_push(_all, { line: current_line, char: current_char });
	for(var i = 0; i < array_length(cursors); i++){
		array_push(_all, { line: cursors[i].line, char: cursors[i].char });
	}
	
	for(var i = 0; i < array_length(_all); i++){
		current_line = _all[i].line;
		current_char = _all[i].char;
		
		_func();
		
		_all[i].line = current_line;
		_all[i].char = current_char;
	}
	
	current_line = _all[0].line;
	current_char = _all[0].char;
	
	for(var i = 1; i < array_length(_all); i++){
		cursors[i - 1].line = _all[i].line;
		cursors[i - 1].char = _all[i].char;
	}
	
	update_text_surf();
}

multi_cursor_insert = function(_text){
	_txt = _text;
	
	save_undo_state();
	
	apply_to_all_cursors(function(){
		lines[current_line] = string_insert(_txt, lines[current_line], current_char + 1);
		current_char += string_length(_txt);
	});
	
	update_autocomplete_dictionary();
}

multi_cursor_delete = function(_forward){
	_fwd = _forward;
	
	save_undo_state();
	
	apply_to_all_cursors(function(){
		if (_fwd){
			if (current_char < string_length(lines[current_line])){
				lines[current_line] = string_delete(lines[current_line], current_char + 1, 1);
			}
		}else{
			if (current_char > 0){
				lines[current_line] = string_delete(lines[current_line], current_char, 1);
				current_char--;
			}
		}
	});
	
	update_autocomplete_dictionary();
}

get_snippets_for_word = function(_word){
	var _word_lower = string_lower(_word);
	var _result = [];
	
	var _key = ds_map_find_first(global.snippets);
	while(!is_undefined(_key)){
		if (string_pos(_word_lower, _key) == 1){
			var _snip_map = ds_map_find_value(global.snippets, _key);
			var _snip_key = ds_map_find_first(_snip_map);
			
			while(!is_undefined(_snip_key)){
				var _snip_value = ds_map_find_value(_snip_map, _snip_key);
				array_push(_result, {
					word: _snip_key,
					label: _snip_key + " (snippet)",
					snippet: _snip_value,
					is_snippet: true
				});
				_snip_key = ds_map_find_next(_snip_map, _snip_key);
			}
		}
		_key = ds_map_find_next(global.snippets, _key);
	}
	
	return _result;
}

insert_snippet = function(_snippet_text){
	save_undo_state();
	
	var _snippet_lines = string_split(_snippet_text, "\n");
	
	var _current_line = lines[current_line];
	var _indent = "";
	for(var i = 1; i <= string_length(_current_line); i++){
		var _ch = string_char_at(_current_line, i);
		if (_ch == " "){
			_indent += _ch;
		}else{
			break;
		}
	}
	
	var _start = current_char;
	while(_start > 0){
		var _ch = string_char_at(_current_line, _start);
		if (!((_ch >= "a" && _ch <= "z") || (_ch >= "A" && _ch <= "Z") || (_ch >= "0" && _ch <= "9") || _ch == "_")){
			_start++;
			break;
		}
		_start--;
	}
	
	var _old_len = current_char - _start + 1;
	lines[current_line] = string_delete(_current_line, _start, _old_len);
	
	if (array_length(_snippet_lines) == 1){
		lines[current_line] = string_insert(_indent + _snippet_lines[0], lines[current_line], _start);
		current_char = _start + string_length(_indent + _snippet_lines[0]);
	}else{
		var _first_line = _indent + _snippet_lines[0];
		lines[current_line] = string_insert(_first_line, lines[current_line], _start);
		
		for(var i = 1; i < array_length(_snippet_lines); i++){
			array_insert(lines, current_line + i, _indent + _snippet_lines[i]);
		}
		
		lines_count = array_length(lines);
		current_line += array_length(_snippet_lines) - 1;
		current_char = string_length(lines[current_line]);
	}
	
	prev_char = current_char;
	update_text_surf();
	update_autocomplete_dictionary();
}

update_autocomplete_dictionary = function(){
	autocomplete_words = [];
	
	for(var i = 0; i < array_length(global.Keywords); i++){
		array_push(autocomplete_words, global.Keywords[i]);
	}
	
	for(var i = 0; i < array_length(global.Functions); i++){
		array_push(autocomplete_words, global.Functions[i]);
	}
	
	for(var i = 0; i < lines_count; i++){
		var _line = lines[i];
		var _word = "";
		
		for(var j = 1; j <= string_length(_line); j++){
			var _ch = string_char_at(_line, j);
			
			if ((_ch >= "a" && _ch <= "z") || (_ch >= "A" && _ch <= "Z") || (_ch >= "0" && _ch <= "9") || _ch == "_"){
				_word += _ch;
			}else{
				if (_word != "" && string_length(_word) > 1){
					var _found = false;
					for(var k = 0; k < array_length(autocomplete_words); k++){
						if (autocomplete_words[k] == _word){
							_found = true;
							break;
						}
					}
					if (!_found) array_push(autocomplete_words, _word);
				}
				_word = "";
			}
		}
		
		if (_word != "" && string_length(_word) > 1){
			var _found = false;
			for(var k = 0; k < array_length(autocomplete_words); k++){
				if (autocomplete_words[k] == _word){
					_found = true;
					break;
				}
			}
			if (!_found) array_push(autocomplete_words, _word);
		}
	}
	
	for(var i = 0; i < array_length(include_words); i++){
		var _found = false;
		for (var k = 0; k < array_length(autocomplete_words); k++){
			if (string_lower(autocomplete_words[k]) == string_lower(include_words[i])){
				_found = true;
				break;
			}
		}
		if (!_found) array_push(autocomplete_words, include_words[i]);
	}
}

get_nearest_words = function(_input, _count){
	var _len = array_length(autocomplete_words);
	if (_len == 0) return [];
	
	var _inp_len = string_length(_input);
	var _input_lower = string_lower(_input);
	
	var _prefix_matches = [];
	var _fuzzy_matches = [];
	
	for(var i = 0; i < _len; i++){
		var _word = autocomplete_words[i];
		var _word_lower = string_lower(_word);
		var _word_len = string_length(_word);
		
		var _prefix_match = true;
		if (_inp_len <= _word_len){
			for(var j = 1; j <= _inp_len; j++){
				if (string_char_at(_input_lower, j) != string_char_at(_word_lower, j)){
					_prefix_match = false;
					break;
				}
			}
		}else{
			_prefix_match = false;
		}
		
		if (_prefix_match){
			var _priority = 1000 - (_word_len - _inp_len) * 10;
			array_push(_prefix_matches, { word: _word, priority: _priority });
		}else{
			var _inp_pos = 1;
			var _match_count = 0;
			
			for(var j = 1; j <= _word_len && _inp_pos <= _inp_len; j++){
				if (string_char_at(_word_lower, j) == string_char_at(_input_lower, _inp_pos)){
					_match_count++;
					_inp_pos++;
				}
			}
			
			if (_match_count >= _inp_len * 0.6){
				var _priority = _match_count * 10;
				array_push(_fuzzy_matches, { word: _word, priority: _priority });
			}
		}
	}
	
	var _sort = function(_arr){
		var _n = array_length(_arr);
		for(var i = 0; i < _n - 1; i++){
			for(var j = 0; j < _n - i - 1; j++){
				if (_arr[j].priority < _arr[j + 1].priority){
					var _tmp = _arr[j];
					_arr[j] = _arr[j + 1];
					_arr[j + 1] = _tmp;
				}
			}
		}
	}
	
	_sort(_prefix_matches);
	_sort(_fuzzy_matches);
	
	var _result = [];
	
	for(var i = 0; i < array_length(_prefix_matches) && array_length(_result) < _count; i++){
		array_push(_result, _prefix_matches[i].word);
	}
	
	var _remaining = _count - array_length(_result);
	for(var i = 0; i < array_length(_fuzzy_matches) && i < _remaining; i++){
		var _found = false;
		for(var j = 0; j < array_length(_result); j++){
			if (_result[j] == _fuzzy_matches[i].word){
				_found = true;
				break;
			}
		}
		if (!_found){
			array_push(_result, _fuzzy_matches[i].word);
		}
	}
	
	return _result;
}

get_nearest_from_list = function(_input, _list, _count) {
	var _len = array_length(_list);
	if (_len == 0) return [];
	
	var _inp_len = max(string_length(_input), 1);
	var _input_lower = string_lower(_input);
	
	var _weights = array_create(_len, 0);
	
	for(var i = 0; i < _len; i++){
		var _word = _list[i];
		var _word_lower = string_lower(_word);
		var _word_len = string_length(_word);
		
		var _prefix_match = true;
		if (_inp_len <= _word_len) {
			for(var j = 1; j <= _inp_len; j++){
				if (string_char_at(_input_lower, j) != string_char_at(_word_lower, j)){
					_prefix_match = false;
					break;
				}
			}
		}else{
			_prefix_match = false;
		}
		
		if (_prefix_match) {
			_weights[i] = 1000 - (_word_len - _inp_len) * 10;
		}else{
			var _inp_pos = 1;
			var _match_count = 0;
			for(var j = 1; j <= _word_len && _inp_pos <= _inp_len; j++){
				if (string_char_at(_word_lower, j) == string_char_at(_input_lower, _inp_pos)){
					_match_count++;
					_inp_pos++;
				}
			}
			if (_match_count >= _inp_len * 0.6){
				_weights[i] = _match_count * 10;
			}
		}
	}
	
	var _indices = array_create(_len, 0);
	for (var i = 0; i < _len; i++) _indices[i] = i;
	
	for(var i = 0; i < _len - 1; i++){
		for(var j = 0; j < _len - i - 1; j++){
			if (_weights[_indices[j]] < _weights[_indices[j + 1]]){
				var _tmp = _indices[j];
				_indices[j] = _indices[j + 1];
				_indices[j + 1] = _tmp;
			}
		}
	}
	
	var _result = [];
	for(var i = 0; i < _len && array_length(_result) < _count; i++){
		if (_weights[_indices[i]] > 0){
			array_push(_result, _list[_indices[i]]);
		}
	}
	
	return _result;
}

show_autocomplete = function(){
	autocomplete_suggestions = [];
	var _line = lines[current_line];
	var _pos = current_char;
	var _dot_pos = 0;
	
	for(var i = _pos; i >= 1; i--){
		var _ch = string_char_at(_line, i);
		if (_ch == ".") {
			_dot_pos = i;
			break;
		}
		if (_ch == " " || _ch == "(" || _ch == ")" || _ch == "[" || _ch == "]" || 
			_ch == "{" || _ch == "}" || _ch == "," || _ch == ";" || _ch == ":" || 
			_ch == "\"" || _ch == "'") {
			break;
		}
	}
	if (_dot_pos > 0) {
		var _var_start = _dot_pos - 1;
		while(_var_start > 0) {
			var _ch = string_char_at(_line, _var_start);
			if (!((_ch >= "a" && _ch <= "z") || (_ch >= "A" && _ch <= "Z") || (_ch >= "0" && _ch <= "9") || _ch == "_")) {
				_var_start++;
				break;
			}
			_var_start--;
		}
		if (_var_start < 1) _var_start = 1;
		var _var_name = string_copy(_line, _var_start, _dot_pos - _var_start);
		
		var _text_after = string_copy(_line, _dot_pos + 1, _pos - _dot_pos);
		var _methods = get_context_methods(_var_name);
		if (_text_after != "") {
			_methods = get_nearest_from_list(_text_after, _methods, autocomplete_max);
		}
		
		for(var i = 0; i < array_length(_methods); i++){
			array_push(autocomplete_suggestions, _methods[i]);
		}
		
		autocomplete_index = 0;
		autocomplete_popup = array_length(autocomplete_suggestions) > 0;
		return;
	}
	
	var _start = _pos;
	while(_start > 0){
		var _ch = string_char_at(_line, _start);
		if (!((_ch >= "a" && _ch <= "z") || (_ch >= "A" && _ch <= "Z") || (_ch >= "0" && _ch <= "9") || _ch == "_")) {
			_start++;
			break;
		}
		_start--;
	}
	var _word = string_copy(_line, _start, _pos - _start + 1);
	var _word_len = string_length(_word);
	
	if (_word_len >= 2){
		autocomplete_suggestions = get_nearest_words(_word, autocomplete_max);
		
		for(var i = array_length(autocomplete_suggestions) - 1; i >= 0; i--){
			if (autocomplete_suggestions[i] == _word || 
				string_length(autocomplete_suggestions[i]) < _word_len) {
				array_delete(autocomplete_suggestions, i, 1);
			}
		}
		
		var _snippets = get_snippets_for_word(_word);
		for(var i = 0; i < array_length(_snippets); i++){
			array_push(autocomplete_suggestions, _snippets[i].label);
		}
		
		autocomplete_index = 0;
		autocomplete_popup = array_length(autocomplete_suggestions) > 0;
	}else{
		autocomplete_popup = false;
	}
}


apply_autocomplete = function(){
	if (!autocomplete_popup || array_length(autocomplete_suggestions) == 0) return;
	
	var _selected = autocomplete_suggestions[autocomplete_index];
	
	if (current_char > 0 && string_char_at(lines[current_line], current_char) == "."){
		lines[current_line] = string_insert(_selected, lines[current_line], current_char + 1);
		current_char += string_length(_selected);
		autocomplete_popup = false;
		surface_redraw_line();
		return;
	}
	
	if (string_pos(" (snippet)", _selected) > 0){
		var _snippet_name = string_replace(_selected, " (snippet)", "");
		
		var _word = string_copy(lines[current_line], find_word_start(), current_char - find_word_start() + 1);
		var _snippets_for_word = get_snippets_for_word(_word);
		
		for(var i = 0; i < array_length(_snippets_for_word); i++){
			if (_snippets_for_word[i].word == _snippet_name){
				insert_snippet(_snippets_for_word[i].snippet);
				break;
			}
		}
	}else{
		save_undo_state();
		
		var _start = find_word_start();
		var _old_word = string_copy(lines[current_line], _start, current_char - _start + 1);
		
		lines[current_line] = string_delete(lines[current_line], _start, current_char - _start + 1);
		lines[current_line] = string_insert(_selected, lines[current_line], _start);
		
		current_char = _start + string_length(_selected);
	}
	
	autocomplete_popup = false;
	surface_redraw_line();
}

parse_includes = function(_base_path){
	var _words = [];
	var _scanned = ds_list_create();
	
	scan_includes_recursive(_base_path, _words, _scanned);
	
	ds_list_destroy(_scanned);
	return _words;
}

scan_includes_recursive = function(_file_path, _words_list, _scanned_list){
	if (ds_list_find_index(_scanned_list, _file_path) != -1) return;
	ds_list_add(_scanned_list, _file_path);
	
	if (!file_exists(_file_path)) return;
	
	var _dir = filename_path(_file_path);
	if (_dir == "") _dir = working_directory;
	
	var _file = file_text_open_read(_file_path);
	
	while (!file_text_eof(_file)){
		var _line = file_text_read_string(_file);
		file_text_readln(_file);
		
		_line = string_replace_all(_line, "\r", "");
		_line = string_replace_all(_line, "\n", "");
		
		var _trimmed = string_trim(_line);
		
		if (string_pos("#include", _trimmed) == 1){
			var _inc_path = string_trim(string_copy(_trimmed, 9, string_length(_trimmed) - 8));
			
			if (string_char_at(_inc_path, 1) == "'" || string_char_at(_inc_path, 1) == "\""){
				_inc_path = string_copy(_inc_path, 2, string_length(_inc_path) - 2);
			}
			
			var _full_inc = _dir + "/" + _inc_path;
			scan_includes_recursive(_full_inc, _words_list, _scanned_list);
		}
		
		var _word = "";
		for (var i = 1; i <= string_length(_line); i++){
			var _ch = string_char_at(_line, i);
			if ((_ch >= "a" && _ch <= "z") || (_ch >= "A" && _ch <= "Z") || 
				(_ch >= "0" && _ch <= "9") || _ch == "_"){
				_word += _ch;
			} else {
				if (_word != "" && string_length(_word) > 1){
					var _found = false;
					for (var j = 0; j < array_length(_words_list); j++){
						if (string_lower(_words_list[j]) == string_lower(_word)){
							_found = true;
							break;
						}
					}
					if (!_found) array_push(_words_list, _word);
				}
				_word = "";
			}
		}
		
		if (_word != "" && string_length(_word) > 1){
			var _found = false;
			for (var j = 0; j < array_length(_words_list); j++){
				if (string_lower(_words_list[j]) == string_lower(_word)){
					_found = true;
					break;
				}
			}
			if (!_found) array_push(_words_list, _word);
		}
	}
	
	file_text_close(_file);
}

find_word_start = function(){
	var _line = lines[current_line];
	var _start = current_char;
	
	while(_start > 0){
		var _ch = string_char_at(_line, _start);
		if (!((_ch >= "a" && _ch <= "z") || (_ch >= "A" && _ch <= "Z") || (_ch >= "0" && _ch <= "9") || _ch == "_")){
			_start++;
			break;
		}
		_start--;
	}
	
	return _start;
}

save_undo_state = function(){
	if (undo_active) return;
	
	redo_stack = [];
	
	var _state = [];
	for(var i = 0; i < lines_count; i++){
		array_push(_state, lines[i]);
	}
	
	array_push(undo_stack, {
		lines: _state,
		cursor_line: current_line,
		cursor_char: current_char,
		lines_skip: lines_skip
	});
	
	while(array_length(undo_stack) > max_undo_steps){
		array_delete(undo_stack, 0, 1);
	}
}

undo = function(){
	if (array_length(undo_stack) == 0) return;
	
	undo_active = true;
	
	var _current_state = [];
	for(var i = 0; i < lines_count; i++){
		array_push(_current_state, lines[i]);
	}
	
	array_push(redo_stack, {
		lines: _current_state,
		cursor_line: current_line,
		cursor_char: current_char,
		lines_skip: lines_skip
	});
	
	var _state = undo_stack[array_length(undo_stack) - 1];
	array_pop(undo_stack);
	
	lines = [];
	for(var i = 0; i < array_length(_state.lines); i++){
		array_push(lines, _state.lines[i]);
	}
	
	lines_count = array_length(lines);
	current_line = clamp(_state.cursor_line, 0, lines_count - 1);
	current_char = clamp(_state.cursor_char, 0, string_length(lines[current_line]));
	lines_skip = clamp(_state.lines_skip, 0, max(0, lines_count - lines_max_draw));
	prev_char = current_char;
	
	window.scroll_offset = lines_skip;
	window.max_scroll = max(0, lines_count - lines_max_draw + 8);
	
	if (surface_exists(text_surface)) update_text_surf();
	
	undo_active = false;
}

redo = function(){
	if (array_length(redo_stack) == 0) return;
	
	undo_active = true;
	
	var _current_state = [];
	for(var i = 0; i < lines_count; i++){
		array_push(_current_state, lines[i]);
	}
	
	array_push(undo_stack, {
		lines: _current_state,
		cursor_line: current_line,
		cursor_char: current_char,
		lines_skip: lines_skip
	});
	
	var _state = redo_stack[array_length(redo_stack) - 1];
	array_pop(redo_stack);
	
	lines = [];
	for(var i = 0; i < array_length(_state.lines); i++){
		array_push(lines, _state.lines[i]);
	}
	
	lines_count = array_length(lines);
	current_line = clamp(_state.cursor_line, 0, lines_count - 1);
	current_char = clamp(_state.cursor_char, 0, string_length(lines[current_line]));
	lines_skip = clamp(_state.lines_skip, 0, max(0, lines_count - lines_max_draw));
	prev_char = current_char;
	
	window.scroll_offset = lines_skip;
	window.max_scroll = max(0, lines_count - lines_max_draw + 8);
	
	if (surface_exists(text_surface)) update_text_surf();
	
	undo_active = false;
}

surface_redraw_line = function(){
	if (!surface_exists(text_surface)){
		text_surface = surface_create(width, height);
		update_text_surf();
		return;
	}
	
	var vi = current_line - lines_skip;
	if (vi >= 0 && vi < lines_max_draw){
		surface_set_target(text_surface);
		var _y = vi * (char_h + 4);
		draw_rectangle_colour(line_x_start - char_w * 2 - h_scroll_offset, _y, width, _y + char_h + 4, c_black, c_black, c_black, c_black, false);
		draw_set_font(fo_text_editor);
		draw_set_halign(fa_right);
		draw_text(line_x_start - h_scroll_offset, _y, $"{current_line + 1}: ");
		draw_set_halign(fa_left);
		draw_text(line_x_start - h_scroll_offset, _y, lines[current_line]);
		surface_reset_target();
	}
}

surface_clear_line = function(){
	if (!surface_exists(text_surface)){
		text_surface = surface_create(width, height);
		update_text_surf();
		return;
	}
	
	var vi = current_line - lines_skip;
	if (vi >= 0 && vi < lines_max_draw){
		surface_set_target(text_surface);
		var _y = vi * (char_h + 4);
		draw_rectangle_colour(0, _y, width, _y + char_h + 4, c_black, c_black, c_black, c_black, false);
		surface_reset_target();
	}
}

update_text_surf = function(){
	if (!surface_exists(text_surface)){
		text_surface = surface_create(width, height);
	}
	
	surface_set_target(text_surface);
	draw_clear_alpha(c_black, 0);
	draw_set_font(fo_text_editor);
	
	draw_set_color(c_white);
	
	for(var i = 0; i < lines_max_draw; i++){
		var li = lines_skip + i;
		if (li >= lines_count) break;
	
		draw_set_halign(fa_right);
		draw_text(line_x_start - h_scroll_offset, i * (char_h + 4), string(li + 1) + ": ");
	
		draw_set_halign(fa_left);
		draw_text(line_x_start - h_scroll_offset, i * (char_h + 4), lines[li]);
	}
	
	surface_reset_target();
	
	var _max_line_w = 0;
	for(var i = 0; i < lines_count; i++){
		var _w = string_width(lines[i]) + line_x_start + 20;
		if (_w > _max_line_w) _max_line_w = _w;
	}
	h_scroll_max = max(0, _max_line_w - width);
	window.h_scroll_max = h_scroll_max;
	
	window.max_scroll = max(0, lines_count - lines_max_draw + 1);
}

copy_selection = function(){
	if (select_start_line == -1) return "";
	
	var _start_line = min(select_start_line, select_end_line);
	var _end_line = max(select_start_line, select_end_line);
	var _start_char, _end_char;
	
	if (select_start_line < select_end_line){
		_start_char = select_start_char;
		_end_char = select_end_char;
	}else if (select_start_line > select_end_line){
		_start_char = select_end_char;
		_end_char = select_start_char;
	}else{
		_start_char = min(select_start_char, select_end_char);
		_end_char = max(select_start_char, select_end_char);
	}
	
	var _result = "";
	
	if (_start_line == _end_line){
		var _len = _end_char - _start_char;
		
		if (_len > 0){
			_result = string_copy(lines[_start_line], _start_char + 1, _len);
		}
	}else{
		_result = string_copy(lines[_start_line], _start_char + 1, string_length(lines[_start_line]) - _start_char);
		
		for(var i = _start_line + 1; i < _end_line; i++){
			_result += "\n" + lines[i];
		}
		
		_result += "\n" + string_copy(lines[_end_line], 1, _end_char);
	}
	
	return _result;
}
delete_selection = function(){
	if (select_start_char == -1 || select_start_line == -1) return;
	
	var _start = min(select_start_line, select_end_line);
	var _end = max(select_start_line, select_end_line);
	var _start_char, _end_char;
	
	if (select_start_line < select_end_line){
		_start_char = select_start_char;
		_end_char = select_end_char;
	}else if (select_start_line > select_end_line){
		_start_char = select_end_char;
		_end_char = select_start_char;
	}else{
		_start_char = min(select_start_char, select_end_char);
		_end_char = max(select_start_char, select_end_char);
	}
	
	if (_start == _end){
		lines[_start] = string_delete(lines[_start], _start_char + 1, _end_char - _start_char);
	}else{
		var _first_part = string_copy(lines[_start], 1, _start_char);
		var _last_part = string_copy(lines[_end], _end_char + 1, string_length(lines[_end]) - _end_char);
		lines[_start] = _first_part + _last_part;
		
		var _delete_count = _end - _start;
		for(var i = 0; i < _delete_count; i++){
			array_delete(lines, _start + 1, 1);
		}
	}
	
	lines_count = array_length(lines);
	current_line = _start;
	current_char = _start_char;
	
	select_start_char = -1;
	select_start_line = -1;
	select_end_char = -1;
	select_end_line = -1;
	
	update_text_surf();
}

load_file = function(_path){
	if (!file_exists(_path)) return;
	
	current_file = _path;
	window.title = "File: " + filename_name(_path);
	
	lines = [];
	var _f = file_text_open_read(_path);
	
	if (file_text_eof(_f)){
		array_push(lines, "");
		file_text_close(_f);
		
		lines_count = 1;
		current_line = 0;
		current_char = 0;
		prev_char = 0;
		lines_skip = 0;
		is_select = false;
		select_start_line = -1;
		select_end_line = -1;
		select_start_char = -1;
		select_end_char = -1;
		
		if (surface_exists(text_surface)) update_text_surf();
		return;
	}
	
	while(!file_text_eof(_f)){
		var _line = file_text_read_string(_f);
		
		file_text_readln(_f);
		_line = string_replace_all(_line, "\r", "");
		_line = string_replace_all(_line, "\n", "");
		array_push(lines, _line);
	}
	
	file_text_close(_f);
	
	lines_count = array_length(lines);
	current_line = 0;
	current_char = 0;
	prev_char = 0;
	lines_skip = 0;
	
	if (lines_count == 0){
		array_push(lines, "");
	}
	
	if (surface_exists(text_surface)) update_text_surf();
	
	undo_stack = [];
	redo_stack = [];
	save_undo_state();
	
	window.max_scroll = max(0, lines_count - lines_max_draw + 1);
	
	include_words = parse_includes(_path);
	update_autocomplete_dictionary();
}

save_file = function(){
	if (current_file == "") return;
	
	var _f = file_text_open_write(current_file);
	
	for(var i = 0; i < lines_count; i++){
		file_text_write_string(_f, lines[i]);
		file_text_writeln(_f);
	}
	
	file_text_close(_f);
}

set_text = function(_text){
	if (_text == ""){
		lines = [""];
		lines_count = 1;
	}else{
		lines = string_split(_text, "\n");
		lines_count = array_length(lines);
	}
	
	current_line = 0;
	current_char = string_length(lines[0]);
	prev_char = current_char;
	lines_skip = 0;
	
	if (surface_exists(text_surface)) update_text_surf();
	
	window.max_scroll = max(0, lines_count - lines_max_draw + 1);
}

get_text = function(){
	var _r = "";
	for(var i = 0; i < lines_count; i++){
		if (i > 0) _r += "\n";
		_r += lines[i];
	}
	
	return _r;
}

detect_var_type = function(_var_name){
	var _search = string_trim(_var_name);
	
	for(var i = current_line; i >= 0; i--){
		var _line = string_trim(lines[i]);
		var _decl = "var " + _search;
		
		if (string_pos(_decl, _line) == 1){
			var _rest = string_copy(_line, string_length(_decl) + 1, string_length(_line) - string_length(_decl));
			_rest = string_trim(_rest);
			
			if (_rest == "") continue;
			
			var _first = string_char_at(_rest, 1);
			
			if (_first == "[") return "array";
			if (_first == "\"" || _first == "'") return "string";
			if (_first >= "0" && _first <= "9") return "number";
		}
	}
	
	return "";
}

get_context_methods = function(_var_name){
	var _type = detect_var_type(_var_name);
	var _methods = [];
	
	if (_type == "array"){
		var _key = ds_map_find_first(global.array_methods);
		
		while(!is_undefined(_key)){
			array_push(_methods, _key + "()");
			_key = ds_map_find_next(global.array_methods, _key);
		}
	}else if (_type == "string"){
		var _key = ds_map_find_first(global.string_methods);
		
		while(!is_undefined(_key)){
			array_push(_methods, _key + "()");
			_key = ds_map_find_next(global.string_methods, _key);
		}
	}
	
	return _methods;
}

text_surface = surface_create(width, height);
update_text_surf();
window.max_scroll = max(0, lines_count - lines_max_draw + 1);


if (editor_mode == EditorMode.popup_input){
	if (instance_exists(obj_file_manager)){
		with(obj_file_manager){
			if (instance_exists(current_editor)){
				with(current_editor){
					input_enabled = false;
				}
			}
		}
	}
}

depth = TEDITOR_DEPTH;