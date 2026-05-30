function run(_code){
	var _tokens = lexer(_code);
	var _bytecode = parser(_tokens);
	VMachine(_bytecode);
}

run("func test_output(_local){func bigger_0(_a){if (_a){return _a}else{return 0}} var b 10 return bigger_0(_local)} print(test_output(1), test_output(1923), test_output(2), test_output(-11), b)");

game_end();