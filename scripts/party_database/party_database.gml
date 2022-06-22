function party_database() 
{
	party_template_create("Player1", function( _group, _level, _args) {
		var _stats	 = new PartyStats(_level);
		var _control = new PartyControl(false, true);
		var _parts	 = new PartyParts();
		
		// Crear una entidad
		var _entity = new PartyEntity("Player1", _stats, _control, _parts, _group);
		
		// Indicar grupo y pasar referencias
		_entity.setGroup(_group, party_group_size(_group) );
		
		_stats.setBase("PS" , 15, "PM", 15, "EXP", 25);
		_stats.setBase("FUE", 51, "INT", 51, "DEF", 60);
		_stats.setBase("FIRE.ATTACK" , 51,  "AQUA.ATTACK", 100, "EARTH.ATTACK", 25);
		_stats.setBase("FIRE.DEFEND" ,  0,  "AQUA.DEFEND",   0, "EARTH.DEFEND",  0);
		
	mall_add_state("LIFE");
	mall_add_state("VEN");
	mall_add_state("SIL");
	mall_add_state("STO");
	mall_add_state("BURN");		
		
		// Condicion global
		_stats.setCondition(,function() {
			var _exp = get("EXP");
			var _actual = _exp.valueActual, _max = _exp.valueMax;
			
			return (_actual >= _max);
		});
		_stats.levelUp(0, true);	// Subir de nivel
	});
	
	
}