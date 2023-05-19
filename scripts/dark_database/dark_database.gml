#macro DARK_CATEGORY_AYUDA "DARK.CATEGORY.AYUDA"
#macro DARK_CATEGORY_CAST "DARK.CATEGORY.CAST"
#macro DARK_TYPE_ALLMENU   "MENU&BATALLA"
#macro DARK_TYPE_MENU      "MENU"
#macro DARK_TYPE_BATTLE    "BATALLA"
#macro DARK_TYPE_EXTRA     "EXTRAS"

/// En esta funcion se inician todos los comandos y funciones para usar en MallRPG
function dark_database() 
{
	#macro DARK_COM_DEFAULT_ATTACK "DARK.COM.DEFAULT.ATTACK"
	dark_create(new (function() : DarkCommand(DARK_COM_DEFAULT_ATTACK) constructor 
	{
		// No aparecer en el menu
		type = DARK_TYPE_BATTLE;
	
		/// @param {Struct.PartyEntity} caster
		/// @param {Struct.PartyEntity} target
		static cinematic = function(_caster, _target) 
		{
			var _vtName = "BattleAnimation::" + key;
			var _vt = vuelta(_vtName, [
				new VueltaMove(  "instance", 1, -24, 0, true, 0.0, 0.1),
				new VueltaMethod(function() /*=>*/ {
					var _instance  = getVariable("instance");
					
					with (_instance) {
						customShader = shNegativeColor;
						call_later(.1, time_source_units_seconds, function() /*=>*/ {;customShader = noone});
					}
					
					// Sonido
					cueca_play(AUD_SOUND, snCombateGolpe01);
					
					// Avanzar mensajes y ejecutar comando de ataque fisico
					oCoManager.msgAdvance();
					var _this      = getVariable(  "this");
					var _objective = getVariable("target");
					var _command = getVariable("command");
					
					method(_this, action) (_objective);
				}),
				// Cambiar de color al target
				new VueltaMethod(function()/*=>*/{
					var _instance = getVariable("instanceT");
					with (_instance) {
						customShader = shNegativeColor;
						call_later(.1, time_source_units_seconds, function() /*=>*/ {;customShader = noone});
					}
					// Regresar personaje a donde estaba
					var _return = vuelta("BattleAnimation::ReturnPlayer", [
						new VueltaMove("instance" , 1, 24, 0, true)
					] )
					_return.setVariable("instance", getVariable("instance") );
					_return.start();
				}),
				new VueltaMove("instanceT", 2, -8, 0, true),
				new VueltaMove("instanceT", 2,  8, 0, true),
				new VueltaLoop(function() /*=>*/ {
					if (oCoManager.msgIsReady() ) {
						oCoManager.msgAdvance();
						return true;
					}
					
					return false;
				})
			] );
			
			_vt.setVariable("this"   , self);
			_vt.setVariable("command", _command);
			_vt.setVariable("target" ,  _target);
			_vt.setVariable("instance" , getVar("Instancia") );
			_vt.setVariable("instanceT", _target.getVar("Instancia") );
			
			setVar("WaitFor", _vt.start() );
		}
	
		static action = DK_DefaultAttack
	
	})());
	
	
	
	#region Dark Objetos
	/// Aumentar el especial en 20% por 1 turno cada 2 turnos
	dark_create_function("fPocketJonDibujo", function(_vars) {
	
	});
	
	var _thin = "";
	
	#endregion


	#region Dark Commands
	#macro DARK_COMMAND_HEAL1 "DARK.COMMAND.HEAL1"
	dark_create(
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
	dark_create(
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
	dark_create(
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
	dark_create(
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
	
	dark_create(_);
	
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
	
	
	dark_create(_);




	#endregion
}


function DK_DefaultAttack(_target)
{
	var _cf = statGet(STAT_FUERZA).control;
	var _td = _target.statGet(STAT_DEFENSA).control;
	
	var _sum = (_cf + _td) / 80;
	var _res = _cf / _td;
	
	var _power = statGet(STAT_PODER).control;
	return round(_power * _res * _sum)
}

function DK_DefaultPoisoned()
{
	return (statAdd(STAT_EN, -30, MALL_NUMTYPE.PERCENT, 2) );
}

function DK_DefaultBurned()
{
	return (statAdd(STAT_EN, -10, MALL_NUMTYPE.PERCENT, 2) );
}

function DK_DefaultPassTurn()
{
	pass = true;
	passCount++;
}


#region Efectos
#macro DARK_EFF_DIBUJO "DARK.EFF.DIBUJO"
function DK_ACCDibujo() : DarkEffect(DARK_EFF_DIBUJO, "") constructor
{
	stateKey = "ACCDibujo1";
	
	/// @param {Struct.PartyEntity} entity
	static added = function(entity) 
	{
		var _control = entity.controlGet(stateKey);
		
		// Añadir
		_control.stats[$ STAT_FESPECIAL] = [10, MALL_NUMTYPE.PERCENT];
		array_push(_control.statsKeys, STAT_FESPECIAL);
	}
	
	/// @param {Struct.PartyEntity} entity
	static combatEnd = function(entity)
	{
		entity.controlEffectRemove(stateKey, function(effect) {return (effect.key = DARK_EFF_DIBUJO);} );
	}
}

#endregion
