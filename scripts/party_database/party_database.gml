function party_database() 
{
	party_template_create("CHARMANDER", function(_GROUP, _LEVEL, _ARGS) {
		var _stats = new PartyStats(_LEVEL);
		_stats.setBase("PS", 39, 0, "ATTACK", 52, 0, "DEFENSA", 43, 0, "ESPECIAL", 50, 0, "VELOCIDAD", 65, 0, "EXP", 1, 0);
		_stats.setCondition(function() {
			var _exp = get("EXP");
			return (_exp.valueActual >= _exp.valueMax);
		});
		_stats.setFlag("EXP", "Medium Slow");
		
		_stats.levelUp(0, true);
		
		var _control = new PartyControl()
		
	});
	
}