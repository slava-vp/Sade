function checker(_tokens, _code){
	_len = array_length(_tokens);
	_errors = [];
	_defined_vars = ds_map_create();
	_defined_funcs = ds_map_create();
	_array_sizes = ds_map_create();
	
	var _flen = array_length(global.Functions);
	for(var i = 0; i < _flen; i++){
		_defined_funcs[? global.Functions[i]] = {params: -1};
	}
	
	_line = 1;
	_curr = 0;
	
	next = function(){
		if (_curr < _len) _curr++;
	}
	
	get_token = function(){
		if (_curr >= _len) return undefined;
		return _tokens[_curr];
	}
	
	get_val = function(){
		var _t = get_token();
		return _t != undefined ? _t[$ "val"] : "";
	}
	
	get_id = function(){
		var _t = get_token();
		return _t != undefined ? _t[$ "id"] : -1;
	}
	
	add_error = function(_msg){
		var _l = (_curr < _len) ? _tokens[_curr][$ "line"] : _line;
		array_push(_errors, $"Line {_l}: {_msg}");
	}
	
	while(_curr < _len){
		var _id = get_id();
		var _val = get_val();
		
		if (_id == tokenID.Keyword){
			if (_val == "var"){
				next();
				var _name = get_val();
				next();
	
				if (get_val() == "["){
					var _count = 0;
					var _depth = 1;
					next();
	
					while(_curr < _len && _depth > 0){
						if (get_val() == "[") _depth++;
						if (get_val() == "]") _depth--;
						if (_depth == 0) break;
						if (_depth == 1 && get_id() == tokenID.Value) _count++;
						next();
					}
					_array_sizes[? _name] = _count;
					next();
				}
	
				_defined_vars[? _name] = true;
				continue;
			}
			
			if (_val == "func"){
				next();
				var _name = get_val();
				next();
				next();
				
				var _params = [];
				while(get_val() != ")"){
					if (get_val() != ","){
						array_push(_params, get_val());
					}
					next();
				}
				next();
				
				_defined_funcs[? _name] = {params: array_length(_params)};
				_defined_vars[? _name] = true;
				
				if (get_val() == "{"){
					var _depth = 1;
					next();
					while(_curr < _len && _depth > 0){
						if (get_val() == "{") _depth++;
						if (get_val() == "}") _depth--;
						if (_depth > 0) next();
					}
					next();
				}
				continue;
			}
			
			if (_val == "return"){
				next();
				while(_curr < _len && get_val() != "}" && get_val() != ";"){
					next();
				}
				continue;
			}
		}
		
		if (_id == tokenID.Variable){
			var _var_name = _val;
	
			if (!ds_map_exists(_defined_vars, _var_name)){
				add_error($"Variable '{_var_name}' used before definition");
			}
	
			if (_curr + 1 < _len && _tokens[_curr + 1][$ "val"] == "["){
				if (ds_map_exists(_array_sizes, _var_name)){
					var _size = _array_sizes[? _var_name];
		
					var _check_curr = _curr + 2;
					if (_check_curr < _len && _tokens[_check_curr][$ "id"] == tokenID.Value && is_numeric(_tokens[_check_curr][$ "val"])){
						var _idx = real(_tokens[_check_curr][$ "val"]);
						if (_idx < 0 || _idx >= _size){
							add_error($"Index {_idx} out of bounds for array '{_var_name}' (size {_size})");
						}
					}
				}
			}
		}
		
		if (_id == tokenID.Function){
			var _func_name = _val;
			
			if (!ds_map_exists(_defined_funcs, _func_name)){
				add_error($"Function '{_func_name}' not defined");
			}
		}
		
		next();
	}
	
	if (array_length(_errors) > 0){
		for(var i = 0; i < array_length(_errors); i++){
			console_log(_errors[i]);
		}
		
		ds_map_destroy(_defined_vars);
		ds_map_destroy(_defined_funcs);
		ds_map_destroy(_array_sizes);
		return false;
	}
	
	ds_map_destroy(_defined_vars);
	ds_map_destroy(_defined_funcs);
	ds_map_destroy(_array_sizes);
	return true;
}