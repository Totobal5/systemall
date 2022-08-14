function party_database() 
{
	party_template_create("HERO", function(_GROUP, _LEVEL, _ARGS) {
		static display = function() {};
		// Primero crear entity 
		var _entity = new PartyEntity(_GROUP, "PARTY.HERO", display);
		var _control = new PartyControl(_entity);
		var _stats	 = new PartyStats(_entity, _LEVEL);
		var _equip   = new PartyEquipment(_entity);
		_entity.updateComponents();
	
		_stats.setBase(
			"PS" , 39, MALL_NUMTYPE.REAL,
			"PM" , 39, MALL_NUMTYPE.REAL,
			"EXP", 10, MALL_NUMTYPE.REAL,
			
			"FUERZA" ,	22, MALL_NUMTYPE.REAL,
			"DEFENSA",	18, MALL_NUMTYPE.REAL,
			"ESPECIAL",	25, MALL_NUMTYPE.REAL,
			"VELOCIDAD",30, MALL_NUMTYPE.REAL
		);

		_stats.setCheckLevel(function(stat, flag) {
			var _exp = get("EXP");
			return (_exp.actual >= _exp.peak);
		});
		_stats.setFlag("EXP", "Medium Slow");

		// Subir de nivel
		_stats.eventLevel(_LEVEL, true);
	});
	
}