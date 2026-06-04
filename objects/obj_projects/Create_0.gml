window = new Window(0, 0, room_width, room_height, "Project Manager |>    n - new | d - delete | space - open");
window.can_resize = false;
window.can_close = false;
window.can_drag = false;
window.colors.bg = c_black;
window.has_scrollbar = true;
window.scrollbar_step = 1;

window.add_button("exit", function(){
	game_end();
}, c_red);

draw_set_font(fo_text_editor);

projects_list = [];
scroll_offset = 0;

var _file_name = file_find_first($"{global.projects_dir}\*", fa_directory);

while (_file_name != ""){
	array_push(projects_list, _file_name);
	_file_name = file_find_next();
}

file_find_close();

selected_project = 0;
delete_warning = false;
create_new_project = false;
new_project_name = "";
new_project_name_char = 0;
max_name_len = 29;

char_w = string_width("A");
line_col = 1;

project_create_template = {
	sade: {
		lang_ver: SADE_LANG_VER,
		editor: EDITOR_VER,
	},
	project: {
		name: "",
		graphic_mode: graphic_mode.terminal,
	},
};

get_create_proj_template_json = function(){
	return json_stringify(project_create_template);
};

project_list_surface = -1;
surface_needs_update = true;

ensure_surface = function(){
	var _cw = window.get_content_width();
	var _ch = window.get_content_height() - 28;
	
	if (!surface_exists(project_list_surface)){
		project_list_surface = surface_create(_cw, _ch);
		surface_needs_update = true;
	}
}

redraw_surface = function(){
	ensure_surface();
	
	draw_set_valign(fa_top);
	
	surface_set_target(project_list_surface);
	draw_clear_alpha(c_black, 0);
	
	var _cw = window.get_content_width();
	var _ch = window.get_content_height() - 30;
	var _sx = _cw / 2;
	
	var _plydel = 28;
	var _plh = _plydel - 2;
	var _plw = min(256, _cw / 2 - 40);
	
	var _visible = max(1, _ch div _plydel);
	var _total = array_length(projects_list);
	
	for (var i = 0; i < _total; i++){
		draw_set_halign(fa_left);
		
		var _row = i - scroll_offset;
		if (_row < 0) continue;
		if (_row >= _visible) break;
		
		var _py = _row * _plydel + 8;
		
		if (selected_project == i){
			draw_set_valign(fa_middle);
				draw_set_color(c_white);
				draw_text(_sx - _plw - 16, _py + _plh / 2, ">");
				draw_set_halign(fa_right);
					draw_text(_sx + _plw + 16, _py + _plh / 2, "<");
				draw_set_halign(fa_left);
			draw_set_valign(fa_top);
		}
		
		draw_set_color(c_black);
		draw_rectangle(_sx - _plw, _py, _sx + _plw, _py + _plh, false);
		draw_set_color(c_white);
		draw_rectangle(_sx - _plw, _py, _sx + _plw, _py + _plh, true);
		draw_text(_sx - _plw + 8, _py + 4, projects_list[i]);
	}
	
	surface_reset_target();
	surface_needs_update = false;
	window.max_scroll = max(0, _total - _visible);
}

ensure_surface();
redraw_surface();