function run(_code){
	var _tokens = lexer(_code);
	var _bytecode = parser(_tokens);
	VMachine(_bytecode);
}

run("var a [1, 2, 3] print(a[2], 'Content: ')");

game_end();