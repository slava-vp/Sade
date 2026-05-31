function run(_code){
	var _tokens = lexer(_code);
	var _bytecode = parser(_tokens);
	VMachine(_bytecode);
}

function run_all_tests(_show_output = false){// Checks to make sure nothing's broken. (The computer doesn't explode, the Earth doesn't collapse, and the universe doesn't start shrinking.)
	show_debug_message("\n========== TESTS START ==========\n");
	
	
	show_output = _show_output;
	_passed = 0;
	_failed = 0;
	_results = [];
	
	test = function(_name, _code){
		show_debug_message($"\n--- Test: {_name} ---");
		show_debug_message($"Code: {_code}");
		
		var _tokens = lexer(_code, show_output);
		var _bytecode = parser(_tokens, show_output);
		
		show_debug_message("Output:");
		VMachine(_bytecode);
		
		array_push(_results, $"[OK] {_name}");
		_passed++;
	}
	
	test("Variables", "var x 10 var y 20 var z x+y print(z)");
	test("Arithmetic", "print(10+5*2)");
	
	test("String cat", "var a 'Hello ' var b 'World!' a.cat(b) print(a)");
	test("String len", "var a 'Hello' print(a.len())");
	test("String method chain", "var a 'Hello ' a.cat('World!') print(a.len())");
	test("String cp", "var a 'Hello World' a.cp(7, 5) print(a)");
	test("String ch", "var a 'Hello World' a.ch(2) print(a)");
	test("String ins", "var a 'Hello ' a.ins('World', 7) print(a)");
	
	test("Array create", "var a [1,2,3] print(a[0]) print(a[1]) print(a[2])");
	test("Array push", "var a [] a.push(100) print(a[0])");
	test("Array pop", "var a [1,2,3] a.pop() print(a.len())");
	test("Array len", "var a [1,2,3] print(a.len())");
	test("Array last", "var a [1,2,3] print(a.last())");
	test("Array ins", "var a [1,2,3] print(a.ins(2, [9, 8, 7]))");
	test("Array del", "var a [1,2,3] print(a.del(1, -1))");
	
	test("If true", "var x 10 if(x > 5){ print('yes') }");
	test("If false", "var x 3 if(x > 5){ print('yes') }else{ print('no') }");
	test("If and", "var x 10 var y 5 if(x > 5 && y < 10){ print('yes') }");
	test("If or", "var x 3 var y 5 if(x > 5 || y < 10){ print('yes') }");
	
	test("For range", "for(i in 3){ print(i) }");
	test("For range step", "for(i in 5 step 2){ print(i) }");
	test("For array", "var a [10,20,30] for(i in a){ print(i) }");
	test("For start-end", "for(i=1 in 3){ print(i) }");
	
	test("Function", "func add(a,b){return a+b} print(add(2,3))");
	test("Function recursion", "func fact(n){if(n <= 1){return 1} return n*fact(n-1)} print(fact(5))");
	
	test("Prefix inc", "var x 5 ++x print(x)");
	test("Postfix inc", "var x 5 print(x++) print(x)");
	
	test("Add assign", "var x 10 x+=5 print(x)");
	test("Array add assign", "var a [1,2,3] a[0]+=10 print(a[0])");
	
	show_debug_message($"\n========== RESULTS: {_passed}/{_passed + _failed} passed ==========\n");
}

run_all_tests(false);
game_end();