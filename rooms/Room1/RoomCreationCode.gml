function run(_code){
	var _tokens = lexer(_code);
	var _bytecode = parser(_tokens);
	VMachine(_bytecode);
}

run("print(i) print(102) print('Hello World') var b -11 print(b) var g 'Hello World' print(g)");

game_end();