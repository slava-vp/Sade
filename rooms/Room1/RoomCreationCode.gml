function run(_code){
	var _tokens = lexer(_code);
	var _bytecode = parser(_tokens);
	VMachine(_bytecode);
}

run("var x 10 var y 20 if (x > 5 && y < 30 && 0) { var z x + y print(z) }");

game_end();