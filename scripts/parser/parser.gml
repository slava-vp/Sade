function parser(_tokens, _show_output = false){
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
	
	parse_for = function(){
		next();
		
		if (get_token_val() != "(")
			error("Expected '(' after for", errorType.CRITICAL);
		
		next();
		
		var _var_name = get_token_val();
		
		if (get_token_id() != tokenID.Variable)
			error("Expected variable name after for", errorType.CRITICAL);
		
		next();
		
		var _label_start = label_create();
		var _label_end = label_create();
		var _label_continue = label_create();
		
		current_break = _label_end;
		current_continue = _label_continue;
		
		var _prev_break = current_break;
		var _prev_continue = current_continue;
		
		var _op = get_token_val();
		
		if (_op == "in"){
			next();
			
			var _val = get_token_val();
			var _is_range = (get_token_id() == tokenID.Value && token_is_value(get_token_val()));
			
			if (_is_range){
				var _range_end = real(get_token_val()) - 1;
				next();
				
				array_push(bytecode, [opCode.PUSH, 0]);
				array_push(bytecode, [opCode.STORE, _var_name]);
				
				var _end_tmp = $"__end_{label_create()}_";
				
				array_push(bytecode, [opCode.PUSH, _range_end]);
				array_push(bytecode, [opCode.STORE, _end_tmp]);
				
				var _step = 1;
				if (get_token_val() == "step"){
					next();
					
					var _sign = 1;
					if (get_token_val() == "-"){
						_sign = -1;
						next();
					}
					
					_step = real(get_token_val()) * _sign;
					next();
				}
				
				if (get_token_val() != ")")
					error("Expected ')' after for condition", errorType.CRITICAL);
				
				next();
				
				array_push(bytecode, [opCode.LABEL, _label_start]);
				
				array_push(bytecode, [opCode.LOAD, _var_name]);
				array_push(bytecode, [opCode.LOAD, _end_tmp]);
				var _compare = (_step >= 0) ? "<=" : ">=";
				array_push(bytecode, [opCode.COMPARE, _compare]);
				array_push(bytecode, [opCode.JUMP_IF_FALSE, _label_end]);
				
				array_push(bytecode, [opCode.LABEL, _label_continue]);
				
				parse_block();
				
				array_push(bytecode, [opCode.LOAD, _var_name]);
				array_push(bytecode, [opCode.PUSH, _step]);
				array_push(bytecode, [opCode.ADD]);
				array_push(bytecode, [opCode.STORE, _var_name]);
				
				array_push(bytecode, [opCode.JUMP, _label_start]);
				array_push(bytecode, [opCode.LABEL, _label_end]);
				
				array_push(bytecode, [opCode.DELETE, _end_tmp]);
			}else{
				parse_expression();
				
				var _arr_tmp = $"__arr_{label_create()}";
				var _idx_tmp = $"__idx_{label_create()}";
				var _len_tmp = $"__len_{label_create()}";
				
				array_push(bytecode, [opCode.STORE, _arr_tmp]);
				array_push(bytecode, [opCode.PUSH, 0]);
				array_push(bytecode, [opCode.STORE, _idx_tmp]);
				array_push(bytecode, [opCode.LOAD, _arr_tmp]);
				array_push(bytecode, [opCode.ARRAY_LEN]);
				array_push(bytecode, [opCode.STORE, _len_tmp]);
				
				var _step = 1;
				if (get_token_val() == "step"){
					next();
					
					var _sign = 1;
					if (get_token_val() == "-"){
						_sign = -1;
						next();
					}
					
					_step = real(get_token_val()) * _sign;
					next();
				}
				
				if (get_token_val() != ")")
					error("Expected ')' after for condition", errorType.CRITICAL);
				
				next();
				
				array_push(bytecode, [opCode.LABEL, _label_start]);
				
				array_push(bytecode, [opCode.LOAD, _idx_tmp]);
				array_push(bytecode, [opCode.LOAD, _len_tmp]);
				var _compare = (_step >= 0) ? "<=" : ">=";
				array_push(bytecode, [opCode.COMPARE, _compare]);
				array_push(bytecode, [opCode.JUMP_IF_FALSE, _label_end]);
				
				array_push(bytecode, [opCode.LOAD, _arr_tmp]);
				array_push(bytecode, [opCode.LOAD, _idx_tmp]);
				array_push(bytecode, [opCode.ARRAY_GET]);
				array_push(bytecode, [opCode.STORE, _var_name]);
				
				array_push(bytecode, [opCode.LABEL, _label_continue]);
				
				parse_block();
				
				array_push(bytecode, [opCode.LOAD, _idx_tmp]);
				array_push(bytecode, [opCode.PUSH, _step]);
				array_push(bytecode, [opCode.ADD]);
				array_push(bytecode, [opCode.STORE, _idx_tmp]);
				
				array_push(bytecode, [opCode.JUMP, _label_start]);
				array_push(bytecode, [opCode.LABEL, _label_end]);
				
				array_push(bytecode, [opCode.DELETE, _arr_tmp]);
				array_push(bytecode, [opCode.DELETE, _idx_tmp]);
				array_push(bytecode, [opCode.DELETE, _len_tmp]);
			}
		}else if (_op == "="){
			next();
			
			parse_expression();
			array_push(bytecode, [opCode.STORE, _var_name]);
			
			if (get_token_val() != "in")
				error("Expected 'in' after start value", errorType.CRITICAL);
			
			next();
			
			parse_expression();
			
			var _end_tmp = $"__end_{label_create()}_";
			array_push(bytecode, [opCode.STORE, _end_tmp]);
			
			var _step = 1;
			if (get_token_val() == "step"){
				next();
				
				var _sign = 1;
				if (get_token_val() == "-"){
					_sign = -1;
					next();
				}
				
				_step = real(get_token_val()) * _sign;
				next();
			}
			
			if (get_token_val() != ")")
				error("Expected ')' after for condition", errorType.CRITICAL);
			
			next();
			
			array_push(bytecode, [opCode.LABEL, _label_start]);
			
			array_push(bytecode, [opCode.LOAD, _var_name]);
			array_push(bytecode, [opCode.LOAD, _end_tmp]);
			var _compare = (_step >= 0) ? "<=" : ">=";
			array_push(bytecode, [opCode.COMPARE, _compare]);
			array_push(bytecode, [opCode.JUMP_IF_FALSE, _label_end]);
			
			array_push(bytecode, [opCode.LABEL, _label_continue]);
			
			parse_block();
			
			array_push(bytecode, [opCode.LOAD, _var_name]);
			array_push(bytecode, [opCode.PUSH, _step]);
			array_push(bytecode, [opCode.ADD]);
			array_push(bytecode, [opCode.STORE, _var_name]);
			
			array_push(bytecode, [opCode.JUMP, _label_start]);
			array_push(bytecode, [opCode.LABEL, _label_end]);
			
			array_push(bytecode, [opCode.DELETE, _end_tmp]);
		}else
			error("Expected 'in' or '=' after variable in for", errorType.CRITICAL);
		
		current_break = _prev_break;
		current_continue = _prev_continue;
	}
	
	parse_logic = function(){
		parse_comparison();
		
		while(curr < len){
			var _val = get_token_val();
			
			if (_val == undefined) break;
			
			if (_val == "&&"){
				next();
				
				parse_comparison();
				
				array_push(bytecode, [opCode.AND]);
			}else if (_val == "||"){
				next();
				
				parse_comparison();
				
				array_push(bytecode, [opCode.OR]);
			}else
				break;
		}
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
		var _id = get_token_id();
		var _val = get_token_val();
	
		switch(_id){
			case tokenID.Value:
				array_push(bytecode, [opCode.PUSH, _val]);
				next();
				return;
		
			case tokenID.Variable:
				var _name = _val;
			
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
			
				while(get_token_val() == "["){
					next();
					parse_expression();
				
					if (get_token_val() != "]")
						error("Expected ']'", errorType.CRITICAL);
				
					next();
					array_push(bytecode, [opCode.ARRAY_GET]);
				}
			
				while(get_token_val() == "."){
					next();
				
					var _method = get_token_val();
					next();
				
					if (get_token_val() != "(")
						error("Expected '(' after method name", errorType.CRITICAL);
				
					next();
				
					var _arg_count = 0;
					if (get_token_val() != ")"){
						while(curr < len){
							parse_expression();
							_arg_count++;
						
							if (get_token_val() == ",")
								next();
							else
								break;
						}
					}
				
					if (get_token_val() != ")")
						error("Expected ')'", errorType.CRITICAL);
				
					next();
					array_push(bytecode, [opCode.METHOD, _method, _arg_count]);
				}
			
				return;
		
			case tokenID.Function:
				if (token_is(_val, global.Functions)){
					parse_call();
				}else{
					parse_user_call();
				}
				return;
		
			case tokenID.Unar:
				if (get_token_val() == "-"){
					next();
					parse_primary();
					array_push(bytecode, [opCode.PUSH, -1]);
					array_push(bytecode, [opCode.MUL]);
				}else{
					parse_prefix_idec();
				}
				return;
		
			case tokenID.Sbracket_L:
				next();
			
				var _len = 0;
			
				if (get_token_val() != "]")
					while(curr < len){
						parse_expression();
						_len++;
					
						if (get_token_val() == ",")
							next();
						else
							break;
					}
			
				if (get_token_val() != "]")
					error("Expected ']'", errorType.CRITICAL);
			
				next();
				array_push(bytecode, [opCode.ARRAY_CREATE, _len]);
				return;
		
			case tokenID.Minus:
				next();
				parse_primary();
				array_push(bytecode, [opCode.PUSH, -1]);
				array_push(bytecode, [opCode.MUL]);
				return;
		}
	
		switch(_val){
			case "(":
				next();
				parse_expression();
			
				if (get_token_val() != ")")
					error("Expected ')'", errorType.CRITICAL);
			
				next();
				return;
		
			case "-":
				next();
				parse_primary();
				array_push(bytecode, [opCode.PUSH, -1]);
				array_push(bytecode, [opCode.MUL]);
				return;
		
			case "+":
				next();
				parse_primary();
				return;
		
			case "!":
				next();
				parse_primary();
				array_push(bytecode, [opCode.PUSH, false]);
				array_push(bytecode, [opCode.COMPARE, "=="]);
				return;
		}
	
		error($"Unexpected token in expression: {_val}", errorType.CRITICAL);
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
			
			if (_val == "&&" || _val == "||") break;
			
			if (_id == tokenID.Operator || _id == tokenID.More || _id == tokenID.Less || _val == "%=" || _val == "==" || _val == "!=" || _val == "<=" || _val == ">=" || _val == "<" || _val == ">"){
				next();
				
				parse_addition();
				
				array_push(bytecode, [opCode.COMPARE, _val]);
			}else
				break;
		}
	}
	
	parse_expression = function(){
		parse_logic();
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
		
		if (get_token_val() == "["){
			var _indices = [];
			
			array_push(bytecode, [opCode.LOAD, _name]);
			
			while(get_token_val() == "["){
				next();
				
				var _idx_tmp = $"__idx_{label_create()}_";
				array_push(_indices, _idx_tmp);
				
				parse_expression();
				array_push(bytecode, [opCode.STORE, _idx_tmp]);
				
				if (get_token_val() != "]"){
					error("Expected ']'", errorType.CRITICAL);
				}
				
				next();
				
				if (get_token_val() == "["){
					array_push(bytecode, [opCode.LOAD, _idx_tmp]);
					array_push(bytecode, [opCode.ARRAY_GET]);
				}
			}
			
			var _last_idx = _indices[array_length(_indices) - 1];
			var _op = get_token_val();
			
			if (_op == "="){
				next();
				array_push(bytecode, [opCode.LOAD, _last_idx]);
				parse_expression();
				array_push(bytecode, [opCode.ARRAY_SET]);
				
				for(var i = array_length(_indices) - 2; i >= 0; i--){
					var _tmp = $"__tmp_{label_create()}_";
					array_push(bytecode, [opCode.STORE, _tmp]);
					array_push(bytecode, [opCode.LOAD, _name]);
					
					for(var j = 0; j < i; j++){
						array_push(bytecode, [opCode.LOAD, _indices[j]]);
						array_push(bytecode, [opCode.ARRAY_GET]);
					}
					
					array_push(bytecode, [opCode.LOAD, _indices[i]]);
					array_push(bytecode, [opCode.LOAD, _tmp]);
					array_push(bytecode, [opCode.ARRAY_SET]);
				}
				
				array_push(bytecode, [opCode.STORE, _name]);
			
			}else if (_op == "+=" || _op == "-=" || _op == "*=" || _op == "/=" || _op == "//=" || _op == "^="){
				array_push(bytecode, [opCode.DUP]);
				array_push(bytecode, [opCode.LOAD, _last_idx]);
				array_push(bytecode, [opCode.ARRAY_GET]);
				
				next();
				parse_expression();
				
				if (_op == "+=") array_push(bytecode, [opCode.ADD]);
				else if (_op == "-=") array_push(bytecode, [opCode.SUB]);
				else if (_op == "*=") array_push(bytecode, [opCode.MUL]);
				else if (_op == "/=") array_push(bytecode, [opCode.DIV]);
				else if (_op == "//=") array_push(bytecode, [opCode.IDIV]);
				else if (_op == "^=") array_push(bytecode, [opCode.POW]);
				
				array_push(bytecode, [opCode.STORE, "__temp_val__"]);
				array_push(bytecode, [opCode.LOAD, _last_idx]);
				array_push(bytecode, [opCode.LOAD, "__temp_val__"]);
				array_push(bytecode, [opCode.ARRAY_SET]);
			
			}else{
				error($"Unknown assignment operator: {_op}", errorType.CRITICAL);
			}
			
			for(var i = 0; i < array_length(_indices); i++){
				array_push(bytecode, [opCode.DELETE, _indices[i]]);
			}
			
			return;
		}
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
					
					case "for":
						parse_for();
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
				var _name = get_token_val();
			
				if (curr + 1 < len){
					var _next_val = tokens[curr + 1][$ "val"];
					
					if (_next_val == "++" || _next_val == "--"){
						parse_postfix_idec();
						break;
					}
					
					if (_next_val == "=" || _next_val == "%=" || _next_val == "+=" || _next_val == "-=" || _next_val == "*=" || _next_val == "/=" || _next_val == "//=" || _next_val == "^=" || _next_val == "["){
						parse_assignment();
						
						break;
					}
					
					if (_next_val == "."){
						parse_expression();
						
						array_push(bytecode, [opCode.STORE, _name]);
					}
				}
				
				parse_expression();
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
	
	if (_show_output) show_bytecode(bytecode);
	return bytecode;
}

function show_bytecode(bc){
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