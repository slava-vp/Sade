window.draw_frame();

var _cx = window.get_content_x();
var _cy = window.get_content_y();
var _cw = window.get_content_width();
var _ch = window.get_content_height();

draw_set_color(c_white);
draw_set_font(fo_text_editor);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _path_text = "Path: " + current_dir;
if (string_length(_path_text) > 50){
	_path_text = "..." + string_copy(_path_text, string_length(_path_text) - 47, 47);
}
draw_text(_cx + 5, _cy + 2, _path_text);

ensure_panel_surface();
if (surface_needs_update){
	redraw_panel_surface();
}

if (surface_exists(panel_surface)){
	draw_surface(panel_surface, _cx, _cy + 25);
}

show_tooltip = false;
tooltip_text = "";

for(var i = 0; i < array_length(cached_buttons); i++){
	var _btn = cached_buttons[i];
	var _abs_x = _cx + _btn.x;
	var _abs_y = _cy + 25 + _btn.y;
	
	if (point_in_rectangle(mouse_x, mouse_y, _abs_x, _abs_y, _abs_x + _btn.w, _abs_y + _btn.h)){
		if (struct_exists(_btn.child, "name")){
			tooltip_text = _btn.child.name;
			tooltip_x = _abs_x + _btn.w / 2;
			tooltip_y = _abs_y - 5;
			show_tooltip = true;
		}
		break;
	}
}

if (show_tooltip && tooltip_text != ""){
	var _tw = string_width(tooltip_text);
	var _th = string_height(tooltip_text);
	var _tp = 4;
	var _tx = tooltip_x - _tw / 2 - _tp;
	var _ty = tooltip_y - _th - _tp * 2;
	
	if (_tx < 0) _tx = 0;
	if (_tx + _tw + _tp * 2 > room_width) _tx = room_width - _tw - _tp * 2;
	if (_ty < 0) _ty = tooltip_y + 10;
	
	draw_set_color(c_black);
	draw_set_alpha(0.8);
	draw_rectangle(_tx, _ty, _tx + _tw + _tp * 2, _ty + _th + _tp * 2, false);
	draw_set_color(c_white);
	draw_set_alpha(1);
	draw_rectangle(_tx, _ty, _tx + _tw + _tp * 2, _ty + _th + _tp * 2, true);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_text(_tx + _tp, _ty + _tp, tooltip_text);
}

if (show_context_menu){
	var _mh = array_length(context_menu_items) * context_menu_item_height + 4;
	var _mx = context_menu_x;
	var _my = context_menu_y;
	var _mw = context_menu_width;
	
	if (_mx + _mw > room_width) _mx = room_width - _mw - 5;
	if (_my + _mh > room_height) _my = room_height - _mh - 5;
	
	draw_set_color(c_dkgray);
	draw_rectangle(_mx, _my, _mx + _mw, _my + _mh, false);
	draw_set_color(c_white);
	draw_rectangle(_mx, _my, _mx + _mw, _my + _mh, true);
	
	draw_set_font(fo_text_editor);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	
	for(var i = 0; i < array_length(context_menu_items); i++){
		var _iy = _my + 2 + i * context_menu_item_height;
		var _ih = context_menu_item_height;
		
		if (context_menu_items[i].label == "---"){
			draw_set_color(c_gray);
			draw_line(_mx + 5, _iy + _ih / 2, _mx + _mw - 5, _iy + _ih / 2);
			continue;
		}
		
		if (point_in_rectangle(mouse_x, mouse_y, _mx, _iy, _mx + _mw, _iy + _ih)){
			draw_set_color(c_blue);
			draw_rectangle(_mx + 1, _iy, _mx + _mw - 1, _iy + _ih, false);
		}
		
		draw_set_color(c_white);
		draw_text(_mx + 8, _iy + _ih / 2, context_menu_items[i].label);
	}
}