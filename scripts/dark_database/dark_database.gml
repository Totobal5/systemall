/// En esta funcion se incializan los hechizos
function dark_database() 
{
	dark_add("DARK.ATTACK", new DarkCommand(0, false, 1).setEventExecute(function(caster, target, flags) {
		var _cStat = caster.getStats();
		var _tStat = target.getStats();
		
		var _cF = _cStat.get( "FUERZA"), _cP = _cStat.get("PODER"), _cC = _cStat.get("CRITICAL");
		var _tF = _cStat.get("DEFENSA");
		
		var _damage = (_cF.control * _cP.control) / _tF.control;
		if (random(100) > _cC.control*100)	{_damage *= 2; }
		
		_tStat.add("PS", -_damage);
	}) );
	
	
	dark_add("DARK.VEN", new DarkCommand(10, false, 1).setEventExecute(function(caster, target, flags) {
		
		
	}) );
	
	
}