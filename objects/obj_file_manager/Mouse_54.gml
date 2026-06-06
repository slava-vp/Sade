var _panel_top = window.y;

if (mouse_y >= _panel_top && mouse_y < _panel_top + window.height){
	var _clicked_child = undefined;
	var _clicked_path = "";
	
	var _cx = window.get_content_x();
	var _cy = window.get_content_y();
	
	for(var i = 0; i < array_length(cached_buttons); i++){
		var _btn = cached_buttons[i];
		var _abs_x = _cx + _btn.x;
		var _abs_y = _cy + 25 + _btn.y;
		
		if (_abs_y + _btn.h < _cy + 25) continue;
		if (_abs_y > _cy + 25 + panel_surface_height) continue;
		
		if (point_in_rectangle(mouse_x, mouse_y, _abs_x, _abs_y, _abs_x + _btn.w, _abs_y + _btn.h)){
			_clicked_child = _btn.child;
			if (struct_exists(_btn.child, "path")) _clicked_path = _btn.child.path;
			break;
		}
	}
	
	show_context_menu = true;
	context_menu_x = mouse_x;
	context_menu_y = mouse_y - (2 * context_menu_item_height + 4);
	if (context_menu_y < 0) context_menu_y = mouse_y;
	
	context_menu_items = [];
	target_creation_dir = current_dir;
	context_clicked_path = _clicked_path;
	context_clicked_type = "file";
	
	if (!is_undefined(_clicked_child) && struct_exists(_clicked_child, "type")){
		context_clicked_type = _clicked_child.type;
	}
	
	if (!is_undefined(_clicked_child)){
		var _item_name = _clicked_child.name;
		var _item_type = struct_exists(_clicked_child, "type") ? _clicked_child.type : "file";
		
		if (_item_type == "directory"){
			array_push(context_menu_items, {
				label: "Open: " + _item_name,
				action: function(){
					obj_file_manager.navigate_to(obj_file_manager.context_clicked_path);
				}
			});
		}else{
			array_push(context_menu_items, {
				label: "Open: " + _item_name,
				action: function(){
					obj_file_manager.open_file_in_editor(obj_file_manager.context_clicked_path);
				}
			});
		}
		
		array_push(context_menu_items, {
			label: "Copy: " + _item_name,
			action: function(){
				obj_file_manager.cut_file_or_directory(obj_file_manager.context_clicked_path);
			}
		});
		
		array_push(context_menu_items, {
			label: "Delete: " + _item_name,
			action: function(){
				obj_file_manager.delete_selected_item(obj_file_manager.context_clicked_path);
			}
		});
		
		array_push(context_menu_items, { label: "---", action: function(){} });
	}
	
	array_push(context_menu_items, {
		label: "New .sadel file",
		action: function(){
			obj_file_manager.show_input_popup(
				"Create new code file", "",
				function(_result){
					if (_result == "") return;
					var _full = obj_file_manager.target_creation_dir + "/" + _result + ".sadel";
					if (!file_exists(_full)){
						var _f = file_text_open_write(_full);
						file_text_close(_f);
						obj_file_manager.refresh_directory_tree();
					}
				},
				function(){}
			);
		}
	});
	
	array_push(context_menu_items, {
		label: "New directory",
		action: function(){
			obj_file_manager.show_input_popup(
				"Create new directory", "",
				function(_result){
					if (_result == "") return;
					var _full = obj_file_manager.target_creation_dir + "/" + _result;
					if (!directory_exists(_full)){
						directory_create(_full);
						obj_file_manager.refresh_directory_tree();
					}
				},
				function(){}
			);
		}
	});
	
	if (obj_file_manager.cut_path != ""){
		array_push(context_menu_items, { label: "---", action: function(){} });
		array_push(context_menu_items, {
			label: "Paste: " + obj_file_manager.cut_name,
			action: function(){
				obj_file_manager.paste_file_or_directory(obj_file_manager.target_creation_dir);
				obj_file_manager.ensure_panel_surface();
				obj_file_manager.refresh_directory_tree();
				obj_file_manager.redraw_panel_surface();
			}
		});
	}
	
	var _max_w = 120;
	for(var i = 0; i < array_length(context_menu_items); i++){
		if (context_menu_items[i].label == "---") continue;
		var _w = string_width(context_menu_items[i].label) + 20;
		if (_w > _max_w) _max_w = _w;
	}
	context_menu_width = _max_w;
}