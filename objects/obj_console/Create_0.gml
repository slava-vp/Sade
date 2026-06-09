window = new Window(room_width - 320, 0, 320, room_height - obj_file_manager.file_manager_height, "Console");
window.colors.bg = c_black;
window.can_drag = false;
window.can_close = false;
window.can_resize = false;
window.min_width = 200;
window.min_height = 100;
window.has_scrollbar = true;
window.scrollbar_step = 16;
window.has_h_scrollbar = true;
window.h_scroll_step = 20;

console_lines = [];
wrapped_lines = [];
max_lines = 500;
line_height = 16;
padding = 4;

console_surface = -1;
surface_width = 0;
surface_height = 0;
surface_needs_update = true;

h_scroll_offset = 0;
h_scroll_max = 0;
word_wrap = false;

window.add_button("Clear", function(){
	clear();
});
window.add_button("Wrap", function(){
	word_wrap = !word_wrap;
	surface_needs_update = true;
}, word_wrap ? c_green : c_gray);

ensure_surface = function(){
	var _cw = window.get_content_width();
	var _ch = window.get_content_height();
	
	if (window.has_scrollbar) _cw -= window.scrollbar_width;
	if (_cw <= 0) _cw = 1;
	if (_ch <= 0) _ch = 1;
	
	if (surface_width != _cw || surface_height != _ch || !surface_exists(console_surface)){
		if (surface_exists(console_surface)) surface_free(console_surface);
		console_surface = surface_create(_cw, _ch);
		surface_width = _cw;
		surface_height = _ch;
		surface_needs_update = true;
	}
}

wrap_text = function(_text, _max_width){
	var _words = string_split(_text, " ");
	var _lines = [];
	var _current_line = "";
	
	for(var i = 0; i < array_length(_words); i++){
		var _test_line = _current_line;
		if (_test_line != "") _test_line += " ";
		_test_line += _words[i];
		
		if (string_width(_test_line) > _max_width && _current_line != ""){
			array_push(_lines, _current_line);
			_current_line = _words[i];
		}else{
			_current_line = _test_line;
		}
	}
	
	if (_current_line != "") array_push(_lines, _current_line);
	if (array_length(_lines) == 0) array_push(_lines, "");
	
	return _lines;
}

rebuild_wrapped = function(){
	wrapped_lines = [];
	
	for(var i = 0; i < array_length(console_lines); i++){
		if (word_wrap){
			var _max_w = surface_width - padding * 2;
			var _wrapped = wrap_text(console_lines[i], _max_w);
			for (var j = 0; j < array_length(_wrapped); j++){
				array_push(wrapped_lines, _wrapped[j]);
			}
		}else{
			array_push(wrapped_lines, console_lines[i]);
		}
	}
}

redraw_surface = function(){
	ensure_surface();
	rebuild_wrapped();
	
	surface_set_target(console_surface);
	draw_clear_alpha(c_black, 0);
	
	var _visible_lines = max(1, (surface_height - padding * 2) div line_height);
	var _start_y = padding;
	
	draw_set_color(c_white);
	draw_set_font(fo_text_editor);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	
	var _max_visible = min(_visible_lines, array_length(wrapped_lines) - window.scroll_offset);
	
	for(var i = 0; i < _max_visible; i++){
		var _line_index = window.scroll_offset + i;
		if (_line_index >= array_length(wrapped_lines)) break;
		draw_text(padding - h_scroll_offset, _start_y + i * line_height, wrapped_lines[_line_index]);
	}
	
	surface_reset_target();
	surface_needs_update = false;
	
	var _total_lines = array_length(wrapped_lines);
	window.max_scroll = max(0, _total_lines - _visible_lines);
	
	if (!word_wrap){
		var _max_line_w = 0;
		for(var i = 0; i < array_length(console_lines); i++){
			var _w = string_width(console_lines[i]) + padding * 2;
			if (_w > _max_line_w) _max_line_w = _w;
		}
		h_scroll_max = max(0, _max_line_w - surface_width);
	}else{
		h_scroll_max = 0;
		h_scroll_offset = 0;
	}
	window.h_scroll_max = h_scroll_max;
}

window.draw_content = function(){
	var _cx = window.get_content_x();
	var _cy = window.get_content_y();
	
	ensure_surface();
	if (surface_needs_update) redraw_surface();
	
	if (surface_exists(console_surface)){
		draw_surface(console_surface, _cx, _cy);
	}
}

add_line = function(_text){
	var _split = string_split(_text, "\n");
	for(var i = 0; i < array_length(_split); i++){
		array_push(console_lines, _split[i]);
	}
	while(array_length(console_lines) > max_lines){
		array_delete(console_lines, 0, 1);
	}
	
	rebuild_wrapped();
	
	var _vis = max(1, (surface_height - padding * 2) div line_height);
	var _total = array_length(wrapped_lines);
	window.scroll_offset = max(0, _total - _vis);
	window.max_scroll = max(0, _total - _vis);
	
	surface_needs_update = true;
}

clear = function(){
	console_lines = [];
	wrapped_lines = [];
	window.scroll_offset = 0;
	window.max_scroll = 0;
	h_scroll_offset = 0;
	h_scroll_max = 0;
	surface_needs_update = true;
}

depth = CONSOLE_DEPTH;