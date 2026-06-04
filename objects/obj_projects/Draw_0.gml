draw_set_font(fo_text_editor);

window.draw_frame();

if (surface_needs_update) redraw_surface();

var _cx = window.get_content_x();
var _cy = window.get_content_y();

draw_set_color(c_white);
draw_set_valign(fa_top);


if (surface_exists(project_list_surface)){
	draw_surface(project_list_surface, _cx, _cy + 30);
}

if (create_new_project || delete_warning){
	var _pw = 200;
	var _ph = 40;
	var _px = _cx + window.get_content_width() / 2 - _pw / 2;
	var _py = _cy + window.get_content_height() / 2 - _ph / 2;
	
	draw_set_color(c_black);
	draw_rectangle(_px - 64, _py - 32, _px + _pw + 64, _py + _ph, false);
	draw_set_color(c_white);
	draw_rectangle(_px - 64, _py, _px + _pw + 64, _py + _ph, true);
	
	var _text = "Enter project name:";
	if (delete_warning){
		_text = $"Delete {projects_list[selected_project]}?";
	}
	
	draw_set_halign(fa_center);
	draw_text((_px + _pw / 2), _py - 20, _text);
	draw_set_valign(fa_middle);
	
		if (delete_warning){
			draw_text(_px + _pw / 2, _py + _ph / 2 - 1, "Y/N");
			draw_set_valign(fa_top);
			draw_set_halign(fa_left);
			exit;
		}
	
	draw_set_halign(fa_left);
		draw_text(_px - 64 + char_w + 4, _py + _ph / 2 - 1, new_project_name);
		draw_text(_px - 64 + (new_project_name_char * char_w + (char_w / 2)) + 4, _py + _ph / 2 - 2, $"{line_col % 2 ? "|" : ""}");
	draw_set_valign(fa_top);
}