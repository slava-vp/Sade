#macro	SADE_LANG_VER "0.0.8"
#macro	EDITOR_VER "0.0.3"

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

function console_log(_text){
	var _console = noone;
	with(obj_console){
		_console = id;
		break;
	}
	if (_console == noone){
		_console = instance_create_depth(10, 10, 9999, obj_console);
	}
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
	"#include",
	"#set",
];

global.Functions = [
	"print",
];