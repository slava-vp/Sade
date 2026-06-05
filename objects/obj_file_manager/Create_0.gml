window = new Window(0, room_height - 160, room_width, 160, "Files");
window.can_close = false;
window.can_drag = false;
window.can_resize = false;
window.colors.bg = c_black;
window.colors.title_bg = c_dkgray;
window.has_scrollbar = true;
window.scrollbar_step = 20;

window.add_button("< Back", function(){
	if (nav_position > 0){
		go_back();
	}
});

function get_directory_tree(_root_path){
	if (!directory_exists(_root_path)){
		return undefined;
	}
	
	var _root_node = {
		name: filename_name(_root_path),
		path: _root_path,
		type: "directory",
		children: [],
		is_open: false
	};
	
	var _items = [];
	var _pattern = _root_path + "/*";
	var _name = file_find_first(_pattern, fa_directory | fa_archive | fa_readonly | fa_hidden);
	
	while(_name != ""){
		array_push(_items, _name);
		_name = file_find_next();
	}
	file_find_close();
	
	for(var i = 0; i < array_length(_items); i++){
		var _item_name = _items[i];
		var _full_path = _root_path + "/" + _item_name;
		
		if (directory_exists(_full_path)){
			var _sub_tree = get_directory_tree(_full_path);
			
			if (!is_undefined(_sub_tree)){
				array_push(_root_node.children, _sub_tree);
			}
		}else{
			var _file_node = {
				name: _item_name,
				type: "file",
				path: _full_path
			};
			array_push(_root_node.children, _file_node);
		}
	}
	
	return _root_node;
}

file_manager_height = window.height;
var _project_path = global.projects_dir + project_name;

directories = get_directory_tree(_project_path);
current_dir = _project_path;

nav_history = [];
nav_position = 0;

scroll_offset = 0;
scroll_speed = 20;
max_scroll = 0;

tooltip_text = "";
tooltip_x = 0;
tooltip_y = 0;
show_tooltip = false;

cached_buttons = [];

show_context_menu = false;
context_menu_x = 0;
context_menu_y = 0;
context_menu_items = [];
context_menu_width = 150;
context_menu_item_height = 20;
target_creation_dir = "";

current_editor = noone;
opened_file_path = "";
current_popup = noone;
last_popup_time = 0;
popup_cooldown = 10;

panel_surface = -1;
panel_surface_width = 0;
panel_surface_height = 0;
surface_needs_update = true;

btn_size = 48;
btn_padding = 10;
btn_label_height = 20;
btn_row_height = btn_size + btn_label_height + btn_padding;
btn_start_x = btn_padding;

context_clicked_path = "";
context_clicked_type = "";

cut_path = "";
cut_type = "";
cut_name = "";

pending_conflict_menu = false;
conflict_source = "";
conflict_target = "";
conflict_target_dir = "";
conflict_name = "";
conflict_type = "";

ensure_panel_surface = function(){
	var _pw = room_width;
	var _ph = file_manager_height - 30;
	
	if (panel_surface_width != _pw || panel_surface_height != _ph || !surface_exists(panel_surface)){
		if (surface_exists(panel_surface)) surface_free(panel_surface);
		panel_surface = surface_create(_pw, _ph);
		panel_surface_width = _pw;
		panel_surface_height = _ph;
		surface_needs_update = true;
	}
}

