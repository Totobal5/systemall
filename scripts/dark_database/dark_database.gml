/// En esta funcion se incializan los hechizos
function dark_database() {
        
    dark_add("DARK.WSPELL.HEAL1" , MALL_DARK_TYPE_MAGIC, new DarkCommand("W.S", 20).setCommand(function(caster, target, extra) {
		
		
	}) );
	
    dark_add("DARK.GSPELL.VENENO", MALL_DARK_TYPE_TICK , new DarkCommand("G.S", 0).setCommand(function(caster, target, extra)  {
		static update = function() {__value[NUMVALUE.VALUE] += 5; }
		var _effect = new DarkEffect("PS", 5, NUMTYPES.PERCENT, 5, update);
		/// @type {Struct.__PartyControlAtom}
		var _control = caster.getControl();
		_control.addEffect(_effect);
	}) );
}