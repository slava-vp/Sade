function token(_id, _val) constructor{
	id = _id;
	val = _val;
}

enum tokenID{
	Keyword			,
	Function		,
	Value			,
	Variable		,
	
	Unar			,	// for !var, -var, var++, var--, ++var, --var
	Binary			,	// for +=, *=, -=, /=, ^=
	Operator		,	// for ==, <=, >=, !=, >>, <<
	
	Comment			,	// //
	
	Rbracket_L		,	// (
	Rbracket_R		,	// )
	Bracket_L		,	// {
	Bracket_R		,	// }
	Sbracket_L		,	// [
	Sbracket_R		,	// ]
	Semicolon		,	// ;
	Colon			,	// :
	Dot				,	// .
	Comma			,	// ,
	Double_Quotes	,	// "
	Quotes			,	// '
	Minus			,	// -
	Plus			,	// +
	More			,	// >
	Less			,	// <
	Power			,	// ^
	Mult			,	// *
	Percent			,	// %
	Equal			,	// =
	Slash			,	// /
	Slash_Back		,	// \
	Question		,	// ?
	Exclamation		,	// !
	Dog				,	// @
	Ampersand		,	// &
	Sharp			,	// #
	Dollar			,	// $
	Underscore		,	// _
	Or				,	// |
}

function token_is(_tok, _is){
	var _len = array_length(_is);
	
	for(var i = 0; i < _len; i++){
		if (_tok == _is[i]) return true;
	}
	
	return false;
}

function token_is_real(_tok, _return_firse = false){
	var _len = string_length(_tok);
	var _digits = "0123456789";
	var _end = (_return_firse == false ? _len : 1);
	
	for(var i = 1; i <= _end; i++){
		var _ch = string_char_at(_tok, i);
		if (string_pos(_ch, _digits) == 0) return false;
	}
	return true;
}

function token_is_string(_tok){
	var _ch1 = string_char_at(_tok, 1);
	var _ch2 = string_char_at(_tok, string_length(_tok) + 1);
	
	return (_ch1 == "'" && _ch2 == "'");
}

function token_is_variable(_tok){
	if (token_is_real(_tok, true)) return false;
	return true;
}

function token_is_value(_tok){
	if (_tok == "") return false;
	
	var _is_string = token_is_string(_tok);
	show_debug_message($"token_is_value({_tok}): _is_string={_is_string}");
	
	var _is_real = token_is_real(_tok);
	show_debug_message($"token_is_value({_tok}): _is_real={_is_real}");
	
	return (_is_real || _is_string);
}