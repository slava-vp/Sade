function lexer(_str, _show_output = true){
	_str += " ";
	
	lexer_error = function(_error, _harmless = true){
		var _text = $"LEXER: {_error}";
		
		error(_text, (!_harmless ? errorType.ERROR : errorType.INFO));
		
		if (!_harmless)
			lexer_stop = true;
	}
	
	if (_show_output){
		show_debug_message("\nLexer Start ===========");
		
		show_debug_message($"string1: {_str}");
	}
	
	strings = array_create(10, "");
	strings_count = 0;
	
	var _str_len = string_length(_str);
	
	var _in_string = false;
	var _string_start = -1;
	
	var _ch;
	for(var i = 1; i < _str_len; i++){
		_ch = string_char_at(_str, i);
		
		if (_in_string && _ch != "'"){
			strings[strings_count] += _ch;
		}
		
		if (_ch == "'"){
			_in_string = !_in_string;
			
			if (!_in_string) {
				strings_count++;
				
				if (_string_start != -1){
					_str = string_replace(_str, string_copy(_str, _string_start, i - _string_start + 1), "lexerpasteherestring");
					
					_string_start = -1;
					_str_len = string_length(_str);
				}
			}
			
			if (_in_string) _string_start = i;
		}
	}
	
	if (_in_string == true){
		lexer_error("Unexpected end of line", false);
	}
	
	
	str = _str;
	var _spaces = ["|", "(", ")", "{", "}", "[", "]", ";", ":", "\"", "\'", ",", ".", "<", ">", "/", "\\", "?", "!", "@", "#", "$", "%", "^", "&", "*", "-", "+", "="];
	var _len = array_length(_spaces);
	
	for(var i = 0; i < _len; i++){
		str = string_replace_all(str, _spaces[i], $" {_spaces[i]} ");
	}
	
	if (_show_output) show_debug_message($"string2:  {_str}");
	lexer_stop = false;
	
	tokenizer = function(){
		_words = string_split(str, " ", true);
		_len = array_length(_words);
		
		_tokens = [];
		
		get_next_token = function(_nt = 1){
			if (curr + _nt >= _len){
				lexer_error("undefined next token");
				return "";
			}
			
			return _words[curr + _nt];
		}
		get_prev_token = function(_nt = 1){
			if (curr - _nt < 0){
				lexer_error("undefined prev token");
				return "";
			}
			
			return _words[curr - _nt];
		}
		
		var _token_id;
		var _token_value;
		curr = 0;
		
		for(; curr < _len; curr++){
			if (lexer_stop) exit;
			
			_token_id = -1;
			_token_value = _words[curr];
			
			var _nt = get_next_token();
			
			switch(_token_value){
				case "lexerpasteherestring":
					_token_id = tokenID.Value;
					
					_token_value = $"'{strings[0]}'";
					array_delete(strings, 0, -1);
					
					break;
				case "|":
					_token_id = tokenID.Or;
					
					if (_nt == "|"){
						_token_id = tokenID.Operator;
						_token_value = "||";
						
						array_delete(_words, curr + 1, -1);
						_len--;
					}
					
					break;
					
				case "(":
					_token_id = tokenID.Rbracket_L;
					
					break;
					
				case ")":
					_token_id = tokenID.Rbracket_R;
					
					break;
					
				case "{":
					_token_id = tokenID.Bracket_L;
					
					break;
					
				case "}":
					_token_id = tokenID.Bracket_R;
					
					break;
					
				case "[":
					_token_id = tokenID.Sbracket_L;
					
					break;
					
				case "]":
					_token_id = tokenID.Sbracket_R;
					
					break;
				case ";":
				
					_token_id = tokenID.Semicolon;
					
					break;
					
				case ":":
					_token_id = tokenID.Colon;
					
					break;
					
				case ".":
					_token_id = tokenID.Dot;
					
					break;
					
				case ",":
					_token_id = tokenID.Comma;
					
					break;
					
				case "\"":
					_token_id = tokenID.Double_Quotes;
					
					break;
					
				case "\'":
					_token_id = tokenID.Quotes;
					
					if (_nt == "="){
						_token_id = tokenID.Binary;
						_token_value = "/=";
						
						array_delete(_words, curr + 1, -1);
						_len--;
					}
					
					break;
					
				case "-":
					_token_id = tokenID.Minus;
					
					var _pt = get_prev_token();
					
					if (_nt == "="){
						_token_id = tokenID.Binary;
						_token_value = "-=";
						
						array_delete(_words, curr + 1, -1);
						_len--;
					}else
					if (_nt == "-"){
						_token_id = tokenID.Unar;
						_token_value = "--";
						
						array_delete(_words, curr + 1, -1);
						_len--;
					}else
					if (!token_is(_pt, global.Operator) && token_is_variable(_nt)){
						_token_id = tokenID.Unar;
					}
					
					break;
					
				case "+":
					_token_id = tokenID.Plus;
					
					if (_nt == "="){
						_token_id = tokenID.Binary;
						_token_value = "+=";
						
						array_delete(_words, curr + 1, -1);
						_len--;
					}
					
					if (_nt == "+"){
						_token_id = tokenID.Unar;
						_token_value = "++";
						
						array_delete(_words, curr + 1, -1);
						_len--;
					}
					
					break;
					
				case ">":
					_token_id = tokenID.More;
					
					if (_nt == "="){
						_token_id = tokenID.Operator;
						_token_value = ">=";
						
						array_delete(_words, curr + 1, -1);
						_len--;
					}
					
					break;
					
				case "<":
					_token_id = tokenID.Less;
					
					if (_nt == "="){
						_token_id = tokenID.Operator;
						_token_value = "<=";
						
						array_delete(_words, curr + 1, -1);
						_len--;
					}
					
					break;
					
				case "^":
					_token_id = tokenID.Power;
					
					if (_nt == "="){
						_token_id = tokenID.Binary;
						_token_value = "^=";
						
						array_delete(_words, curr + 1, -1);
						_len--;
					}
					
					break;
					
				case "*":
					_token_id = tokenID.Mult;
					
					if (_nt == "="){
						_token_id = tokenID.Binary;
						_token_value = "*=";
						
						array_delete(_words, curr + 1, -1);
						_len--;
					}
					
					break;
					
				case "%":
					_token_id = tokenID.Percent;
					
					if (_nt == "="){
						_token_id = tokenID.Operator;
						_token_value = "%=";
						
						array_delete(_words, curr + 1, -1);
						_len--;
					}
					
					break;
					
				case "=":
					_token_id = tokenID.Equal;
					
					if (_nt == "="){
						_token_id = tokenID.Operator;
						_token_value = "==";
						
						array_delete(_words, curr + 1, -1);
						_len--;
					}
					
					break;
					
				case "/":
					_token_id = tokenID.Slash;
					
					if (_nt == "="){
						_token_id = tokenID.Binary;
						_token_value = "/=";
						
						array_delete(_words, curr + 1, -1);
						_len--;
					}
					
					if (_nt == "/"){
						_token_id = tokenID.Comment;
						_token_value = "//";
						
						if (get_next_token(2) == "="){
							_token_id = tokenID.Operator;
							_token_value = "//=";
						}
						
						array_delete(_words, curr + 1, -1);
						_len--;
					}
					
					break;
					
				case "\\":
					_token_id = tokenID.Slash_Back;
					
					break;
					
				case "?":
					_token_id = tokenID.Question;
					
					break;
					
				case "!":
					_token_id = tokenID.Exclamation;
					
					var _pt = get_prev_token();
					
					if (_nt == "="){
						_token_id = tokenID.Binary;
						_token_value = "!=";
						
						array_delete(_words, curr + 1, -1);
						_len--;
					}else
					if (!token_is(_pt, global.Operator) && token_is_variable(_nt)){
						_token_id = tokenID.Unar;
					}
					
					break;
					
				case "@":
					_token_id = tokenID.Dog;
					
					break;
					
				case "&":
					_token_id = tokenID.Ampersand;
					
					if (_nt == "&"){
						_token_id = tokenID.Operator;
						_token_value = "&&";
						
						array_delete(_words, curr + 1, -1);
						_len--;
					}
					
					break;
					
				case "#":
					_token_id = tokenID.Sharp;
					
					break;
					
				case "$":
					_token_id = tokenID.Dollar;
					
					break;
					
				case "_":
					_token_id = tokenID.Underscore;
					
					break;
					
				default:
					if (token_is(_token_value, global.Functions)){
						_token_id = tokenID.Function;
					}else
					if (token_is(_token_value, global.Keywords)){
						_token_id = tokenID.Keyword;
					}else
					if (token_is(_token_value, global.Operator)){
						_token_id = tokenID.Operator;
					}else
					if (token_is(_token_value, global.Unar)){
						_token_id = tokenID.Unar;
					}else
					if (token_is_value(_token_value)){
						_token_id = tokenID.Value;
					}else{
						_token_id = tokenID.Variable;
						
						if (_nt == "(")
							_token_id = tokenID.Function;
					}
					
					break;
			}
			
			array_push(_tokens, new token(_token_id, _token_value));
		}
		
		return _tokens;
	}
	
	var _tokens = tokenizer();
	
	if (_show_output){
		show_debug_message(_tokens);
		
		show_debug_message("Lexer End ============\n");
	}
	
	return _tokens;
}