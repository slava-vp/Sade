if (editor_mode == EditorMode.popup_input){
	global.popup_active = false;
	
	if (instance_exists(obj_file_manager)){
		with(obj_file_manager){
			if (instance_exists(current_editor)){
				with(current_editor){
					input_enabled = true;
				}
			}
			current_popup = noone;
		}
	}
}

if (editor_mode == EditorMode.full_editor){
	if (instance_exists(obj_file_manager)){
		with(obj_file_manager){
			if (current_editor == other.id){
				current_editor = noone;
				opened_file_path = "";
			}
		}
	}
}

if (surface_exists(text_surface)){
	surface_free(text_surface);
}

on_confirm = undefined;
on_cancel = undefined;

delete window;

ds_map_destroy(bracket_pairs);