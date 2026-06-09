#macro	SADE_LANG_VER "0.8"
#macro	EDITOR_VER "0.3"

enum EditorMode {
	full_editor,
	single_line,
	popup_input,
}

function run(_code){
	if (global.Settings.internal_error_log){
		try{
			var _tokens = lexer(_code);
			
			var _bytecode = parser(_tokens, true);
			VMachine(_bytecode);
		}catch(_error){
			console_log($"{_error.message}");
		}
	}else{
		var _tokens = lexer(_code);
		var _bytecode = parser(_tokens, true);
		VMachine(_bytecode);
	}
}

function console_check(){
	var _console = noone;
	with(obj_console){
		_console = id;
		break;
	}
	if (_console == noone){
		_console = instance_create_depth(10, 10, 9999, obj_console);
	}
	
	return _console;
}

function console_log(_text){
	var _console = console_check();
	
	with(_console){
		if (!window.visible) window.show();
		add_line(string(_text));
	}
	show_debug_message(_text);
}

global.Operator = [
	"+",
	"-",
	"/",
	"*",
	"^",
	"%",
];

global.Binury = [
	"+=",
	"-=",
	"/=",
	"//=",
	"*=",
	"^=",
	"%=",
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
	"func",
	"return",
	"for",
	"continue",
	"break",
	"#include",
	"#set",
];

global.Functions = [
	"print",
	"chr",
];

global.string_methods = ds_map_create();
global.string_methods[? "cat"] = function(_str, _args){
	var _len = array_length(_args);

	for(var i = 0; i < _len; i++){
		_str += $"{_args[i]}";
	}

	return _str;
}
global.string_methods[? "len"] = function(_str, _args){
	var _s = _str;
	if (string_char_at(_s, 1) == "'" && string_char_at(_s, string_length(_s)) == "'"){
		_s = string_copy(_s, 2, string_length(_s) - 2);
	}
	return string_length(_s);
}
global.string_methods[? "cp"] = function(_str, _args){
		return string_copy(_str, _args[0], _args[1]);
	}
global.string_methods[? "ch"] = function(_str, _args){
	var _s = _str;

	if (string_char_at(_s, 1) == "'" && string_char_at(_s, string_length(_s)) == "'"){
		_s = string_copy(_s, 2, string_length(_s) - 2);
	}
	var _idx = _args[0];
	if (_idx < 0 || _idx >= string_length(_s)) return "''";

	return $"'{string_char_at(_s, _idx + 1)}'";
}
global.string_methods[? "ins"] = function(_str, _args){
	return string_insert(_args[0], _str, _args[1]);
}
global.string_methods[? "split"] = function(_str, _args){
	return string_split(_str, _args[0]);
}
global.string_methods[? "upper"] = function(_str, _args){
	return string_upper(_str);
}
global.string_methods[? "lower"] = function(_str, _args){
	return string_lower(_str);
}
global.string_methods[? "trim"] = function(_str, _args){
	return string_trim(_str);
}
global.string_methods[? "replace"] = function(_str, _args){
	return string_replace_all(_str, _args[0], _args[1]);
}
global.string_methods[? "del"] = function(_str, _args){
	return string_delete(_str, _args[0], _args[1]);
}
global.string_methods[? "shuffle"] = function(_str, _args){
	var _len = string_length(_str);
	var _chars = [];
	
	for(var i = 1; i <= _len; i++){
		array_push(_chars, string_char_at(_str, i));
	}
	
	for(var i = 0; i < _len; i++){
		var _r = irandom_range(0, _len - 1);
		var _tmp = _chars[i];
		_chars[i] = _chars[_r];
		_chars[_r] = _tmp;
	}
	
	var _result = "";
	for(var i = 0; i < _len; i++){
		_result += _chars[i];
	}
	
	return _result;
}
global.string_methods[? "rev"] = function(_str, _args){
	var _result = "";
	var _len = string_length(_str);
	for(var i = _len; i >= 1; i--){
		_result += string_char_at(_str, i);
	}
	return _result;
}
global.string_methods[? "repeat"] = function(_str, _args){
	var _n = _args[0];
	var _result = "";
	for(var i = 0; i < _n; i++){
		_result += _str;
	}
	return _result;
}


global.array_methods = ds_map_create();
global.array_methods[? "push"] = function(_arr, _args){
	array_push(_arr, _args[0]);

	return _arr;
}
global.array_methods[? "pop"] = function(_arr, _args){
	array_pop(_arr);
	return _arr;
}
global.array_methods[? "last"] = function(_arr, _args){
	return _arr[array_length(_arr) - 1];
}
global.array_methods[? "len"] = function(_arr, _args){
	return array_length(_arr);
}
global.array_methods[? "ins"] = function(_arr, _args){
	array_insert(_arr, _args[0], _args[1]);
	return _arr;
}
global.array_methods[? "del"] = function(_arr, _args){
	array_delete(_arr, _args[0], _args[1]);
	return _arr;
}
global.array_methods[? "sort"] = function(_arr, _args){
	array_sort(_arr, true);
	return _arr;
}
global.array_methods[? "reverse"] = function(_arr, _args){
	return array_reverse(_arr);
}
global.array_methods[? "find"] = function(_arr, _args){
	var _val = _args[0];
	var _len = array_length(_arr);
	
	for(var i = 0; i < _len; i++){
		if (_arr[i] == _val) return i;
	}
	
	return -1;
}
global.array_methods[? "join"] = function(_arr, _args){
	var _sep = _args[0];
	var _result = "";
	var _len = array_length(_arr);
	for(var i = 0; i < _len; i++){
		_result += string(_arr[i]);
		if (i < _len - 1) _result += _sep;
	}
	return _result;
}
global.array_methods[? "clear"] = function(_arr, _args){
	return [];
}
global.array_methods[? "set_len"] = function(_arr, _args){
	array_resize(_arr, _args[0]);
	return _arr;
}
global.array_methods[? "create"] = function(_arr, _args){
	var _len = array_length(_args);
	var _val = 0;
	
	if (_len > 1){
		_val = _args[1];
	}
	
	return array_create(_args[0], _val ?? 0);
}
global.array_methods[? "cat"] = function(_arr, _args){
	var _len = array_length(_args);
	for(var i = 0; i < _len; i++){
		_arr = array_concat(_arr, _args[i]);
	}
	
	return _arr;
}
global.array_methods[? "shuffle"] = function(_arr, _args){
	return array_shuffle(_arr);
}
global.array_methods[? "min"] = function(_arr, _args){
	var _res = 0;
	var _len = array_length(_arr);
	
	for(var i = 0; i < _len; i++){
		if (_arr[i] < _res){
			_res = _arr[i];
		}
	}
	
	return _res;
}
global.array_methods[? "max"] = function(_arr, _args){
	var _res = 0;
	var _len = array_length(_arr);
	
	for(var i = 0; i < _len; i++){
		if (_arr[i] > _res){
			_res = _arr[i];
		}
	}
	
	return _res;
}
global.array_methods[? "unique"] = function(_arr, _args){
	return array_unique(_arr);
}
global.array_methods[? "sum"] = function(_arr, _args){
	var _sum = 0;
	var _len = array_length(_arr);
	
	for(var i = 0; i < _len; i++){
		_sum += _arr[i];
	}
	
	return _sum;
}
global.array_methods[? "avg"] = function(_arr, _args){
	var _sum = 0;
	var _len = array_length(_arr);
	
	for(var i = 0; i < _len; i++){
		_sum += _arr[i];
	}
	
	return _sum / _len;
}