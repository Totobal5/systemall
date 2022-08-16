/// @description Iniciar pelea

var _wate = wate_create("test", true);

wate_add(_wate, party_create("TRAUCO", "ENEMIGOS", irandom(10) ) );
var _group = party_group_get("HEROES");

var _t = function(entitys, i, flag) {wate_add(flag, entitys); }
party_foreach("HEROES", _t, _wate)