global.snippets = ds_map_create();

var _map = ds_map_create();
ds_map_add(_map, "for", "for ");
ds_map_add(_map, "for", "for(i in count){\n    \n}");
ds_map_add(_map, "for-r", "for(i=count in 0){\n    \n}");
ds_map_add_map(global.snippets, "for", _map);

_map = ds_map_create();
ds_map_add(_map, "if", "if ");
ds_map_add(_map, "if", "if (){\n    \n}");
ds_map_add(_map, "if-else", "if (){\n    \n}else{\n    \n}");
ds_map_add(_map, "if-else-if", "if (){\n    \n}else if (){\n    \n}");
ds_map_add_map(global.snippets, "if", _map);

_map = ds_map_create();
ds_map_add(_map, "func", "func ");
ds_map_add(_map, "func-full", "func name(){\n    \n}");
ds_map_add(_map, "func-with-return", "func name(){\n    return\n}");
ds_map_add_map(global.snippets, "func", _map);

_map = ds_map_create();
ds_map_add(_map, "var", "var ");
ds_map_add(_map, "var-full", "var name value");
ds_map_add(_map, "var-string", "var name 'value'");
ds_map_add_map(global.snippets, "var", _map);

_map = ds_map_create();
ds_map_add(_map, "return", "return ");
ds_map_add(_map, "return-val", "return value");
ds_map_add_map(global.snippets, "return", _map);

_map = ds_map_create();
ds_map_add(_map, "set", "#set ");
ds_map_add(_map, "set-auto_include_once on", "#set auto_include_once on");
ds_map_add(_map, "set-auto_include_once off", "#set auto_include_once off");
ds_map_add(_map, "set-unknown_is_zero on", "#set unknown_is_zero on");
ds_map_add(_map, "set-unknown_is_zero off", "#set unknown_is_zero off");
ds_map_add(_map, "set-internal_error_log on", "#set internal_error_log on");
ds_map_add(_map, "set-internal_error_log off", "#set internal_error_log off");
ds_map_add_map(global.snippets, "set", _map);