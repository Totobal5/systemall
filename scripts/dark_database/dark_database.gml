#macro DARK_CATEGORY_AYUDA "DARK.CATEGORY.AYUDA"
#macro DARK_CATEGORY_CAST "DARK.CATEGORY.CAST"
#macro DARK_TYPE_ALLMENU   "MENU&BATALLA"
#macro DARK_TYPE_MENU      "MENU"
#macro DARK_TYPE_BATTLE    "BATALLA"

/// En esta funcion se inician todos los comandos y funciones para usar en MallRPG
function dark_database() 
{
	#region Dark stats
	dark_create_function("fStatLevel01", function(_partyStat, _level) {
		return round( (base * _level) + (_level+10) );
	});
	
	// Para EXP
	dark_create_function("fStatLevel02" , function(_partyStat, _level) {
		/// @self PartyStat$$createAtom
		return round( (base * _level * 8) + (_level*2) + 60);
	});	
	
	// Otras estadisticas
	dark_create_function("fStatLevel03" , function(_partyStat, _level) {
		return round( ( (base * _level) / 40) + 5);
	})
	
	dark_create_function("fStatLevel04" , function(_partyStat, _level) {
		/// @self Struct.PartyStat
		var _velocidad = _partyStat.get(STAT_VELOCIDAD);
		return round( (_velocidad.peak / 10) );
	});
	
	#endregion
	
	#region Dark states
	dark_create_function("fStateVenenoS"   , function(_entity, _vars) {
		var _stat = _entity.getStat();
		var _sub  = _stat.add(STAT_EN, -30, MALL_NUMTYPE.PERCENT, 2);
		// Enviar mensaje al bus
		mall_message_send(
			lexicon_text("GUI.VENENO.MSG", _entity.key, _sub)
		)
	});

	dark_create_function("fStateQuemadoS"  , function(entity, _vars) {
		var _stat = entity.getStats();
		var _sub  = _stat. add("PS", -10, MALL_NUMTYPE.PERCENT, 2); 
		
		// enviar mensaje
		mall_message_send(
			lexicon_text("GUI.QUEMADO.MSG", entity.key, _sub) 
		);
	});

	dark_create_function("fStateCongeladoS", function(entity, _vars) {
		// Pasar el turno
		entity.pass = true;
		
		// enviar mensaje
		mall_message_send(
			lexicon_text("GUI.CONGELADO.MSG", entity.key) 
		);
	});

	dark_create_function("fStateDormidoS"  , function(entity, _vars) {
		// Pasar el turno
		entity.pass = true;
		
		// enviar mensaje
		mall_message_send(
			lexicon_text("GUI.DORMIDO.MSG", entity.key) 
		);
	});
	
	#endregion
	
	dark_create_function("fPartyCheckExp"  , function(_vars) {
		var _exp = get(STAT_EXP);
		return (_exp.actual >= _exp.peak);
	});
	
	#region Dark Objetos
	/// Aumentar el especial en 20% por 1 turno cada 2 turnos
	dark_create_function("fPocketJonDibujo", function(_vars) {
	
	});
	
	var _thin = "";
	
	#endregion

	#region Dark Combates
	dark_create_function("fWateDefaultAttack", function(_power, _fue, _def) {
		var _sum = (_fue + _def) / 80;
		var _res = _fue / _def;
		return round(_power * _res * _sum);
	})
	
	
	#endregion

	#region Dark Commands
	#macro DARK_COMMAND_HEAL1 "DARK.COMMAND.HEAL1"
	dark_create_command(
		new DarkCommand(DARK_COMMAND_HEAL1, 10, true, 1).
		setCheck  (function(_caster, _target) {
			var _ccontrol = _caster.getControl(), _tcontrol = _target.getControl();
			// Que los 2 esten vivos
			if (_ccontrol.getState(STATE_VIVO) && _tcontrol.getState(STATE_VIVO) ) {
				var _cstats = _caster.getStat(), _tstats = _target.getStat();
				// obtener EPM del caster y EN del target
				var _cep = _cstats.get(STAT_EPM);
				if (_cep.actual >= consume) { // Asegurarse que posea más energía que el consumo
					var _ten = _tstats.get( STAT_EN);
					if (_ten.actual < _ten.control) {
						return true;
					}
				}
			}
			return false;
		}).
		setExecute(function(_caster, _target) {
			var _ret = {result: false, value: 0};
			var _ccontrol = _caster.getControl(), _tcontrol = _target.getControl();
			// Que los 2 esten vivos
			if (_ccontrol.getState(STATE_VIVO) && _tcontrol.getState(STATE_VIVO) ) {
				var _cstats = _caster.getStat(), _tstats = _target.getStat();
				// obtener EPM del caster y EN del target
				var _cep = _cstats.get(STAT_EPM);
				if (_cep.actual >= consume) { // Asegurarse que posea más energía que el consumo
					var _ten = _tstats.get( STAT_EN);
					if (_ten.actual < _ten.control) {
						// Quitar EPM de consumo
						_cstats.add(STAT_EPM, -consume, MALL_NUMTYPE.REAL);
						// Guardar valor recuperado
						_ret.value  = _tstats.add(STAT_EN, 10, MALL_NUMTYPE.PERCENT, 5);
						_ret.result = true;	
					}
				}
			}

			return (_ret);
		}).
		setType(DARK_TYPE_ALLMENU)
	);
	
	#macro DARK_COMMAND_HEAL2 "DARK.COMMAND.HEAL2"
	dark_create_command(
		new DarkCommand(DARK_COMMAND_HEAL2, 60, false, 1).
		setExecute(function(_caster, _target) {
			var _ret = {result: false, value: 0};
			var _ccontrol = _caster.getControl(), _tcontrol = _target.getControl();
			// Que los 2 esten vivos
			if (_ccontrol.getState(STATE_VIVO) && _tcontrol.getState(STATE_VIVO) ) {
				var _cstats = _caster.getStat(), _tstats = _target.getStat();
				// obtener EPM del caster y EN del target
				var _cep = _cstats.get(STAT_EPM);
				if (_cep.actual >= consume) { // Asegurarse que posea más energía que el consumo
					var _ten = _tstats.get( STAT_EN);
					if (_ten.actual < _ten.control) {
						// Quitar EPM de consumo
						_cstats.add(STAT_EPM, -consume, MALL_NUMTYPE.REAL);
						// Guardar valor recuperado
						_ret.value  = _tstats.add(STAT_EN, 25, MALL_NUMTYPE.PERCENT, 5);
						_ret.result = true;	
					}
				}
			}

			return (_ret);
		}).
		setType(DARK_TYPE_ALLMENU)
	);

	#macro DARK_COMMAND_HEAL3 "DARK.COMMAND.HEAL3"
	dark_create_command(
		new DarkCommand(DARK_COMMAND_HEAL3, 90, true, 1).
		setCheck  (function(_caster, _target) {
			var _ccontrol = _caster.getControl(), _tcontrol = _target.getControl();
			// Que los 2 esten vivos
			if (_ccontrol.getState(STATE_VIVO) && _tcontrol.getState(STATE_VIVO) ) {
				var _cstats = _caster.getStat(), _tstats = _target.getStat();
				// obtener EPM del caster y EN del target
				var _cep = _cstats.get(STAT_EPM);
				if (_cep.actual >= consume) { // Asegurarse que posea más energía que el consumo
					var _ten = _tstats.get( STAT_EN);
					if (_ten.actual < _ten.control) {
						return true;
					}
				}
			}
			
			return false;
		}).
		setExecute(function(_caster, _target) {
			var _ret = {result: false, value: 0};
			var _ccontrol = _caster.getControl(), _tcontrol = _target.getControl();
			// Que los 2 esten vivos
			if (_ccontrol.getState(STATE_VIVO) && _tcontrol.getState(STATE_VIVO) ) {
				var _cstats = _caster.getStat(), _tstats = _target.getStat();
				// obtener EPM del caster y EN del target
				var _cep = _cstats.get(STAT_EPM);
				if (_cep.actual >= consume) { // Asegurarse que posea más energía que el consumo
					var _ten = _tstats.get( STAT_EN);
					if (_ten.actual < _ten.control) {
						// Quitar EPM de consumo
						_cstats.add(STAT_EPM, -consume, MALL_NUMTYPE.REAL);
						// Guardar valor recuperado
						_ret.value  = _tstats.add(STAT_EN, 40, MALL_NUMTYPE.PERCENT, 5);
						_ret.result = true;	
					}
				}
			}

			return (_ret);
		}).
		setType(DARK_TYPE_ALLMENU)
	);

	#macro DARK_COMMAND_ANTIDOTO "DARK.COMMAND.ANTIDOTO"
	dark_create_command(
		new DarkCommand(DARK_COMMAND_ANTIDOTO, 60, true, 1).
		setExecute(function(_caster, _target) {
			var _ret = {result: false, value: 0};
			var _ccontrol = _caster.getControl(), _tcontrol = _target.getControl();
			// Que los 2 esten vivos
			if (_ccontrol.getState(STATE_VIVO) && _tcontrol.getState(STATE_VIVO) ) {
				var _cstats = _caster.getStat(), _tstats = _target.getStat();
				// obtener EPM del caster y EN del target
				var _cep = _cstats.get(STAT_EPM);
				if (_cep.actual >= consume) { // Asegurarse que posea más energía que el consumo
					var _ten = _tstats.get( STAT_EN);
					if (_ten.actual < _ten.control) {
						// Quitar EPM de consumo
						_cstats.add(STAT_EPM, -consume, MALL_NUMTYPE.REAL);
						// Guardar valor recuperado
						_ret.value  = _tstats.add(STAT_EN, 10, MALL_NUMTYPE.PERCENT, 5);
						_ret.result = true;	
					}
				}
			}

			return (_ret);
		}).
		setType(DARK_TYPE_BATTLE)
	);

	// ATAQUE 01
	var _ = new DarkCommand("DARK.COMMAND.ATAQUE.01", 0, true, 1).setExecute(function(_caster, _target, _vars) {
			// Solo ataca a 1
			var _fn = dark_get_function("fWateDefaultAttack");
			
			var _cStats = _caster.getStat();
			var _tStats = _target.getStat();
			
			var _cFUE = _cStats.get( STAT_FUERZA).control;
			var _cPOW = _cStats.get(  STAT_PODER).control;
			var _tDEF = _tStats.get(STAT_DEFENSA).control;
			
			var _attackResult = _fn(_cPOW, _cFUE, _tDEF);
			
			// Dañar al target y obtener el daño producido
			var _substractResult = _tStats.add(STAT_EN, -_attackResult);
			
			var _nameCaster = lexicon_text(_caster.displayKey);
			var _nameTarget = lexicon_text(_target.displayKey);
			var _msg = lexicon_text("UI.MESSAGES.ATTACK.01", _nameCaster, _nameTarget, string(_attackResult) );
			oCoManager.msgSend(_msg, 60);
			oCoManager.msgAdvance();
			
			// Si el target es 0
			if (_tStats.isBelow(STAT_EN, 1) ) {
				// Indicar que esta muerto
				var _alive = _target.getControl();
				_alive.setState(STATE_VIVO, false);
				
				_msg = lexicon_text("UI.MESSAGES.DEFEAT.01", _nameTarget);
				oCoManager.msgSend(_msg, 60);
				oCoManager.msgAdvance();
			}
	})
	_.type = DARK_TYPE_BATTLE; // Solo se puede usar en batallas
	_.onSelf    = false;
	_.onAllies  = false;
	_.onEnemies = true;  // Solo se pueden seleccionar enemigos
	
	dark_create_command(_);
	
	#region CAST.FORED
	_ = new DarkCommand("DARK.COMMAND.CAST.FORED", 20, true, 1).setExecute(function(_caster) {
		var _stats   = _caster.getStat();
		var _control = _caster.getControl();
		
		var _epm = _stats.get(STAT_EPM); 
		
		// Revisar el uso de ectoplasma
		var _consume = 20;
		if (_control.getState(STATE_VORTEX) ) _consume *= 1.5;

		var _name = lexicon_text(_caster.displayKey), _msg;
		// Comprobar que poseo la energía
		if (_epm.actual > _consume) {
			_stats.add(STAT_EPM, -_consume);
			_msg = lexicon_text("UI.MESSAGES.CAST.FORED", _name);
			oCoManager.msgSend(_msg, 60);
			oCoManager.msgAdvance();
			
			// Actualizar stats de los personajes en la party
			oCoManager.updatePartyStats();
			
			// Completado
			return true;
		}
		else {
			// Error
			return false;
		}
	});
	_.type = DARK_TYPE_BATTLE;
	_.onSelf   = true;
	_.onAllies = false;
	_.onEnemies = true;
	_.setVar("animation", method(_, function(entity, target) {
		var _vt = vuelta("CAST.FORED::Animation", [
			// Que se mueva la instancia del caster
			new VueltaMove("instanceE", 1, -24, 0, true, 0.0, 0.3),
			new VueltaMethod(function() {
				var _command = getVariable("Command");
				_command.exAction(getVariable("Entity") );
			}),
			new VueltaMove("instanceE", 1,  24, 0, true)
		]);
		
		// Establecer variables para la vuelta!
		_vt.setVariable("Command",   self);
		_vt.setVariable("Entity" , entity);
		_vt.setVariable("Target" , target);
		_vt.setVariable("instanceE", entity.getVar("Instancia") );
		_vt.setVariable("instanceT", target.getVar("Instancia") );
		
		// Para que espere que termine el vuelta para continuar
		entity.setVar("WaitFor", _vt.start() );
	}) );
	
	#endregion
	
	
	dark_create_command(_);




	#endregion
}