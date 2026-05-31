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