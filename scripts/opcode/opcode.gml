enum opCode{
	PUSH            ,   // push into stack
	POP             ,   // pop from stack
	STORE           ,   // push into memory
	LOAD            ,   // pop from memory
	JUMP            ,   // jump
	JUMP_IF_FALSE   ,   // conditional jump -> false
	JUMP_IF_TRUE    ,   // conditional jump -> true
	
	EXECUTE         ,   // execute builtin function
	CALL			,	// execute user-defined function
	
	LABEL           ,   // label
	
	COMPARE         ,   // ==, !=, >= ...
	ADD             ,   // +
	SUB             ,   // -
	MUL             ,   // *
	DIV             ,   // /
	POW             ,   // ^
	
	HALT            ,   // stop VMachine
	RETURN          ,   // return from function
	BREAK           ,   // break look
	CONTINUE        ,   // continue in loop
}

function get_opcode_name(code){
	switch(code){
		case opCode.PUSH: return "PUSH";
		case opCode.POP: return "POP";
		case opCode.STORE: return "STORE";
		case opCode.LOAD: return "LOAD";
		case opCode.JUMP: return "JUMP";
		case opCode.JUMP_IF_FALSE: return "JUMP_IF_FALSE";
		case opCode.JUMP_IF_TRUE: return "JUMP_IF_TRUE";
		case opCode.EXECUTE: return "EXECUTE";
		case opCode.CALL: return "CALL";
		case opCode.LABEL: return "LABEL";
		case opCode.COMPARE: return "COMPARE";
		case opCode.ADD: return "ADD";
		case opCode.SUB: return "SUB";
		case opCode.MUL: return "MUL";
		case opCode.DIV: return "DIV";
		case opCode.POW: return "POW";
		case opCode.HALT: return "HALT";
		case opCode.RETURN: return "RETURN";
		case opCode.BREAK: return "BREAK";
		case opCode.CONTINUE: return "CONTINUE";
		default: return undefined;
	}
}