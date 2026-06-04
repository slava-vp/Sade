function Preprocessor(_lines){
	var _len = array_length(_lines);
	var _output = [];
	
	var _line = "";
	for(var i = 0; i < _len; i++){
		_line = string_trim(_lines[i]);
		
		if (_line == "") continue;
		if (string_pos("//", _line) == 1) continue;
		
		if (string_pos("#include ", _line) > 0){
			var _split = string_split(_line, "'", true);
			
			var _file = $"{global.projects_dir}{obj_file_manager.project_name}/{_split[1]}";
			if (file_exists(_file)){
				var _f = file_text_open_read(_file);
				var _included_lines = [];
				
				while(!file_text_eof(_f)){
					var _fline = file_text_read_string(_f);
					file_text_readln(_f);
					_fline = string_replace_all(_fline, "\r", "");
					_fline = string_replace_all(_fline, "\n", "");
					array_push(_included_lines, _fline);
				}
				
				file_text_close(_f);
				
				var _processed = Preprocessor(_included_lines);
				for(var j = 0; j < array_length(_processed); j++){
					array_push(_output, _processed[j]);
				}
			}else{
				error($"Include file {_file} not found", errorType.CRITICAL);
			}
			
			continue;
		}
		
		array_push(_output, _line);
	}
	
	return _output;
}