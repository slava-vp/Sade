function VMachine(_bytecode){
	bytecode = _bytecode;
	len = array_length(bytecode);
	
	stack = [];
	call_stack = [];
	memory = ds_map_create();
	
	curr = 0;
	
	label_map = ds_map_create();
	for(var i = 0; i < len; i++){
		if (bytecode[i][0] == opCode.LABEL)
			label_map[? bytecode[i][1]] = i;
	}
	
	jump_to_label = function(_label){
		if (ds_map_exists(label_map, _label))
			curr = label_map[? _label];
		else
			error($"Label '{_label}' not found", errorType.CRITICAL);
	}
	
	show_memory = function(){
		var _str = "";
		
		var _keys = ds_map_keys_to_array(memory);
		var _len = array_length(_keys);
		
		for(var i = 0; i < _len; i++){
			_str += $"{_keys[i]}: {memory[? _keys[i]]}\n";
		}
		
		console_log($"\nMemory=======\n{_str}Memory end===\n");
	}
	
	builtin_functions = ds_map_create();
	builtin_functions[? "print"] = function(_args){
		array_foreach(_args, function(value, index){ console_log(value); });
	}
	
	string_methods = ds_map_create();
	string_methods[? "cat"] = function(_str, _args){
		var _len = array_length(_args);
	
		for(var i = 0; i < _len; i++){
			_str += $"{_args[i]}";
		}
	
		return _str;
	}
	string_methods[? "len"] = function(_str, _args){
		return string_length(_str);
	}
	string_methods[? "cp"] = function(_str, _args){
		return string_copy(_str, _args[0], _args[1]);
	}
	string_methods[? "ch"] = function(_str, _args){
		return string_char_at(_str, _args[0]);
	}
	string_methods[? "ins"] = function(_str, _args){
		return string_insert(_args[0], _str, _args[1]);
	}

	array_methods = ds_map_create();
	array_methods[? "push"] = function(_arr, _args){
		array_push(_arr, _args[0]);
	
		return _arr;
	}
	array_methods[? "pop"] = function(_arr, _args){
		array_pop(_arr);
		return _arr;
	}
	array_methods[? "last"] = function(_arr, _args){
		return _arr[array_length(_arr) - 1];
	}
	array_methods[? "len"] = function(_arr, _args){
		return array_length(_arr);
	}
	array_methods[? "ins"] = function(_arr, _args){
		array_insert(_arr, _args[0], _args[1]);
		return _arr;
	}
	array_methods[? "del"] = function(_arr, _args){
		array_delete(_arr, _args[0], _args[1]);
		return _arr;
	};
	
	console_log(">VMachine<");
	
	get_value = function(_val){
		if (is_array(_val) || is_struct(_val)) return _val;
		
		if (is_numeric(_val)) return real(_val);
		
		if (string_length(string_digits(_val)) == string_length(_val) && _val != ""){
				return real(_val);
		}

		if (is_string(_val) && string_length(_val) >= 2){
			if (string_char_at(_val, 1) == "'" && string_char_at(_val, string_length(_val)) == "'"){
				return string_copy(_val, 2, string_length(_val) - 2); 
			}
		}
		
		if (token_is_variable(_val)){
			if (ds_map_exists(memory, _val)){	
				return memory[? _val];
			}else{
				if (is_string(_val)){
					return _val;
				}
				
				if (!token_is_value(_val)){
					if (global.Settings.use_0_as_default){
						error($"The variable '{_val}' was not created prior to use.\nThe default value '0' is used.", errorType.WARNING);
						
						return 0;
					}else
						error($"Variable '{_val}' not found", errorType.CRITICAL);
				}
			}
		}
		
		if (string_length(string_digits(_val)) == string_length(_val))
			return real(_val);
		
		return _val;
	}
	
	for(curr = 0; curr < len; curr++){
		var _instruction = bytecode[curr];
		
		var _operator = _instruction[0];
		
		switch(_operator){
			case opCode.PUSH:
				var _val = _instruction[1];
				
				array_push(stack, _val);
				
				break;
			
			case opCode.POP:
				array_pop(stack);
				
				break;
			
			case opCode.STORE:
				var _name = _instruction[1];
				
				var _val = array_pop(stack);
				
				memory[? _name] = _val;
				
				break;
			
			case opCode.LOAD:
				var _name = _instruction[1];
				
				var _val = get_value(_name);
				
				array_push(stack, _val);
				
				break;
			
			case opCode.JUMP:
				var _label = _instruction[1];
				
				jump_to_label(_label);
				
				break;
			
			case opCode.JUMP_IF_FALSE:
				var _value = array_pop(stack);
				
				var _loaded_value = get_value(_value);
				
				if (!_loaded_value){
					var _label = _instruction[1];
					
					jump_to_label(_label);
				}
				
				break;
			
			case opCode.EXECUTE:
				var _func_name = _instruction[1];
				
				var _args_count = _instruction[2];
				
				var _args = [];
				
				for(var i = 0; i < _args_count; i++){
					var _arg = array_pop(stack);
					array_push(_args, _arg);
				}
				
				if (ds_map_exists(builtin_functions, _func_name))
					builtin_functions[? _func_name](_args);
				else
					error($"Builtin Function '{_func_name}' not found", errorType.CRITICAL);
				
				break;
			
			case opCode.CALL:
				var _func_name = _instruction[1];
				
				var _args_count = _instruction[2];
				
				var _func_obj = get_value(_func_name);
				
				if (!is_struct(_func_obj))
					error($"User-defined Function '{_func_name}' not found", errorType.CRITICAL);
				
				var _args = [];
				
				for(var i = 0; i < _args_count; i++){
					var _arg = array_pop(stack);
					array_push(_args, _arg);
				}
				
				_func_obj[$ "stack"] = [];
				ds_map_clear(_func_obj[$ "memory"]);
				
				var _params_len = array_length(_func_obj[$ "params"]);
				
				for(var i = 0; i < _params_len; i++){
					var _param_name = _func_obj[$ "params"][i];
					var _param_val = (i < array_length(_args) ? _args[i] : undefined);
					
					_func_obj[$ "memory"][? _param_name] = _param_val;
				}
				
				array_push(call_stack, {
					return_curr: curr,
					caller_stack: stack,
					caller_memory: memory,
					func_obj: _func_obj
				});
				
				stack = _func_obj[$ "stack"];
				memory = _func_obj[$ "memory"];
				
				jump_to_label(_func_obj[$ "start_label"]);
				
				break;
			
			case opCode.METHOD:
				var _method = _instruction[1];
				var _args_count = _instruction[2];
				var _args = [];
				
				for(var i = 0; i < _args_count; i++){
					_args = array_concat([get_value(array_pop(stack))], _args);
				}
				
				var _obj = get_value(array_pop(stack));
				var _methods = undefined;
				
				if (is_string(_obj)){
					_methods = string_methods;
				}else if (is_array(_obj)){
					_methods = array_methods;
				}
				
				if (_methods != undefined && ds_map_exists(_methods, _method)){
					var _result = _methods[? _method](_obj, _args);
					array_push(stack, _result);
				}else
					error($"Unknown method '{_method}' forthis type", errorType.CRITICAL);
				
				break;
			
			case opCode.RETURN:
				var _return_val = undefined;
				
				if (array_length(stack) > 0)
					_return_val = get_value(array_pop(stack));
				
				if (array_length(call_stack) > 0){
					var _frame = array_pop(call_stack);
					_frame[$ "func_obj"][$ "return_value"] = _return_val;
					
					stack = _frame[$ "caller_stack"];
					memory = _frame[$ "caller_memory"];
					
					array_push(stack, _return_val);
					curr = _frame[$ "return_curr"];
				}else{
					curr = len;
				}
				
				break;
			
			case opCode.LABEL:
				
				break;
			
			case opCode.ADD:
				var b_raw = array_pop(stack);
				var a_raw = array_pop(stack);
				
				var b = get_value(b_raw);
				var a = get_value(a_raw);
				
				array_push(stack, a + b);
				
				break;
			
			case opCode.SUB:
				var b_raw = array_pop(stack);
				var a_raw = array_pop(stack);
				
				var b = get_value(b_raw);
				var a = get_value(a_raw);
				
				array_push(stack, a - b);
				
				break;
			
			case opCode.MUL:
				var b_raw = array_pop(stack);
				var a_raw = array_pop(stack);
				
				var b = get_value(b_raw);
				var a = get_value(a_raw);
				
				array_push(stack, a * b);
				
				break;
			
			case opCode.DIV:
				var b_raw = array_pop(stack);
				var a_raw = array_pop(stack);
				
				var b = get_value(b_raw);
				var a = get_value(a_raw);
				
				array_push(stack, a / b);
				
				break;
			
			case opCode.IDIV:
				var b_raw = array_pop(stack);
				var a_raw = array_pop(stack);
				
				var b = get_value(b_raw);
				var a = get_value(a_raw);
				
				array_push(stack, a div b);
				
				break;
			
			case opCode.POW:
				var b_raw = array_pop(stack);
				var a_raw = array_pop(stack);
				
				var b = get_value(b_raw);
				var a = get_value(a_raw);
				
				array_push(stack, power(a, b));
				
				break;
			
			case opCode.AND:
				var b_raw = array_pop(stack);
				var a_raw = array_pop(stack);
				
				var b = get_value(b_raw);
				var a = get_value(a_raw);
				
				array_push(stack, a && b);
				
				break;
			
			case opCode.REM:
				var b_raw = array_pop(stack);
				var a_raw = array_pop(stack);
				
				var b = get_value(b_raw);
				var a = get_value(a_raw);
				
				array_push(stack, a % b);
				
				break;
				
			case opCode.OR:
				var b_raw = array_pop(stack);
				var a_raw = array_pop(stack);
				
				var b = get_value(b_raw);
				var a = get_value(a_raw);
				
				array_push(stack, a || b);
				
				break;
			
			case opCode.COMPARE:
				var _op = _instruction[1];
				
				var b_raw = array_pop(stack);
				var a_raw = array_pop(stack);
				
				var b = get_value(b_raw);
				var a = get_value(a_raw);
				
				switch(_op){
					case "==": array_push(stack, a == b); break;
					case "!=": array_push(stack, a != b); break;
					case ">=": array_push(stack, a >= b); break;
					case "<=": array_push(stack, a <= b); break;
					case ">": array_push(stack, a > b); break;
					case "<": array_push(stack, a < b); break;
				}
				
				break;
			
			case opCode.ARRAY_CREATE:
				var _len = _instruction[1];
				
				var _arr = [];
				
				for(var i = _len - 1; i >= 0; i--){
					_arr[i] = array_pop(stack);
				}
				
				array_push(stack, _arr);
				
				break;
			
			case opCode.ARRAY_GET:
				var _index = get_value(array_pop(stack));
				
				var _arr = array_pop(stack);
	
				if (array_length(_arr) == 0){
					error("Cannot access element of empty array");
					break;
				}
	
				_index = _index % array_length(_arr);
				
				if (_index < 0) _index += array_length(_arr);
	
				array_push(stack, _arr[_index]);
				
				break;

			case opCode.ARRAY_SET:
				var _value = get_value(array_pop(stack));
				
				var _index = get_value(array_pop(stack));
				
				var _arr = array_pop(stack);
	
				if (_index >= array_length(_arr)){
					while(array_length(_arr) <= _index){
						array_push(_arr, 0);
					}
				}
	
				_arr[_index] = _value;
				
				array_push(stack, _arr);
				
				break;
			
			case opCode.ARRAY_LEN:
				var _arr = array_pop(stack);
				
				array_push(stack, array_length(_arr));
				
				break;
			
			case opCode.JUMP_IF_TRUE:
				var _value = array_pop(stack);
				
				var _loaded_value = get_value(_value);
				
				if (_loaded_value){
					var _label = _instruction[1];
					
					jump_to_label(_label);
				}
				
				break;
			
			case opCode.DUP:
				var _val = array_pop(stack);
				
				array_push(stack, _val, _val);
				
				break;
			
			case opCode.DELETE:
				var _name = _instruction[1];
				
				ds_map_delete(memory, _name);
				
				break;
			
			case opCode.BREAK:
			case opCode.CONTINUE:
				jump_to_label(_instruction[1]);
				
				break;
			
			case opCode.HALT:
				curr = len;
				
				break;
		}
	}
	
	show_memory();
	
	ds_map_destroy(label_map);
	ds_map_destroy(builtin_functions);
	ds_map_destroy(memory);
	ds_map_destroy(string_methods);
	ds_map_destroy(array_methods);
	stack = -1;
	
	console_log(">VMachine<\n");
	return 0;
}