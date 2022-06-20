/// @desc EN ESTE SCRIPT SE DEBE CREAR Y CUSTOMIZAR CADA ELEMENTO MALL
function mall_database()
{
	global.__feather_mall_stats = {PS:"",PM:"",FUE:"",INT:"",DEF:""};
	
	mall_add_action	 ("ATTACK", "DEFEND", "SPELL");
	mall_add_itemtype("SWORD", "ARMOR", "HELMET", "BOOTS");
	
	mall_add_stat("PS", "EXP", "PM", "FUE", "INT", "DEF", "SPD");
	
	mall_add_element("FIRE");
	mall_add_element("AQUA");
	mall_add_element("EARTH");
	
	mall_add_state("LIFE");
	mall_add_state("VEN");
	mall_add_state("SIL");
	mall_add_state("STO");
	
	mall_add_part("HEAD", "TORSO", "HAND", "FEET");
	
	#region Customize Stats
	mall_customize_stat("PS", 0, 0, 9999, NUMTYPES.REAL, true,, function() {return string(valueActual); } ).setLevel(,,function(_level) {
		var _t = (base * _level * 3) div 2;
		return (_t + 10);	
	});
	mall_customize_stat("PM", "PS", true, true, true);
	
	mall_customize_stat("EXP", 0, 0, 9999999, NUMTYPES.REAL, true,, function() {return string(valueActual); } ).setLevel(,,function(_level) {
		/// @context {Struct.__PartyStatsAtom}
		var _t = (_level * base * 7);
		return (_t + (_level * 2) + 60);
	});
	
	mall_customize_stat("FUE", 0, 0, 220, NUMTYPES.REAL, true,, function() {return string(valueActual); } ).setLevel(,,function(_level) {
		var _t = ( (base * _level) / 15);
		return (_t + 5);
	});
	mall_customize_stat("INT", "FUE", true, true, true);
	mall_customize_stat("INT", "DEF", true, true, true);
	mall_customize_stat("INT", "SPD", true, true, true);
	
	#endregion
	
	#region Customize State
	mall_customize_state("LIFE", true, NUMTYPES.BOOLEAN);
	mall_customize_state("VEN", false, NUMTYPES.BOOLEAN);
	mall_customize_state("SIL", false, NUMTYPES.BOOLEAN);
	mall_customize_state("STO", false, NUMTYPES.BOOLEAN);
	
	#endregion
	
}