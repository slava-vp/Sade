function VMachine(_bytecode){
	bytecode = _bytecode;
	len = array_length(bytecode);
	
	stack = [];
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
		
		show_debug_message($"\nMemory=======\n{_str}Memory end===\n");
	}
	
	builtin_functions = ds_map_create();
	builtin_functions[? "print"] = function(_args){
		array_foreach(_args, function(value, index){ show_debug_message(value); });
	}
	
	show_debug_message(">VMachine<");
	
	get_value = function(_val){
		if (is_numeric(_val)) return real(_val);
		
		if (token_is_variable(_val)){
			if (ds_map_exists(memory, _val)){	
				return memory[? _val];
			}else{
				if (!token_is_value(_val)){
					if (USE_0_AS_THE_DEFAULT_VALUE_FOR_VARIABLES){
						error("The variable was not created prior to use.\nThe default value '0' is used.", errorType.WARNING);
						
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
					error($"Function '{_func_name}' not found", errorType.CRITICAL);
				
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
				//show_message(b_raw);
				//show_message(a_raw);
				
				var b = get_value(b_raw);
				var a = get_value(a_raw);
				//show_message(b);
				//show_message(a);
				array_push(stack, a * b);
				
				break;
			
			case opCode.DIV:
				var b_raw = array_pop(stack);
				var a_raw = array_pop(stack);
				
				var b = get_value(b_raw);
				var a = get_value(a_raw);
				
				array_push(stack, a / b);
				
				break;
			
			case opCode.POW:
				var b_raw = array_pop(stack);
				var a_raw = array_pop(stack);
				
				var b = get_value(b_raw);
				var a = get_value(a_raw);
				
				array_push(stack, power(a, b));
				
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
			
			case opCode.JUMP_IF_TRUE:
				var _value = array_pop(stack);
				
				var _loaded_value = get_value(_value);
				
				if (_loaded_value){
					var _label = _instruction[1];
					
					jump_to_label(_label);
				}
				
				break;
			
			case opCode.BREAK:
			case opCode.CONTINUE:
				jump_to_label(_instruction[1]);
				
				break;
			
			case opCode.RETURN:
			case opCode.HALT:
				curr = len;
				
				break;
		}
	}
	
	ds_map_destroy(label_map);
	ds_map_destroy(memory);
	stack = -1;
	
	show_debug_message(">VMachine<\n");
	return 0;
}

global.Operator = [
	"+",
	"-",
	"/",
	"*",
	"^",
	"%",
];

global.Unar = [
	"!",
	"++",
	"--"
];

global.Keywords = [
	"var",
	"if",
	"else",
];

global.Functions = [
	"print",
];

function token_is(_tok, _is){
	var _len = array_length(_is);
	
	for(var i = 0; i < _len; i++){
		if (_tok == _is[i]) return true;
	}
	
	return false;
}

function token_is_real(_tok, _return_firse = false){
	var _len = string_length(_tok);
	var _digits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
	var _len_2 = array_length(_digits);
	
	for(var i = 1; i < (_return_firse == false ? _len : 3); i++){
		for(var j = 0; j < _len_2; j++){
			if (string_char_at(_tok, i) != _digits[j]) return false;
		}
	}
	return true;
}

function token_is_string(_tok){
	var _ch1 = string_char_at(_tok, 1);
	var _ch2 = string_char_at(_tok, string_length(_tok) + 1);
	
	var _tok1 = (_ch1 == "'" || _ch1 == "\"");
	var _tok2 = (_ch2 == "'" || _ch2 == "\"");
	
	return (_tok1 && _tok2);
}

function token_is_variable(_tok){
	var _first_is_digit = token_is_real(_tok, true);
	
	if (!_first_is_digit) return true;
}

function token_is_value(_tok){
	var _is_string = token_is_string(_tok);
	
	var _dig = string_digits(_tok);
	
	var _is_real = false;
	if (string_length(_dig) == string_length(_tok)){
		_is_real = is_real(real(_tok));
	}
	
	return (_is_real || _is_string);
}