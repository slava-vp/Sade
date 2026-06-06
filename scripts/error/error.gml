function error(_message, _type, _line = "?", _col = "?"){
	var _location = $" (line {_line})";
	
	switch(_type){
		case errorType.INFO:
		case errorType.WARNING:
			console_log($"[{(_type == errorType.INFO ? "INFO" : "WARNING")}]: {_message}{_location}");
			break;
		
		case errorType.ERROR:
		case errorType.CRITICAL:
			show_error($"[{(_type == errorType.ERROR ? "ERROR" : "CRITICAL ERROR")}]: {_message}{_location}", false);
			break;
	}
}

enum errorType{
	INFO,
	WARNING,
	ERROR,
	CRITICAL,
}