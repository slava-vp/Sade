if (!window.visible) exit;

window.update_buttons(mouse_x, mouse_y);

if (mouse_check_button_pressed(mb_left)){
	if (window.check_buttons_click(mouse_x, mouse_y)) exit;
}

if (mouse_check_button_pressed(mb_left)){
	if (window.on_close_button(mouse_x, mouse_y)){
		window.hide();
		exit;
	}
	
	if (window.on_title_bar(mouse_x, mouse_y)){
		window.start_drag(mouse_x, mouse_y);
	}else if (window.on_resize_handle(mouse_x, mouse_y)){
		window.start_resize(mouse_x, mouse_y);
	}
}

if (mouse_check_button(mb_left)){
	if (window.dragging){
		window.update_drag(mouse_x, mouse_y);
	}else if (window.resizing){
		window.update_resize(mouse_x, mouse_y);
		surface_needs_update = true;
	}
}else{
	window.end_drag();
	window.end_resize();
}

if (window.handle_scroll(mouse_x, mouse_y)){
	surface_needs_update = true;
}

if (!word_wrap && window.contains_point(mouse_x, mouse_y)){
	if (keyboard_check(vk_shift)){
		if (mouse_wheel_down() && h_scroll_offset < h_scroll_max){
			h_scroll_offset = min(h_scroll_max, h_scroll_offset + window.h_scroll_step);
			window.h_scroll_offset = h_scroll_offset;
			surface_needs_update = true;
		}
		if (mouse_wheel_up() && h_scroll_offset > 0){
			h_scroll_offset = max(0, h_scroll_offset - window.h_scroll_step);
			window.h_scroll_offset = h_scroll_offset;
			surface_needs_update = true;
		}
	}
}