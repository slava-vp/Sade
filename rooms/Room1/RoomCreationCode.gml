function run(_code){
	var _tokens = lexer(_code);
	var _bytecode = parser(_tokens);
	VMachine(_bytecode);
}

run("for(i=7 in 10 step 3){for(j in 10){print(j, i)}}");
//run("for(i in 10 step 3){print(i)}");

game_end();