redraw_panel_surface = function(){
	ensure_panel_surface();
	
	cached_buttons = [];
	
	surface_set_target(panel_surface);
	draw_clear_alpha(c_black, 0);
	
	var _current_node = find_node_by_path(directories, current_dir);
	if (is_undefined(_current_node) || !struct_exists(_current_node, "children")){
		surface_reset_target();
		surface_needs_update = false;
		return;
	}
	
	var _children = _current_node.children;
	var _len = array_length(_children);
	
	if (_len == 0){
		surface_reset_target();
		surface_needs_update = false;
		return;
	}
	
	var _max_cols = max(1, floor((panel_surface_width - btn_padding * 2) / (btn_size + btn_padding)));
	var _start_y = -scroll_offset;
	
	for(var i = 0; i < _len; i++){
		var _child = _children[i];
		if (!is_struct(_child)) continue;
		if (!struct_exists(_child, "name")) continue;
		
		var _name = _child.name;
		var _type = "file";
		if (struct_exists(_child, "type")) _type = _child.type;
		
		var _col = i % _max_cols;
		var _row = i div _max_cols;
		
		var _bx = btn_start_x + _col * (btn_size + btn_padding);
		var _by = _start_y + _row * btn_row_height;
		
		if (_by + btn_row_height < 0) continue;
		if (_by > panel_surface_height) continue;
		
		array_push(cached_buttons, {
			x: _bx,
			y: _by,
			w: btn_size,
			h: btn_size,
			child: _child,
			index: i,
			col: _col,
			row: _row
		});
		
		draw_set_color((_type == "directory") ? c_yellow : c_gray);
		draw_rectangle(_bx, _by, _bx + btn_size, _by + btn_size, false);
		
		draw_set_color(c_black);
		draw_rectangle(_bx, _by, _bx + btn_size, _by + btn_size, true);
		
		draw_set_color(c_black);
		draw_set_font(fo_text_editor);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text(_bx + btn_size / 2, _by + btn_size / 2, (_type == "directory") ? "DIR" : "FILE");
		
		draw_set_color(c_white);
		draw_set_halign(fa_center);
		draw_set_valign(fa_top);
		var _label = _name;
		if (string_length(_label) > 4){
			_label = string_copy(_label, 1, 4) + ".";
		}
		
		draw_text(_bx + btn_size / 2, _by + btn_size + 2, _label);
	}
	
	var _total_rows = ceil(_len / _max_cols);
	var _total_height = _total_rows * btn_row_height;
	max_scroll = max(0, _total_height - panel_surface_height);
	
	if (scroll_offset > max_scroll) scroll_offset = max_scroll;
	if (scroll_offset < 0) scroll_offset = 0;
	
	surface_reset_target();
	surface_needs_update = false;
}

find_node_by_path = function(_node, _path){
	if (is_undefined(_node)) return undefined;
	
	var _node_path = _node.path;
	var _search_path = _path;
	if (string_char_at(_node_path, string_length(_node_path)) == "/")
		_node_path = string_copy(_node_path, 1, string_length(_node_path) - 1);
	
	if (string_char_at(_search_path, string_length(_search_path)) == "/")
		_search_path = string_copy(_search_path, 1, string_length(_search_path) - 1);
	
	if (_node_path == _search_path) return _node;
	
	if (struct_exists(_node, "children")){
		for(var i = 0; i < array_length(_node.children); i++){
			var _found = find_node_by_path(_node.children[i], _path);
			
			if (!is_undefined(_found)) return _found;
		}
	}
	return undefined;
}

open_file_in_editor = function(_file_path){
	if (!file_exists(_file_path)) return;
	
	if (instance_exists(current_popup)){
		instance_destroy(current_popup);
		current_popup = noone;
	}
	
	if (instance_exists(current_editor)){
		instance_destroy(current_editor);
		current_editor = noone;
	}
	
	var _editor = instance_create_depth(0, 0, 0, obj_text_editor);
	current_editor = _editor;
	opened_file_path = _file_path;
	
	with(_editor){
		editor_mode = EditorMode.full_editor;
		input_enabled = true;
		load_file(_file_path);
	}
}

