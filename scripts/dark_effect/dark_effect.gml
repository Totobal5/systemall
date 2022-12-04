/// @param {String}      effectKey
/// @param {Real}        startValue
/// @param {Real, Array} turnStart          array para una cantidad aleatoria
/// @param {Real, Array} turnEnd            array para una cantidad aleatoria
/// @param {Function}    [funTurnStart]
/// @param {Function}    [funTurnEnd]
function DarkEffect(_effectKey, _startVal, _turnStart, _turnEnd, _funTurnStart, _funTurnEnd) : Mall(_effectKey) constructor 
{
	static effectNumber = 1;
	id = string("{0}{1}:{2}", _effectKey, "DE", effectNumber++);
	commandKey = "" // Que Comando lo crea
	
	
	value = _startVal; // Valor que cambia real/porcentual
	ready = false;     // Se marca que el efecto termino
	
	turn = 0;        // En que turno va
	turnMarkStart = 0;   // En que turno global empezo
	turnMarkEnd   = 0;   // En que turno global termino
	turnType = 0;
	/*
		0: Inicio del turno
		1: Final  del turno
		2: En el inicio y final del turno
	*/
	
	// Crear iteradores
	iteratorStart = new iteratorCreate();    // Inicio turno
	
	iteratorStart.countLimits = (is_array(_turnStart) ) ?
		irandom_range(_turnStart[0], _turnStart[1]) :
		_turnStart;

	iteratorEnd   =  new iteratorCreate();  // Final de turno
	
	iteratorFinish.countLimits = (is_array(_turnEnd) ) ?
		irandom_range(_turnEnd[0], _turnEnd[1]) :
		_turnEnd;

	
	#region METHODS

	/// @desc Evento a ejecutar cuando inicio el turno
	turnStart = __dummy;
	
	/// @desc Evento a ejecutar cuando termina el turno
	turnEnd   = __dummy;
	
	/// @desc Evento a ejecutar cuando es eliminado
	remove    = __dummy;
	
	/// @param {Real} value
	/// @param {Enum.MALL_NUMTYPE} numtype
	static set = function(_value, _type)
	{
		_type ??= type;
		value[_type] = _value;
	}
	
	
	/// @param {Real} value
	/// @param {Enum.MALL_NUMTYPE} numtype
	static add = function(_value, _type)
	{
		_type ??= type;
		value[_type] += _value;
	}
	
	
	/// @param {Real} turnType
	static getIterator = function(_type=0)
	{
		return (!_type) ? iteratorStart  : iteratorEnd;
	}
	
	
	/// @param {Real} turnType
	static getEvent = function(_type=0)
	{
		return (!_type)	? turnStart : turnEnd;
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