/// @desc EN ESTE SCRIPT SE DEBE CREAR Y CUSTOMIZAR CADA ELEMENTO MALL
function mall_database()
{
	mall_add_stat("PS", "EXP", "PM", "FUE", "INT", "DEF", "SPD");
	
	mall_add_element("FIRE");
	mall_add_element("AQUA");
	mall_add_element("EARTH");
	
	mall_add_state("LIFE");
	mall_add_state("VEN");
	mall_add_state("SIL");
	mall_add_state("STO");
	mall_add_state("BURN");
	
	mall_add_part("HEAD", "TORSO", "HAND", "FEET");
	
	mall_add_group("NORM", true);	// Crear grupo actual

	#region Customize Stats
	var _displayMethod = function() {
		return string(valueActual); 
	}
	
	mall_customize_stat("PS", 0, 0, 9999, NUMTYPES.REAL, true,, _displayMethod).setLevel(,,function(_level) {
		var _t = (base * _level * 3) div 2;
		return (_t + 10);	
	});
	mall_customize_stat("PM", "PS", true, true, true);
	
	mall_customize_stat("EXP", 0, 0, 9999999, NUMTYPES.REAL, true,, _displayMethod).setLevel(,,function(_level) {
		/// @context {Struct.__PartyStatsAtom}
		var _t = (_level * base * 7);
		return (_t + (_level * 2) + 60);
	});
	
	mall_customize_stat("FUE", 0, 0, 220, NUMTYPES.REAL, true,, _displayMethod).setLevel(,,function(_level) {
		var _t = ( (base * _level) / 15);
		return (_t + 5);
	});
	mall_customize_stat("INT", "FUE", true, true, true);
	mall_customize_stat("INT", "DEF", true, true, true);
	mall_customize_stat("INT", "SPD", true, true, true);
	
	#endregion
	
	#region Customize State
	mall_customize_state("LIFE", true);
	mall_customize_state("VEN", false);
	mall_customize_state("SIL", false);
	mall_customize_state("STO", false);
	
	#endregion
	
	#region Customize element
	/// @param {Struct.PartyEntity}	caster
	/// @param {Struct.PartyEntity}	target
	/// @param {Any*}				[extra]		Daño en este caso
	var _fireonhit = function(caster, target, extra) {
		// Si la defensa del target >= 100 entonces lo absorbe
		#region Get
		var _cstats   = caster.getStats();
		var _cattk = _cstats.get("FIRE.ATTACK");
		
		var _tstats   = target.getStats();
		var _tcontr   = target.getControl();
		var _tdef = _tstats.get("FIRE.DEFENSE");
		#endregion
		
		// Obtener si es efectivo
		var _effective = target.getEffective("FIRE");
		
		// Salir
		if (_effective == undefined) return extra;
		
		if (_tcontr.isAffected("BURN") )
		{
				
		}
		else
		{
			// Es porcentaje
			if (_tdef.valueControl >= 100)
			{
				dark_execute("DARK.HEAL", caster,, extra);	
			}
			else
			{
				dark_execute("DARK.DAMAGE", caster,,extra);	
			}
		}
		
	}
	
	mall_customize_element("FIRE");
	mall_customize_element("AQUA");
	mall_customize_element("EARTH");
	
	#endregion
	
	#region Customize Parts
	mall_customize_part("HEAD" ,  true, 1);
	mall_customize_part("TORSO",  true, 1);
	mall_customize_part("HAND" ,  true, 2);
	mall_customize_part("FEET" ,  true, 1);
	#endregion
}