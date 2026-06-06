window.update_buttons(mouse_x, mouse_y);

if (mouse_check_button_pressed(mb_left)){
	if (window.check_buttons_click(mouse_x, mouse_y)){
		exit;
	}
}

if (mouse_check_button_pressed(mb_left)){
	if (window.on_title_bar(mouse_x, mouse_y)){
		window.start_drag(mouse_x, mouse_y);
	} else if (window.on_resize_handle(mouse_x, mouse_y)){
		window.start_resize(mouse_x, mouse_y);
	}
}

if (mouse_check_button(mb_left)){
	if (window.dragging){
		window.update_drag(mouse_x, mouse_y);
		file_manager_height = window.height;
	} else if (window.resizing){
		window.update_resize(mouse_x, mouse_y);
		file_manager_height = window.height;
		surface_needs_update = true;
	}
}else{
	window.end_drag();
	window.end_resize();
}

if (show_context_menu && mouse_check_button_pressed(mb_left)){
	var _mw = context_menu_width;
	var _mh = array_length(context_menu_items) * context_menu_item_height + 4;
	if (!point_in_rectangle(mouse_x, mouse_y, context_menu_x, context_menu_y, context_menu_x + _mw, context_menu_y + _mh)){
		show_context_menu = false;
	}
}
if ((mouse_wheel_down() || mouse_wheel_up()) && window.contains_point(mouse_x, mouse_y)){
	scroll_offset = clamp(scroll_offset + (mouse_wheel_down() - mouse_wheel_up()) * scroll_speed, 0, max_scroll);
	window.scroll_offset = scroll_offset;
	surface_needs_update = true;
}
if (window.handle_scroll(mouse_x, mouse_y)){
	scroll_offset = window.scroll_offset;
	surface_needs_update = true;
}

if (pending_conflict_menu){
	pending_conflict_menu = false;
	
	show_context_menu = true;
	context_menu_x = mouse_x;
	context_menu_y = mouse_y;
	
	context_menu_items = [];
	
	array_push(context_menu_items, {
		label: "Replace existing",
		action: function(){
			_t = obj_file_manager.conflict_target;
			_s = obj_file_manager.conflict_source;
			_tp = obj_file_manager.conflict_type;
			_nm = obj_file_manager.conflict_name;
			
			if (directory_exists(_t)){
				obj_file_manager.delete_all_in_directory(_t);
				directory_destroy(_t);
			} else if (file_exists(_t)){
				file_delete(_t);
			}
			
			obj_file_manager.perform_paste_direct(_s, _t, _tp, _nm);
			obj_file_manager.refresh_directory_tree();
		}
	});
	
	array_push(context_menu_items, {
		label: "Rename and paste",
		action: function(){
			_d = obj_file_manager.conflict_target_dir;
			_s = obj_file_manager.conflict_source;
			_tp = obj_file_manager.conflict_type;
			_nm = obj_file_manager.conflict_name;
			
			obj_file_manager.show_input_popup(
				"Enter new name:",
				_nm,
				function(_new_name){
					if (_new_name != "" && _new_name != _nm){
						var _new_path = _d + "/" + _new_name;
						obj_file_manager.perform_paste_direct(_s, _new_path, _tp, _new_name);
						
						obj_file_manager.refresh_directory_tree();
					}
				},
				function(){}
			);
		}
	});
	
	array_push(context_menu_items, {
		label: "Cancel",
		action: function(){
			obj_file_manager.cut_path = "";
			obj_file_manager.cut_type = "";
			obj_file_manager.cut_name = "";
		}
	});
	
	var _max_w = 120;
	for(var i = 0; i < array_length(context_menu_items); i++){
		var _w = string_width(context_menu_items[i].label) + 20;
		if (_w > _max_w) _max_w = _w;
	}
	context_menu_width = _max_w;
}