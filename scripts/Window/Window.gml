function Window(_x, _y, _w, _h, _title) constructor{
	x = _x;
	y = _y;
	width = _w;
	height = _h;
	min_width = 150;
	min_height = 100;
	
	title = _title;
	title_height = 24;
	
	visible = true;
	dragging = false;
	resizing = false;
	focused = false;
	can_close = true;
	can_resize = true;
	can_drag = true;
	
	drag_offset_x = 0;
	drag_offset_y = 0;
	
	colors = {
		bg: c_black,
		border: c_gray,
		title_bg: c_dkgray,
		title_bg_focused: c_blue,
		title_text: c_white,
		close_btn: c_red,
		resize_handle: c_gray,
		button_bg: c_gray,
		button_hover: c_blue,
		button_text: c_white
	}
	
	scroll_offset = 0;
	max_scroll = 0;
	has_scrollbar = false;
	scrollbar_width = 10;
	scrollbar_color = c_gray;
	scrollbar_thumb_color = c_white;
	scrollbar_step = 20;
	
	has_h_scrollbar = false;
	h_scroll_offset = 0;
	h_scroll_max = 0;
	h_scroll_step = 20;
	h_scrollbar_height = 12;
	
	title_buttons = [];
	close_button_width = 20;
	button_padding = 4;
	
	add_button = function(_label, _action, _color, _width){
		if (is_undefined(_color)) _color = colors.button_bg;
		if (is_undefined(_width)) _width = string_width(_label) + 12;
		
		array_push(title_buttons, {
			label: _label,
			action: _action,
			color: _color,
			width: _width,
			hover: false
		});
	}
	
	clear_buttons = function(){
		title_buttons = [];
	}
	
	get_buttons_width = function(){
		var _w = 0;
		for(var i = 0; i < array_length(title_buttons); i++){
			_w += title_buttons[i].width + button_padding;
		}
		if (can_close) _w += close_button_width + button_padding;
		return _w;
	}
	
	check_buttons_click = function(_px, _py){
		var _start_x = x + width - get_buttons_width();
		
		for(var i = 0; i < array_length(title_buttons); i++){
			var _btn = title_buttons[i];
			var _bx = _start_x;
			var _bw = _btn.width;
			
			if (point_in_rectangle(_px, _py, _bx, y + 4, _bx + _bw, y + title_height - 4)){
				if (!is_undefined(_btn.action)){
					_btn.action();
				}
				return true;
			}
			
			_start_x += _bw + button_padding;
		}
		
		return false;
	}
	
	update_buttons = function(_px, _py){
		var _start_x = x + width - get_buttons_width();
		
		for(var i = 0; i < array_length(title_buttons); i++){
			var _btn = title_buttons[i];
			var _bx = _start_x;
			var _bw = _btn.width;
			
			_btn.hover = point_in_rectangle(_px, _py, _bx, y + 4, _bx + _bw, y + title_height - 4);
			_start_x += _bw + button_padding;
		}
	}
	
	contains_point = function(_px, _py){
		return point_in_rectangle(_px, _py, x, y, x + width, y + height);
	}
	
	on_title_bar = function(_px, _py){
		var _buttons_w = get_buttons_width();
		return point_in_rectangle(_px, _py, x, y, x + width - _buttons_w, y + title_height);
	}
	
	on_close_button = function(_px, _py){
		if (!can_close) return false;
		var _buttons_w = get_buttons_width();
		var _close_x = x + width - _buttons_w + (get_buttons_width() - close_button_width - button_padding);
		return point_in_rectangle(_px, _py, _close_x, y + 4, _close_x + close_button_width, y + title_height - 4);
	}
	
	on_resize_handle = function(_px, _py){
		return can_resize && point_in_rectangle(_px, _py, x + width - 15, y + height - 15, x + width, y + height);
	}
	
	start_drag = function(_px, _py){
		if (can_drag && on_title_bar(_px, _py)){
			dragging = true;
			drag_offset_x = _px - x;
			drag_offset_y = _py - y;
			return true;
		}
		return false;
	}
	
	update_drag = function(_px, _py){
		if (dragging){
			x = _px - drag_offset_x;
			y = _py - drag_offset_y;
		}
		return dragging;
	}
	
	end_drag = function(){
		dragging = false;
	}
	
	start_resize = function(_px, _py){
		if (can_resize && on_resize_handle(_px, _py)){
			resizing = true;
			return true;
		}
		return false;
	}
	
	update_resize = function(_px, _py){
		if (resizing){
			width = max(min_width, _px - x);
			height = max(min_height, _py - y);
		}
		return resizing;
	}
	
	end_resize = function(){
		resizing = false;
	}
	
	draw_frame = function(){
		if (!visible) return;
		
		draw_set_alpha(0.3);
		draw_set_color(c_black);
		draw_rectangle(x + 3, y + 3, x + width + 3, y + height + 3, false);
		draw_set_alpha(1);
		
		draw_set_color(colors.bg);
		draw_rectangle(x, y, x + width, y + height, false);
		
		draw_set_color(focused ? colors.title_bg_focused : colors.title_bg);
		draw_rectangle(x, y, x + width, y + title_height, false);
		
		draw_set_color(colors.title_text);
		draw_set_font(fo_text_editor);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		var _buttons_w = get_buttons_width();
		var _max_chars = floor((width - _buttons_w - 20) / string_width("A"));
		var _title_text = title;
		if (string_length(_title_text) > _max_chars){
			_title_text = string_copy(_title_text, 1, _max_chars - 2) + "..";
		}
		draw_text(x + 8, y + title_height / 2, _title_text);
		
		var _start_x = x + width - _buttons_w;
		
		for(var i = 0; i < array_length(title_buttons); i++){
			var _btn = title_buttons[i];
			var _bx = _start_x;
			var _bw = _btn.width;
			var _bh = title_height - 8;
			var _by = y + 4;
			
			draw_set_color(_btn.hover ? colors.button_hover : _btn.color);
			draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);
			
			draw_set_color(colors.border);
			draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, true);
			
			draw_set_color(colors.button_text);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_text(_bx + _bw / 2, _by + _bh / 2, _btn.label);
			
			_start_x += _bw + button_padding;
		}
		
		if (can_close){
			var _close_x = _start_x;
			
			draw_set_color(colors.close_btn);
			draw_rectangle(_close_x, y + 4, _close_x + close_button_width, y + title_height - 4, false);
			draw_set_color(c_white);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_text(_close_x + close_button_width / 2, y + title_height / 2, "X");
		}
		
		draw_set_color(colors.border);
		draw_rectangle(x, y, x + width, y + height, true);
		draw_line(x, y + title_height, x + width, y + title_height);
		
		if (can_resize){
			draw_set_color(colors.resize_handle);
			draw_line(x + width - 15, y + height, x + width, y + height - 15);
			draw_line(x + width - 10, y + height, x + width, y + height - 10);
		}
		
		if (has_scrollbar && max_scroll > 0){
			var _cx = get_content_x();
			var _cy = get_content_y();
			var _cw = get_content_width();
			var _ch = get_content_height();
			
			var _bar_h = max(20, _ch * (_ch / (max_scroll + _ch)));
			var _bar_y = _cy + (scroll_offset / max_scroll) * (_ch - _bar_h);
			
			draw_set_color(scrollbar_color);
			draw_rectangle(_cx + _cw - scrollbar_width, _cy, _cx + _cw, _cy + _ch, false);
			
			draw_set_color(scrollbar_thumb_color);
			draw_rectangle(_cx + _cw - scrollbar_width + 1, _bar_y, _cx + _cw - 1, _bar_y + _bar_h, false);
		}
		
		if (has_h_scrollbar && h_scroll_max > 0){
			var _cx = get_content_x();
			var _cy = get_content_y();
			var _cw = get_content_width();
			var _ch = get_content_height();
			
			var _bar_w = max(20, _cw * (_cw / (h_scroll_max + _cw)));
			var _bar_x = _cx + (h_scroll_offset / h_scroll_max) * (_cw - _bar_w);
			var _bar_y = _cy + _ch - h_scrollbar_height;
			
			draw_set_color(scrollbar_color);
			draw_rectangle(_cx, _bar_y, _cx + _cw, _bar_y + h_scrollbar_height, false);
			
			draw_set_color(scrollbar_thumb_color);
			draw_rectangle(_bar_x + 1, _bar_y + 1, _bar_x + _bar_w - 1, _bar_y + h_scrollbar_height - 1, false);
		}
	}
	
	draw_content = function(){};
	
	get_content_x = function(){ return x + 1; };
	get_content_y = function(){ return y + title_height + 1; };
	get_content_width = function(){ return width - 2; };
	get_content_height = function(){ return height - title_height - 2; };
	
	handle_scroll = function(_px, _py){
		if (!visible || !has_scrollbar) return false;
		if (!contains_point(_px, _py)) return false;
		
		if (mouse_wheel_down()){
			scroll_offset = min(max_scroll, scroll_offset + scrollbar_step);
			return true;
		}
		if (mouse_wheel_up()){
			scroll_offset = max(0, scroll_offset - scrollbar_step);
			return true;
		}
		return false;
	}
	
	handle_h_scroll = function(_px, _py){
		if (!visible || !has_h_scrollbar || h_scroll_max <= 0) return false;
		if (!contains_point(_px, _py)) return false;
		
		if (mouse_wheel_down() && keyboard_check(vk_shift)){
			h_scroll_offset = min(h_scroll_max, h_scroll_offset + h_scroll_step);
			return true;
		}
		if (mouse_wheel_up() && keyboard_check(vk_shift)){
			h_scroll_offset = max(0, h_scroll_offset - h_scroll_step);
			return true;
		}
		return false;
	}
	
	show = function(){ visible = true; focused = true; };
	hide = function(){ visible = false; };
	toggle = function(){ visible = !visible; if (visible) focused = true; };
	center = function(){
		x = room_width / 2 - width / 2;
		y = room_height / 2 - height / 2;
	}
}