show_input_popup = function(_title, _default_text, _on_confirm, _on_cancel){
	if (current_time - last_popup_time < popup_cooldown) return noone;
	last_popup_time = current_time;
	
	if (instance_exists(current_editor)){
		with (current_editor){
			input_enabled = false;
		}
	}
	
	if (instance_exists(current_popup)){
		instance_destroy(current_popup);
		current_popup = noone;
	}
	
	with (obj_text_editor){
		if (editor_mode == EditorMode.popup_input) instance_destroy();
	}
	
	global.popup_active = true;
	
	var _popup = instance_create_depth(0, 0, 9999, obj_text_editor);
	current_popup = _popup;
	
	with (_popup){
		editor_mode = EditorMode.popup_input;
		input_enabled = true;
		editor_title = _title;
		auto_close_on_enter = true;
		auto_close_on_escape = true;
		on_confirm = _on_confirm;
		on_cancel = _on_cancel;
		
		width = 400;
		height = 100;
		window = new Window(room_width / 2 - 200, room_height / 2 - 50, 400, 100, _title);
		window.colors.bg = c_white;
		window.colors.title_bg = c_blue;
		window.can_resize = false;
		window.has_scrollbar = false;
		
		height = window.get_content_height();
		width = window.get_content_width();
		lines_max_draw = 1;
		line_x_start = 20;
		
		if (surface_exists(text_surface)) surface_free(text_surface);
		text_surface = surface_create(width, height);
		
		set_text(_default_text);
		visible = true;
		depth = -9999;
	}
	
	return _popup;
};

refresh_directory_tree = function(){
	var _proj_path = global.projects_dir + project_name;
	
	directories = get_directory_tree(_proj_path);
	
	if (!directory_exists(current_dir)){
		current_dir = _proj_path;
		nav_history = [_proj_path];
		nav_position = 0;
		scroll_offset = 0;
	}
	
	surface_needs_update = true;
}

delete_directory_recursive = function(_dir_path){
	if (!directory_exists(_dir_path)){
		return;
	}
	
	var _items = [];
	var _pattern = _dir_path + "/*";
	var _name = file_find_first(_pattern, fa_directory | fa_archive | fa_readonly | fa_hidden);
	
	while (_name != ""){
		array_push(_items, _name);
		_name = file_find_next();
	}
	file_find_close();
	
	for(var i = 0; i < array_length(_items); i++){
		var _full_path = _dir_path + "/" + _items[i];
		
		if (directory_exists(_full_path)){
			delete_directory_recursive(_full_path);
		} else if (file_exists(_full_path)){
			file_delete(_full_path);
		}
	}
	
	directory_destroy(_dir_path);
}

delete_all_in_directory = function(_dir_path){
	if (!directory_exists(_dir_path)) return;
	
	var _items = [];
	var _pattern = _dir_path + "/*";
	var _name = file_find_first(_pattern, fa_directory | fa_archive | fa_readonly | fa_hidden);
	
	while (_name != ""){
		array_push(_items, _name);
		_name = file_find_next();
	}
	file_find_close();
	
	for(var i = 0; i < array_length(_items); i++){
		var _full_path = _dir_path + "/" + _items[i];
		
		if (directory_exists(_full_path)){
			delete_directory_recursive(_full_path);
		} else if (file_exists(_full_path)){
			file_delete(_full_path);
		}
	}
}

delete_file_or_directory = function(_path){
	if (directory_exists(_path)){
		delete_all_in_directory(_path);
		directory_destroy(_path);
	}else if (file_exists(_path)){
		file_delete(_path);
	}else{
		return;
	}
	
	if (!directory_exists(current_dir)){
		var _proj_path = global.projects_dir + project_name;
		current_dir = _proj_path;
		nav_history = [_proj_path];
		nav_position = 0;
		scroll_offset = 0;
	}
	
	refresh_directory_tree();
	surface_needs_update = true;
}

delete_selected_item = function(_child_path){
	var _item_name = filename_name(_child_path);
	var _is_dir = directory_exists(_child_path);
	var _type = _is_dir ? "directory" : "file";
	_path = _child_path;
	
	show_input_popup(
		"Delete " + _type + "? Type Y to confirm",
		"",
		function(_result){
			if (_result == "Y" || _result == "y"){
				delete_file_or_directory(_path);
			}
		},
		function(){}
	);
}

cut_file_or_directory = function(_path){
	if (directory_exists(_path)){
		cut_type = "directory";
	}else if (file_exists(_path)){
		cut_type = "file";
	}else{
		return;
	}
	
	cut_path = _path;
	cut_name = filename_name(_path);
}

