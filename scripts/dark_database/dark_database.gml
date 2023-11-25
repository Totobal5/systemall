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
	
	#macro DARK_COMMAND_HEAL1 "DARK.COMMAND.HEAL1"
	dark_create(new function() : DarkCommand(DARK_COMMAND_HEAL1) constructor
	{
		type = DARK_TYPE_ALLMENU;
		consume = 10;
		restore = 10;
		targets =  1;
		
		/// @param {Struct.PartyEntity} caster
		/// @param {Struct.PartyEntity} target
		static check = function(caster, target)
		{
			var _casterAlive = caster.controlState(STATE_VIVO);
			var _targetAlive = target.controlState(STATE_VIVO);
			if (_casterAlive && _targetAlive) {
				var _casterEPM = caster.statGet(STAT_EPM);
				// Asegurarse que el caster posee más energía que el consumo
				if (_casterEPM.actual >= getConsume(caster)) {
					var _targetEN = target.statGet(STAT_EN);
					// Que posea si o si menos que el control
					if (_targetEN.actual < _targetEN.control) return true;
				}
			}
			
			return false;
		}

		/// @param {Struct.PartyEntity} caster
		/// @param {Struct.PartyEntity} target
		static action = function(caster, target)
		{
			var _return = {result: false, consumed: 0, value: 0};
			// Si no estan vivos
			if (caster.controlState(STATE_VIVO) && target.controlState(STATE_VIVO) ) {
				return (_return);
			}
			_return.consumed = caster.statAdd(STAT_EPM, -getConsume(caster), MALL_NUMTYPE.REAL);
			_return.value =    target.statAdd(STAT_EN,   restore,      MALL_NUMTYPE.PERCENT, 5);
			
			_return.result = true;
			
			return (_return);
		}
		
		static getConsume = function(caster) 
		{
			return consume * (caster.controlState(STATE_VORTEX) ? 1.5 : 1);
		}
	
	}());
	
	#macro DARK_COMMAND_HEAL2 "DARK.COMMAND.HEAL2"
	dark_create(new function() : DarkCommand(DARK_COMMAND_HEAL2) constructor
	{
		type = DARK_TYPE_ALLMENU;
		consume = 60;
		restore = 25;
		target =  1;
		
		/// @param {Struct.PartyEntity} caster
		/// @param {Struct.PartyEntity} target
		static check =  function(caster, target)
		{
			var _casterAlive = caster.controlState(STATE_VIVO);
			var _targetAlive = target.controlState(STATE_VIVO);
			if (_casterAlive && _targetAlive) {
				var _casterEPM = caster.statGet(STAT_EPM);
				// Asegurarse que el caster posee más energía que el consumo
				if (_casterEPM.actual >= getConsume(caster)) {
					var _targetEN = target.statGet(STAT_EN);
					// Que posea si o si menos que el control
					if (_targetEN.actual < _targetEN.control) return true;
				}
			}
			
			return false;
		}

		/// @param {Struct.PartyEntity} caster
		/// @param {Struct.PartyEntity} target
		static action = function(caster, target) 
		{
			var _return = {result: false, consumed: 0, value: 0};
			// Si no estan vivos
			if (caster.controlState(STATE_VIVO) && target.controlState(STATE_VIVO) ) {
				return (_return);
			}
			
			_return.consumed = caster.statAdd(STAT_EPM, -getConsume(caster), MALL_NUMTYPE.REAL);
			_return.value =    target.statAdd(STAT_EN,    restore, MALL_NUMTYPE.PERCENT, 5); 
			// Cambiar estado
			_return.result = true;
			
			return _return;
		}
	
		static getConsume = function(caster) 
		{
			return consume * (caster.controlState(STATE_VORTEX) ? 1.5 : 1);
		}	
	}());

	#macro DARK_COMMAND_HEAL3 "DARK.COMMAND.HEAL3"
	dark_create(new function() : DarkCommand(DARK_COMMAND_HEAL3) constructor
	{
		type = DARK_TYPE_ALLMENU;
		consume = 90;
		restore = 45;
		target =  1;
		
		/// @param {Struct.PartyEntity} caster
		/// @param {Struct.PartyEntity} target
		static check =  function(caster, target)
		{
			var _casterAlive = caster.controlState(STATE_VIVO);
			var _targetAlive = target.controlState(STATE_VIVO);
			if (_casterAlive && _targetAlive) {
				var _casterEPM = caster.statGet(STAT_EPM);
				// Asegurarse que el caster posee más energía que el consumo
				if (_casterEPM.actual >= getConsume(caster)) {
					var _targetEN = target.statGet(STAT_EN);
					// Que posea si o si menos que el control
					if (_targetEN.actual < _targetEN.control) return true;
				}
			}
			
			return false;
		}

		/// @param {Struct.PartyEntity} caster
		/// @param {Struct.PartyEntity} target
		static action = function(caster, target) 
		{
			var _return = {result: false, consumed: 0, value: 0};
			// Si no estan vivos
			if (caster.controlState(STATE_VIVO) && target.controlState(STATE_VIVO) ) {
				return (_return);
			}
			
			_return.consumed = caster.statAdd(STAT_EPM, -getConsume(caster), MALL_NUMTYPE.REAL);
			_return.value =    target.statAdd(STAT_EN,   restore, MALL_NUMTYPE.PERCENT, 5); 
			// Cambiar estado
			_return.result = true;
			
			return _return;
		}
	
		static getConsume = function(caster) 
		{
			return consume * (caster.controlState(STATE_VORTEX) ? 1.5 : 1);
		}		
	}());

	#macro DARK_COMMAND_ANTIDOTO "DARK.COMMAND.ANTIDOTO"
	dark_create(new function() : DarkCommand(DARK_COMMAND_ANTIDOTO) constructor
	{
		type =    DARK_TYPE_BATTLE;
		consume = 60;

		/// @param {Struct.PartyEntity} caster
		/// @param {Struct.PartyEntity} target
		static check =  function(caster, target)
		{
			// Que ambos esten vivos
			if (!caster.controlState(STATE_VIVO) && !target.controlState(STATE_VIVO) ) return false;
			// Comprobar otras cosas
			var _epm = caster.statGet(STAT_EPM);
			return (target.controlState(STATE_VENENO) && _epm.actual >= getConsume(caster))
		}

		/// @param {Struct.PartyEntity} caster
		/// @param {Struct.PartyEntity} target
		static action = function(caster, target) 
		{
			var _return = {result: false, consumed: 0, value: 0};
			// Que ambos esten vivos
			if (caster.controlState(STATE_VIVO) && target.controlState(STATE_VIVO) ) {
				// Que este envenenado
				if (target.controlState(STATE_VENENO) ) {
					// Posee más del consumo requerido
					var _epm = caster.statGet(STAT_EPM);
					if (_epm.actual >= consume) {
						_return.consumed = caster.statAdd(STAT_EPM, -consume, MALL_NUMTYPE.REAL);
						// Reiniciar control del veneno
						target.controlStateSet(STATE_VENENO, false);
						// Eliminar cada efecto
						target.controlEffectRemoveAll(STATE_VENENO);
						
						_return.result   = true;
					}
				}
			}
			
			return (_return);
		}
	
		static getConsume = function(caster) 
		{
			return consume * (caster.controlState(STATE_VORTEX) ? 1.5 : 1);
		}			
	}());

	// ATAQUE 01
	dark_create(new function() : DarkCommand("DARK.COMMAND.ATAQUE.01") constructor
	{
		// Solo se puede usar en batallas
		type = DARK_TYPE_BATTLE;
		onSelf    = false;
		onAllies  = false;
		
		// Solo se pueden seleccionar enemigos		
		onEnemies = true;  

		/// @param {Struct.PartyEntity} caster
		/// @param {Struct.PartyEntity} target
		static action = function(caster, target, vars) 
		{
			var _return = {damage: 0, defeated: false};
			// Solo ataca a 1
			var _damage = DK_DefaultAttack(caster, target);
			
			// Dañar al target y obtener el daño producido
			var _result = target.statAdd(STAT_EN, -_damage);
			_return.damage = _result;
			
			var _nameCaster = lexicon_text(caster.displayKey);
			var _nameTarget = lexicon_text(target.displayKey);
			var _msg = lexicon_text("UI.MESSAGES.ATTACK.01", _nameCaster, _nameTarget, string(_result) );
			oCoManager.msgSend(_msg, 60);
			oCoManager.msgAdvance();
			
			// Si el target es 0
			if (target.statGet(STAT_EN).control < 1) {
				_return.defeated = true;
				// Indicar que esta muerto
				target.controlStateSet(STATE_VIVO, false);
				
				_msg = lexicon_text("UI.MESSAGES.DEFEAT.01", _nameTarget);
				oCoManager.msgSend(_msg, 60);
				oCoManager.msgAdvance();
			}
		}
	
	}());
	
	#macro DARK_COMMAND_FORED "DARK.COMMAND.FORED"
	dark_create(new function() : DarkCommand(DARK_COMMAND_FORED) constructor 
	{
		type = DARK_TYPE_BATTLE;
		// Cuanto consume
		consume = 20;
		
		onSelf    = true;
		onAllies  = false;
		onEnemies = true;
		
		/// @param {Struct.PartyEntity} caster
		static check =  function(caster)
		{
			// Que el caster este vivo y no posea el estado RED
			if (!caster.controlState(STATE_VIVO) && caster.controlState("CONTROL.RED") ) return false;
			// Comprobar otras cosas
			var _epm = caster.statGet(STAT_EPM);
			return (_epm.actual >= getConsume(caster) );
		}
		
		/// @param {Struct.PartyEntity} caster
		static action = function(caster)
		{
			var _return = {result: false, consumed: 0};
			
			_return.consumed = caster.statAdd(STAT_EPM, -getConsume(caster), MALL_NUMTYPE.REAL);
			_return.result = true;
			
			// Establecer estado
			if (caster.controlExists("CONTROL.RED") ) caster.controlCreate("CONTROL.RED", true);
			
			return (_return);
		}
		
		/// @param {Struct.PartyEntity} caster
		static getConsume = function(caster) 
		{
			var _epm = caster.statGet(STAT_EPM);
			var _con = (_epm.control * consume) / 100; // 20 %
			
			return _con * (caster.controlState(STATE_VORTEX) ? 1.5 : 1);
		}			
	}());

}


function DK_DefaultAttack(caster, target)
{
	var _cf = caster.statGet(STAT_FUERZA) .control;
	var _td = target.statGet(STAT_DEFENSA).control;
	
	var _sum = (_cf + _td) / 80;
	var _res = _cf / _td;
	
	var _power = caster.statGet(STAT_PODER).control;
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
		entity.controlEffectRemove(stateKey, function(effect) {
			return (effect.key = DARK_EFF_DIBUJO);
		} );
	}
}

#endregion
