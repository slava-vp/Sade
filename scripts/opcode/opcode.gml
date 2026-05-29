enum opCode{
	PUSH            ,   // положить в стек
	POP             ,   // взять из стека
	STORE           ,   // положить в память
	LOAD            ,   // взять из памяти
	JUMP            ,   // безусловный переход
	JUMP_IF_FALSE   ,   // условных переход, если false
	JUMP_IF_TRUE    ,   // условных переход, если true
	
	EXECUTE         ,   // выполнить встроенную функцию
	
	LABEL           ,   // заметка
	
	COMPARE         ,   // сравнить
	ADD             ,   // сложить
	SUB             ,   // вычесть
	MUL             ,   // умножить
	DIV             ,   // делить
	POW             ,   // степень
	
	HALT            ,   // остановка ВМ
	RETURN          ,   // возврат из функции
	BREAK           ,   // break из цикла
	CONTINUE        ,   // continue в цикле
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