window.update_buttons(mouse_x, mouse_y);

if (mouse_check_button_pressed(mb_left)){
	if (window.check_buttons_click(mouse_x, mouse_y)){
		exit;
	}
}

var _char = keyboard_lastchar;
var _key = keyboard_lastkey;

if (_key == vk_escape){
	if (create_new_project){
		create_new_project = false;
		new_project_name = "";
		new_project_name_char = 0;
	}
	if (delete_warning){
		delete_warning = false;
	}
}

keyboard_lastkey = vk_nokey;
keyboard_lastchar = "";

if (create_new_project){
	line_col += 0.01;
	
	if (keyboard_check_pressed(vk_enter)){
		if (!directory_exists($"{global.projects_dir}{new_project_name}")){
			create_new_project = false;
			
			directory_create($"{global.projects_dir}{new_project_name}");
			
			var _buffer = buffer_create(32, buffer_grow, 1);
			buffer_write(_buffer, buffer_string, get_create_proj_template_json());
			buffer_save(_buffer, $"{global.projects_dir}{new_project_name}/project.sade");
			buffer_delete(_buffer);
			
			array_push(projects_list, $"{new_project_name}");
			
			create_new_project = false;
			new_project_name = "";
			new_project_name_char = 0;
			surface_needs_update = true;
		}
	}
	
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
	&& _key != vk_f1 && _key != vk_f2 && _key != vk_f3 && _key != vk_f4
	&& _key != vk_f5 && _key != vk_f6 && _key != vk_f7 && _key != vk_f8
	&& _key != vk_f9 && _key != vk_f10 && _key != vk_f11 && _key != vk_f12
	&& !keyboard_check(vk_control) && (string_length(new_project_name) <= max_name_len)){
		new_project_name_char++;
		new_project_name = string_insert(_char, new_project_name, new_project_name_char);
		line_col = 1;
	}
	
	if (_key == vk_backspace){
		new_project_name = string_delete(new_project_name, new_project_name_char, 1);
		new_project_name_char--;
		line_col = 1;
	}
	
	if (_key == vk_left){
		new_project_name_char--;
		line_col = 1;
	}
	if (_key == vk_right){
		new_project_name_char++;
		line_col = 1;
	}
	
	new_project_name_char = clamp(new_project_name_char, 0, string_length(new_project_name));
	exit;
}

var _press_n = keyboard_check_pressed(ord("N"));
var _press_d = keyboard_check_pressed(ord("D"));

if (_press_n){
	if (!delete_warning){
		create_new_project = true;
	}else{
		delete_warning = false;
	}
}

if (delete_warning && keyboard_check_pressed(ord("Y"))){
	directory_destroy($"{global.projects_dir}{projects_list[selected_project]}");
	array_delete(projects_list, selected_project, -1);
	delete_warning = false;
	surface_needs_update = true;
}

if (!create_new_project && (_press_d && array_length(projects_list) > 0)){
	delete_warning = true;
}

if (!delete_warning && !create_new_project){
	if (_key == vk_down){
		selected_project++;
		selected_project = clamp(selected_project, 0, array_length(projects_list) - 1);
		
		if (selected_project >= scroll_offset + max(1, (window.get_content_height() - 30) div 28)){
			scroll_offset++;
		}
		surface_needs_update = true;
	}
	if (_key == vk_up){
		selected_project--;
		selected_project = clamp(selected_project, 0, array_length(projects_list) - 1);
		
		if (selected_project < scroll_offset){
			scroll_offset--;
		}
		surface_needs_update = true;
	}
	
	if (keyboard_check_pressed(vk_space) && array_length(projects_list) > 0){
		instance_destroy();
		instance_create_depth(0, 0, 0, obj_file_manager, {project_name: projects_list[selected_project]});
		exit;
	}
}

if (window.handle_scroll(mouse_x, mouse_y)){
	scroll_offset = window.scroll_offset;
	surface_needs_update = true;
}

if (mouse_check_button_pressed(mb_left)){
	var _sy = 0;
	var _sx = window.get_content_width() / 2;
	var _plw = min(256, window.get_content_width() / 2 - 40);
	var _plydel = 28;
	var _plh = _plydel - 2;
	
	for (var i = 0; i < array_length(projects_list); i++){
		var _row = i - scroll_offset;
		var _px = _sx - _plw;
		var _py = _row * _plydel;
		
		if (point_in_rectangle(mouse_x - window.get_content_x(), mouse_y - window.get_content_y() - 30, _px, _py, _px + _plw * 2, _py + _plh)){
			if (i == selected_project){
				instance_destroy();
				instance_create_depth(0, 0, 0, obj_file_manager, {project_name: projects_list[selected_project]});
			}else{
				selected_project = i;
				surface_needs_update = true;
			}
			exit;
		}
	}
}

if (mouse_check_button_pressed(mb_right)){
	var _sy = 0;
	var _sx = window.get_content_width() / 2;
	var _plw = min(256, window.get_content_width() / 2 - 40);
	var _plydel = 28;
	var _plh = _plydel - 2;
	
	for (var i = 0; i < array_length(projects_list); i++){
		var _row = i - scroll_offset;
		var _px = _sx - _plw;
		var _py = _row * _plydel;
		
		if (point_in_rectangle(mouse_x - window.get_content_x(), mouse_y - window.get_content_y() - 30, _px, _py, _px + _plw * 2, _py + _plh)){
			selected_project = i;
			delete_warning = true;
			create_new_project = false;
			surface_needs_update = true;
			exit;
		}
	}
}