paste_file_or_directory = function(_target_dir){
	if (cut_path == "") return;
	
	var _src = cut_path;
	var _type = cut_type;
	var _name = cut_name;
	
	var _source_exists = false;
	if (_type == "directory"){
		_source_exists = directory_exists(_src);
	}else{
		_source_exists = file_exists(_src);
	}
	
	if (!_source_exists){
		cut_path = "";
		cut_type = "";
		cut_name = "";
		return;
	}
	
	var _target_path = _target_dir + "/" + _name;
	
	if (_src == _target_path){
		cut_path = "";
		cut_type = "";
		cut_name = "";
		return;
	}
	
	if (file_exists(_target_path) || directory_exists(_target_path)){
		pending_conflict_menu = true;
		conflict_source = _src;
		conflict_target = _target_path;
		conflict_target_dir = _target_dir;
		conflict_name = _name;
		conflict_type = _type;
		return;
	}
	
	perform_paste_direct(_src, _target_path, _type, _name);
}

perform_paste_direct = function(_src, _tgt, _type, _name){
	if (_src == _tgt){
		cut_path = "";
		cut_type = "";
		cut_name = "";
		refresh_directory_tree();
		surface_needs_update = true;
		return true;
	}
	
	var _success = false;
	
	if (_type == "directory"){
		if (string_pos(_src + "/", _tgt) == 1) return false;
		if (!directory_exists(_src)) return false;
		if (!directory_exists(_tgt)) directory_create(_tgt);
		
		if (copy_directory_contents(_src, _tgt)){
			delete_all_in_directory(_src);
			directory_destroy(_src);
			_success = true;
		}
	}else{
		if (!file_exists(_src)) return false;
		
		if (file_copy(_src, _tgt)){
			file_delete(_src);
			_success = true;
		}
	}
	
	if (_success){
		cut_path = "";
		cut_type = "";
		cut_name = "";
		refresh_directory_tree();
		surface_needs_update = true;
	}
	
	return _success;
}

copy_directory_contents = function(_source_dir, _target_dir){
	if (!directory_exists(_source_dir)) return false;
	if (!directory_exists(_target_dir)) return false;
	
	var _items = [];
	var _pattern = _source_dir + "/*";
	var _name = file_find_first(_pattern, fa_directory | fa_archive | fa_readonly | fa_hidden);
	
	while(_name != ""){
		array_push(_items, _name);
		_name = file_find_next();
	}
	file_find_close();
	
	var _all_success = true;
	
	for(var i = 0; i < array_length(_items); i++){
		var _item_name = _items[i];
		var _source_path = _source_dir + "/" + _item_name;
		var _target_path = _target_dir + "/" + _item_name;
		
		if (directory_exists(_source_path)){
			var _dir_created = directory_create(_target_path);
			
			if (_dir_created){
				if (!copy_directory_contents(_source_path, _target_path)){
					_all_success = false;
				}
			}else{
				_all_success = false;
			}
		}else if (file_exists(_source_path)){
			if (!file_copy(_source_path, _target_path)){
				_all_success = false;
			}
		}else{
			_all_success = false;
		}
	}
	
	return _all_success;
}

navigate_to = function(_path){
	if (nav_position < array_length(nav_history) - 1){
		while(array_length(nav_history) > nav_position + 1){
			array_pop(nav_history);
		}
	}
	
	array_push(nav_history, _path);
	nav_position = array_length(nav_history) - 1;
	
	current_dir = _path;
	scroll_offset = 0;
	surface_needs_update = true;
}

go_back = function(){
	if (nav_position > 0){
		nav_position--;
		current_dir = nav_history[nav_position];
		scroll_offset = 0;
		surface_needs_update = true;
		return true;
	}
	
	return false;
}

ensure_panel_surface();
redraw_panel_surface();

current_dir = _project_path;
navigate_to(_project_path);

depth = MANAGER_DEPTH;