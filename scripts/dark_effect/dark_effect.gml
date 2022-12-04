/// @param {String} effect_key
/// @param {Real} start_value
/// @param {Real, Array} turn_start		array para una cantidad aleatoria
/// @param {Real, Array} turn_finish	array para una cantidad aleatoria
/// @param {Function} [event_start]
/// @param {Function} [event_finish]
function DarkEffect(_KEY, _START, _TURNS_START, _TURNS_FINISH, _TURN_EVENT_START, _TURN_EVENT_FINISH) : MallStat(_KEY, false) constructor 
{
	static effectsCreated = 0;
	id = _KEY + "DE"; // ID unica del efecto
	effectsCreated++;
	
	value = _START;	 // Valor que cambia real/porcentual
	ready = false;	 // Se marca que el efecto termino
	commandKey = ""; // Que comando lo crea
	turn = 0;		 // En que turno va
	turnType = 0;	 // 0 en el inicio del turno 1 en el final del turno 2 en ambos
	turnStart  = 0;  // En que turno empezo
	turnFinish = 0;	 // En que turno termino
	
	// Crear iteradores
	iteratorStart = new __MallIterator();	// Inicio turno
	iteratorStart.countLimits = (is_array(_TURNS_START) ) ?
		irandom_range(_TURNS_START[0], _TURNS_START[1] ) :
		_TURNS_START;
	
	iteratorFinish = new __MallIterator();  // Final de turno
	iteratorFinish.countLimits = (is_array(_TURNS_FINISH) ) ?
		irandom_range(_TURNS_FINISH[0], _TURNS_FINISH[1] ) :
		_TURNS_FINISH;
		
	// Establecer eventos de inicio de turno y final de turno
	setEventTurnStart (_TURN_EVENT_START);
	setEventTurnFinish(_TURN_EVENT_FINISH);
	
	/// @desc Evento a ejecutar cuando termina el turno
	eventRemove = function() {}

	#region METHODS
	/// @param {Real} value
	/// @param {Enum.MALL_NUMTYPE} numtype
	static set = function(_VALUE, _TYPE)
	{
		_TYPE ??= type;
		value[_TYPE] = _VALUE;
	}
	
	
	/// @param {Real} value
	/// @param {Enum.MALL_NUMTYPE} numtype
	static add = function(_VALUE, _TYPE)
	{
		_TYPE ??= type;
		value[_TYPE] += _VALUE;
	}
	
	
	/// @param {Real} turn_type
	static getIterator = function(_type=0)
	{
		return (!_type) ? iteratorStart  : iteratorFinish;
	}
	
	
	/// @param {Real} turn_type
	static getEvent = function(_type)
	{
		return (!_type)	? eventTurnStart : eventTurnFinish;
	}
	
	
	static save = function() 
	{
		var _this = self;
		var _tosave = {};
		with (_tosave) {
			key = _this.key;
			value = _this.value;
			// Guardar iteradores
			iteratorStart  = _this.iteratorStart.save();
			iteratorFinish = _this.iteratorFinish.save();
		}
		
		return (_tosave );
	}
	
	#endregion
}