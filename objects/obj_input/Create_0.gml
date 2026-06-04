last_char = "";
last_key = vk_nokey;
char_available = false;

get_char = function(){
	return last_char;
}

get_key = function(){
	return last_key;
}

has_char = function(){
	return char_available;
}

consume = function(){
	var _char = last_char;
	var _key = last_key;
	last_char = "";
	last_key = vk_nokey;
	char_available = false;
	
	keyboard_lastchar = "";
	keyboard_lastkey = vk_nokey;
	
	return { char: _char, key: _key };
}