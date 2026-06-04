global.snippets = ds_map_create();

var _map = ds_map_create();
ds_map_add(_map, "for", "for(i in count){\n    \n}");
ds_map_add(_map, "forr", "for(i=count in 0){\n    \n}");
ds_map_add_map(global.snippets, "for", _map);

_map = ds_map_create();
ds_map_add(_map, "if", "if (    ){\n    \n}");
ds_map_add(_map, "ife", "if (    ){\n    \n}else{\n    \n}");
ds_map_add(_map, "ifeif", "if (    ){\n    \n}else if (    ){\n    \n}");
ds_map_add_map(global.snippets, "if", _map);

_map = ds_map_create();
ds_map_add(_map, "func", "func name(){\n    \n}");
ds_map_add(_map, "funcr", "func name(){\n    return\n}");
ds_map_add_map(global.snippets, "func", _map);

_map = ds_map_create();
ds_map_add(_map, "var", "var name value");
ds_map_add(_map, "varstr", "var name 'value'");
ds_map_add_map(global.snippets, "var", _map);

_map = ds_map_create();
ds_map_add(_map, "returnv", "return value");
ds_map_add_map(global.snippets, "return", _map);