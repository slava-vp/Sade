function Preprocessor(_lines, _first = true){
	if (_first){
		if (variable_global_exists("included_files")){
			ds_map_destroy(global.included_files);
		}
		
		global.included_files = ds_map_create();
	}
	
	var _len = array_length(_lines);
	var _output = [];
	
	var _line = "";
	for(var i = 0; i < _len; i++){
		_line = string_trim(_lines[i]);
		
		if (_line == "") continue;
		if (string_pos("//", _line) == 1) continue;
		
		if (string_pos("#include ", _line)){
			var _split = string_split(_line, "'", true);
			
			var _file = $"{global.projects_dir}{obj_file_manager.project_name}/{_split[1]}";
			
			if (ds_map_exists(global.included_files, _file)){
				continue;
			}
			
			if (file_exists(_file)){
				var _f = file_text_open_read(_file);
				var _included_lines = [];
				var _has_once = false;
				
				while(!file_text_eof(_f)){
					var _fline = file_text_read_string(_f);
					file_text_readln(_f);
					_fline = string_replace_all(_fline, "\r", "");
					_fline = string_replace_all(_fline, "\n", "");
					
					if (string_pos("#include once", string_trim(_fline)) == 1){
						_has_once = true;
						continue;
					}
					
					array_push(_included_lines, _fline);
				}
				
				file_text_close(_f);
				
				if (global.Settings.use_auto_include_once){
					_has_once = true;
				}
				
				if (_has_once){
					ds_map_add(global.included_files, _file, true);
				}
				
				var _processed = Preprocessor(_included_lines, false);
				for(var j = 0; j < array_length(_processed); j++){
					array_push(_output, _processed[j]);
				}
			}else{
				error($"Include file {_file} not found", errorType.CRITICAL);
			}
			
			continue;
		}
		
		if (string_pos("#set auto_include_once on", _line)){
			global.Settings.use_auto_include_once = true;
			continue;
		}
		if (string_pos("#set auto_include_once off", _line)){
			global.Settings.use_auto_include_once = false;
			continue;
		}
		if (string_pos("#set unknown_is_zero on", _line)){
			global.Settings.use_0_as_default = true;
			continue;
		}
		if (string_pos("#set unknown_is_zero off", _line)){
			global.Settings.use_0_as_default = false;
			continue;
		}
		
		array_push(_output, _line);
	}
	
	return _output;
}