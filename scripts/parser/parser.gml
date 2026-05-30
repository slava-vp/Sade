function parser(_tokens){
	tokens = _tokens;
	bytecode = [];
	len = array_length(tokens);
	curr = 0;
	
	next = function(){
		if (curr < len){
			curr++;
		}
	}
	
	get_token_id = function(){
		if (curr < len){
			return tokens[curr][$ "id"];
		}
	}
	get_token_val = function(){
		if (curr < len){
			return tokens[curr][$ "val"];
		}
	}
	
	label_count = 0;
	label_create = function(){
		return $"label_{++label_count}";
	}
	
	parse_var = function(){
		next();
		
		var _name = get_token_val();
		
		next();
		
		parse_expression();
		
		array_push(bytecode, [opCode.STORE, _name]);
	}
	
	parse_block = function(){
		if (get_token_val() != "{")
			error("Expected '{'", errorType.CRITICAL);
		
		next();
		
		while(curr < len && get_token_val() != "}"){
			parse_statement();
		}
		
		if (get_token_val() != "}")
			error("Expected '}'", errorType.CRITICAL);
		
		next();
	}
	
	parse_return = function(){
		next();
		
		if (get_token_val() != ";")
			parse_expression();
		else
			array_push(bytecode, [opCode.PUSH, undefined]);
		
		array_push(bytecode, [opCode.RETURN]);
		
		if (get_token_val() == ";")
			next();
	}
	
	parse_call = function(){
		var _func_name = get_token_val();
		
		next();
		
		if (get_token_val() != "(")
			error("Expected '(' after function name", errorType.CRITICAL);
		
		next();
		
		var _arg_count = 0;
		
		if (get_token_val() != ")")
			while(curr < len){
				parse_expression();
				
				_arg_count++;
				
				if (get_token_val() == ",")
					next();
				else
					break;
			}
		
		if (get_token_val() != ")")
			error("Expected ')'", errorType.CRITICAL);
		
		next();
		
		array_push(bytecode, [opCode.EXECUTE, _func_name, _arg_count]);
	}
	
	parse_primary = function(){
		
		switch(get_token_id()){
			case tokenID.Value:
				array_push(bytecode, [opCode.PUSH, get_token_val()]);
				
				next();
				
				return;
			
			case tokenID.Variable:
				//array_push(bytecode, [opCode.LOAD, get_token_val()])
				//
				//next();
				
				var _name = get_token_val();
				
				array_push(bytecode, [opCode.LOAD, _name]);
				
				next();
				
				if (get_token_val() == "++" || get_token_val() == "--"){
					var _op = get_token_val();
					next();
					
					array_push(bytecode, [opCode.LOAD, _name]);
					array_push(bytecode, [opCode.PUSH, 1]);
					
					if (_op == "++")
						array_push(bytecode, [opCode.ADD]);
					else
						array_push(bytecode, [opCode.SUB]);
					
					array_push(bytecode, [opCode.STORE, _name]);
				}
				
				return;
			
			case tokenID.Function:
				if (token_is(get_token_val(), global.Functions)){
					parse_call();
				}else{
					parse_user_call();
				}
				
				return;
			
			case tokenID.Unar:
				parse_prefix_idec();
				
				return;
		}
		
		switch(get_token_val()){
			case "(":
				next();
				
				parse_expression();
				
				if (get_token_val() != ")")
					error("Expected ')'", errorType.CRITICAL);
				
				next();
				
				break;
			
			case "-":
				next();
				
				parse_primary();
				
				array_push(bytecode, [opCode.PUSH, -1]);
				array_push(bytecode, [opCode.MUL]);
				
				break;
			
			case "+":
				next();
				
				parse_primary();
				break;
			
			case "!":
				next();
				
				parse_primary();
				
				array_push(bytecode, [opCode.PUSH, false]);
				array_push(bytecode, [opCode.COMPARE, "=="]);
				
				break;
		}
	}
	
	parse_multiplication = function(){
		parse_primary();
		
		while(true){
			var _val = get_token_val()
			
			if (_val == undefined) break;
			
			switch(_val){
				case "*":
					next();
					
					parse_primary();
					
					array_push(bytecode, [opCode.MUL]);
					
					break;
					
				case "/":
					next();
					
					parse_primary();
					
					array_push(bytecode, [opCode.DIV]);
					
					break;
					
				case "^":
					next();
					
					parse_primary();
					
					array_push(bytecode, [opCode.POW]);
					
					break;
				
				default:
					return false;
			}
		}
	}
	
	parse_addition = function(){
		parse_multiplication();
		
		while(curr < len){
			var _val = get_token_val();
			
			if (_val == undefined) break;
			
			switch(_val){
				case "+":
					next();
					
					parse_multiplication();
					
					array_push(bytecode, [opCode.ADD]);
					
					break;
					
				case "-":
					next();
					
					parse_multiplication();
					
					array_push(bytecode, [opCode.SUB]);
					
					break;
				
				default:
					return false;
			}
		}
	}
	
	parse_comparison = function(){
		parse_addition();
		
		while(curr < len){
			var _id = get_token_id();
			var _val = get_token_val();
			
			if (_val == undefined) break;
			
			if (_id == tokenID.Operator){
				next();
				
				parse_addition();
				
				array_push(bytecode, [opCode.COMPARE, _val]);
			}else
				break;
		}
	}
	
	parse_expression = function(){
		parse_comparison();
	}
	
	parse_func = function(){
		next();
		
		var _func_name = get_token_val();
		
		next();
		
		if (get_token_val() != "(")
			error("Expected '(' after function name", errorType.CRITICAL);
		
		next();
		
		var _params = [];
		
		if (get_token_val() != ")")
			while(curr < len){
				array_push(_params, get_token_val());
				next();
				
				if (get_token_val() == ",")
					next();
				else
					break;
			}
		
		if (get_token_val() != ")")
			error("Expected ')' after condition", errorType.CRITICAL);
		
		next();
		
		var _func_start = label_create();
		var _func_end = label_create();
		
		var _func_obj = {
			start_label: _func_start,
			params: _params,
			stack: [],
			memory: ds_map_create(),
			return_value: undefined,
		};
		
		array_push(bytecode, [opCode.PUSH, _func_obj]);
		array_push(bytecode, [opCode.STORE, _func_name]);
		
		array_push(bytecode, [opCode.JUMP, _func_end]);
		array_push(bytecode, [opCode.LABEL, _func_start]);
		
		array_push(bytecode, [opCode.PUSH, _func_obj]);
		array_push(bytecode, [opCode.STORE, _func_name]);
		
		parse_block();
		
		array_push(bytecode, [opCode.PUSH, undefined]);
		array_push(bytecode, [opCode.RETURN]);
		
		array_push(bytecode, [opCode.LABEL, _func_end]);
	}
	
	parse_user_call = function(){
		var _func_name = get_token_val();
		
		next();
		
		if (get_token_val() != "(")
			error("Expected '(' after function name", errorType.CRITICAL);
			
		next();
		
		var _args_count = 0;
		
		if (get_token_val() != ")")
			while(curr < len){
				parse_expression();
				_args_count++;
				
				if (get_token_val() == ",")
					next();
				else
					break;
			}
		
		if (get_token_val() != ")")
			error("Expected ')' after condition", errorType.CRITICAL);
		
		next();
		
		array_push(bytecode, [opCode.CALL, _func_name, _args_count]);
	}
	
	parse_if = function(){
		next();
		
		if (get_token_val() != "(")
			error("Expected '(' after if", errorType.CRITICAL);
		
		next();
		
		parse_expression();
		
		if (get_token_val() != ")")
			error("Expected ')' after condition", errorType.CRITICAL);
		
		next();
		
		var _label_else = label_create();
		var _label_end = label_create();
		
		array_push(bytecode, [opCode.JUMP_IF_FALSE, _label_else]);
		
		parse_block();
		
		array_push(bytecode, [opCode.JUMP, _label_end]);
		
		array_push(bytecode, [opCode.LABEL, _label_else]);
		
		if (get_token_val() == "else"){
			next();
			
			if (get_token_val() == "if")
				parse_if();
			else
				parse_block();
		}
		
		array_push(bytecode, [opCode.LABEL, _label_end]);
	}
	
	parse_assignment = function(){
		var _name = get_token_val();
		
		next();
		
		//parse_expression();
		
		var _op = get_token_val();
		
		switch(_op){
			case "+=":
				next();
				
				array_push(bytecode, [opCode.LOAD, _name]);
				
				parse_expression();
				
				array_push(bytecode, [opCode.ADD]);
				
				array_push(bytecode, [opCode.STORE, _name]);
				
				break;
			
			case "-=":
				next();
				
				array_push(bytecode, [opCode.LOAD, _name]);
				
				parse_expression();
				
				array_push(bytecode, [opCode.SUB]);
				
				array_push(bytecode, [opCode.STORE, _name]);
				
				break;
			
			case "*=":
				next();
				
				array_push(bytecode, [opCode.LOAD, _name]);
				
				parse_expression();
				
				array_push(bytecode, [opCode.MUL]);
				
				array_push(bytecode, [opCode.STORE, _name]);
				
				break;
			
			case "/=":
				next();
				
				array_push(bytecode, [opCode.LOAD, _name]);
				
				parse_expression();
				
				array_push(bytecode, [opCode.DIV]);
				
				array_push(bytecode, [opCode.STORE, _name]);
				
				break;
			
			case "//=":
				next();
				
				array_push(bytecode, [opCode.LOAD, _name]);
				
				parse_expression();
				
				array_push(bytecode, [opCode.IDIV]);
				
				array_push(bytecode, [opCode.STORE, _name]);
				
				break;
			
			case "^=":
				next();
				
				array_push(bytecode, [opCode.LOAD, _name]);
				
				parse_expression();
				
				array_push(bytecode, [opCode.POW]);
				
				array_push(bytecode, [opCode.STORE, _name]);
				
				break;
		}
		
		//array_push(bytecode, [opCode.STORE, _name]);
	}
	
	parse_statement = function(){
		var _id = get_token_id();
		var _val = get_token_val();
		
		switch(_id){
			case tokenID.Keyword:
				switch(_val){
					case "var":
						parse_var();
						break;
					
					case "if":
						parse_if();
						break;
					
					case "func":
						parse_func();
						break;
					
					case "return":
						parse_return();
						break;
				}
				
				break;
			
			case tokenID.Function:
				if (token_is(get_token_val(), global.Functions)){
					parse_call();
				}else{
					parse_user_call();
				}
				
				break;
			
			case tokenID.Variable:
				if (curr + 1 < len){
					var _next_val = tokens[curr + 1][$ "val"];
					
					if (_next_val == "++" || _next_val == "--"){
						parse_postfix_idec();
						break;
					}
				}
				parse_assignment();
				
				break;
			
			case tokenID.Unar:
				if (_val == "++" || _val == "--")
					parse_prefix_idec();
				
				break;
		}
	}
	
	parse_prefix_idec = function(){
		var _op = get_token_val();
		
		next();
		
		var _name = get_token_val();
		
		next();
		
		array_push(bytecode, [opCode.LOAD, _name]);
		array_push(bytecode, [opCode.PUSH, 1]);
		
		if (_op == "++")
			array_push(bytecode, [opCode.ADD]);
		else
			array_push(bytecode, [opCode.SUB]);
		
		array_push(bytecode, [opCode.STORE, _name]);
		array_push(bytecode, [opCode.LOAD, _name]);
	}
	
	parse_postfix_idec = function(){
		var _name = get_token_val();
		
		next();
		
		var _op = get_token_val();
		
		next();
		
		array_push(bytecode, [opCode.LOAD, _name]);
		
		array_push(bytecode, [opCode.LOAD, _name]);
		array_push(bytecode, [opCode.PUSH, 1]);
		
		if (_op == "++")
			array_push(bytecode, [opCode.ADD]);
		else
			array_push(bytecode, [opCode.SUB]);
		
		array_push(bytecode, [opCode.STORE, _name]);
	}
	
	while(curr < len){
		parse_statement();
	}
	
	array_push(bytecode, [opCode.HALT]);
	
	show_bytecode(bytecode);
	return bytecode;
}

function show_bytecode(bc) {
	var _len = array_length(bc);
	
	for(var i = 0; i < _len; i++){
		var _instr = bc[i];
		var _name = get_opcode_name(_instr[0]);
		var _args = "";
		
		for(var j = 1; j < array_length(_instr); j++){
			_args += string(_instr[j]) + " ";
		}
		
		show_debug_message($"{i}: {_name} {_args}");
	}
}