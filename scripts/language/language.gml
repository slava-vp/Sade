#macro	SADE_LANG_VER "0.0.7"
#macro	EDITOR_VER "0.0.1"

enum EditorMode {
	full_editor,
	single_line,
	popup_input,
}

function run(_code){
	var _tokens = lexer(_code);
	var _bytecode = parser(_tokens);
	VMachine(_bytecode);
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
];

global.Functions = [
	"print",
];