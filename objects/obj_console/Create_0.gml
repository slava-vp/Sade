window = new Window(room_width - 320, 0, 320, room_height - obj_file_manager.file_manager_height, "Console");
window.colors.bg = c_black;
window.can_drag = false;
window.can_close = false;
window.can_resize = false;
window.min_width = 200;
window.min_height = 100;
window.has_scrollbar = true;
window.scrollbar_step = 16;

console_lines = [];
max_lines = 500;
line_height = 16;
padding = 4;

console_surface = -1;
surface_width = 0;
surface_height = 0;
surface_needs_update = true;

window.add_button("Clear", function(){
	clear();
});

ensure_surface = function(){
	var _cw = window.get_content_width();
	var _ch = window.get_content_height();
	
	if (window.has_scrollbar){
		_cw -= window.scrollbar_width;
	}
	
	if (_cw <= 0) _cw = 1;
	if (_ch <= 0) _ch = 1;
	
	if (surface_width != _cw || surface_height != _ch || !surface_exists(console_surface)){
		if (surface_exists(console_surface)) surface_free(console_surface);
		console_surface = surface_create(_cw, _ch);
		surface_width = _cw;
		surface_height = _ch;
		surface_needs_update = true;
	}
};

redraw_surface = function(){
	ensure_surface();
	
	surface_set_target(console_surface);
	draw_clear_alpha(c_black, 0);
	
	var _visible_lines = max(1, (surface_height - padding * 2) div line_height);
	var _start_y = padding;
	
	draw_set_color(c_white);
	draw_set_font(fo_text_editor);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	
	var _max_visible = min(_visible_lines, array_length(console_lines) - window.scroll_offset);
	for(var i = 0; i < _max_visible; i++){
		var _line_index = window.scroll_offset + i;
		if (_line_index >= array_length(console_lines)) break;
		draw_text(padding, _start_y + i * line_height, console_lines[_line_index]);
	}
	
	surface_reset_target();
	surface_needs_update = false;
	
	var _total_lines = array_length(console_lines);
	window.max_scroll = max(0, _total_lines - _visible_lines);
};

window.draw_content = function(){
	var _cx = window.get_content_x();
	var _cy = window.get_content_y();
	var _cw = window.get_content_width();
	var _ch = window.get_content_height();
	
	if (window.has_scrollbar){
		_cw -= window.scrollbar_width;
	}
	
	draw_set_color(c_black);
	draw_rectangle(_cx, _cy, _cx + _cw, _cy + _ch, false);
	
	ensure_surface();
	if (surface_needs_update){
		redraw_surface();
	}
	
	if (surface_exists(console_surface)){
		draw_surface(console_surface, _cx, _cy);
	}
};

add_line = function(_text){
	var _split = string_split(_text, "\n");
	for(var i = 0; i < array_length(_split); i++){
		array_push(console_lines, _split[i]);
	}
	while (array_length(console_lines) > max_lines){
		array_delete(console_lines, 0, 1);
	}
	
	var _vis = max(1, (surface_height - padding * 2) div line_height);
	var _total = array_length(console_lines);
	window.scroll_offset = max(0, _total - _vis);
	window.max_scroll = max(0, _total - _vis);
	
	surface_needs_update = true;
};

clear = function(){
	console_lines = [];
	window.scroll_offset = 0;
	window.max_scroll = 0;
	surface_needs_update = true;
};

depth = CONSOLE_DEPTH;