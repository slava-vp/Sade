function run(_code){
	var _tokens = lexer(_code);
	var _bytecode = parser(_tokens);
	VMachine(_bytecode);
}

run("if (-1) {print(1)}else{print(2) if(0){print(3)}else{print(4)}}");

game_end();