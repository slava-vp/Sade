function run(_code){
	var _tokens = lexer(_code);
	var _bytecode = parser(_tokens);
	VMachine(_bytecode);
}

run("var b 10 print(b) print(++b) print(b++) print(b) b+=b+b+b print(b)");

game_end();