if (show_context_menu){
	var _mx = context_menu_x;
	var _mw = context_menu_width;
	if (_mx + _mw > room_width) _mx = room_width - _mw - 5;
	
	for(var i = 0; i < array_length(context_menu_items); i++){
		if (context_menu_items[i].label == "---") continue;
		
		var _iy = context_menu_y + 2 + i * context_menu_item_height;
		if (point_in_rectangle(mouse_x, mouse_y, _mx + 1, _iy, _mx + _mw - 1, _iy + context_menu_item_height)){
			context_menu_items[i].action();
			show_context_menu = false;
			exit;
		}
	}
	show_context_menu = false;
	exit;
}

var _cx = window.get_content_x();
var _cy = window.get_content_y();

if (array_length(cached_buttons) == 0) exit;

for(var i = 0; i < array_length(cached_buttons); i++){
	var _btn = cached_buttons[i];
	var _abs_x = _cx + _btn.x;
	var _abs_y = _cy + 25 + _btn.y;
	
	if (_abs_y + _btn.h < _cy + 25) continue;
	if (_abs_y > _cy + 25 + panel_surface_height) continue;
	
	if (point_in_rectangle(mouse_x, mouse_y, _abs_x, _abs_y, _abs_x + _btn.w, _abs_y + _btn.h)){
		var _child = _btn.child;
		
		if (_child.type == "directory"){
			navigate_to(_child.path);
		}else{
			if (struct_exists(_child, "path")) open_file_in_editor(_child.path);
		}
		break;
	}
}