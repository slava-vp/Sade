///@desc
function error(_message, _type){
	switch(_type){
		case errorType.INFO:
		case errorType.WARNING:
			show_debug_message($"[{(_type == errorType.INFO ? "INFO" : "WARNING")}]: {_message}")
			
			break;
		
		case errorType.ERROR:
		case errorType.CRITICAL:
			show_message($"[{(_type == errorType.ERROR ? "ERROR" : "CRITICAL ERROR")}]: {_message}");
			game_end(-1);
			
			break;
	}
}

enum errorType{
	INFO,
	WARNING,
	ERROR,
	CRITICAL,
}