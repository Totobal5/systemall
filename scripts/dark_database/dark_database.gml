/// En esta funcion se incializan los hechizos
function dark_database() {
        
    dark_add("DARK.HEAL1" , new DarkCommand(20).setCommand(function(caster, target, extra) {
		
		
	}) );
	
	/// Efecto de veneno. solo toma en cuenta la defensa del target
    dark_add("DARK.VENENO", new DarkCommand(0).setCommand(function(target)  {
		static update = function() {__value[NUMVALUE.VALUE] += 5; }
		// Si esta vivo
		var _control = target.getControl();
		if (_control.isAffected("LIFE") )
		{
			/// @type {Struct.__PartyStatsAtom}
			var _casterVeneno = target.getStats().get("VEN.DEFEND");		

			// Si se logra salir
			if (percent_chance(_casterVeneno.valueControl) ) exit;	
			_control.addEffect(new DarkEffect("VEN", 5, NUMTYPES.PERCENT, 5, update) );
		}
	}) );
	
	/// Curar a una entidad. solo toma en cuenta al target
	dark_add("DARK.HEAL", new DarkCommand(0).setCommand(function(target, value) {
		// Si esta vivo
		var _control = target.getControl();
		if (_control.isAffected("LIFE") )
		{
			var _stats = target.getStats();
			// Si esta envenenado reducir la curacion en un 15%
			var _ven = (_control.isAffected("VEN") ) ? _stats.get("PS") * 1.15 : 0;
			_stats.add("PS", (value - _ven) ); 			
		}
	}) );
}