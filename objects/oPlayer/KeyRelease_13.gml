/// @description Iniciar pelea

var _wate = wate_create_template("test", true);

wate_add(_wate, party_create("TRAUCO", "ENEMIGOS", irandom(10) ) );
var _t = function(entity, i, flag) {
	wate_add(flag, entity); 
}
party_foreach("HEROES", _t, _wate)

wate_sort(_wate, function(en1, en2) {
	var stat1 = en1.getStats().get("VELOCIDAD");
	var stat2 = en2.getStats().get("VELOCIDAD");
		
	return stat2.actual - stat1.actual;
});