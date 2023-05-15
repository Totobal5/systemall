// Feather ignore all

/// @param {String}            effectKey
/// @param {Real}              startValue
/// @param {Enum.MALL_NUMTYPE} startType
/// @param {Real, Array}       turnStart          array para una cantidad aleatoria
/// @param {Real, Array}       turnEnd            array para una cantidad aleatoria
/// @param {string}            [funTurnStart]
/// @param {string}            [funTurnEnd]
function DarkEffect(_effectKey, _startVal, _startType, _turnStart, _turnEnd, _funTurnStart, _funTurnEnd) : Mall(_effectKey) constructor 
{
	static effectNumber = 1;
	id = string("{0}{1}:{2}", _effectKey, "DE", effectNumber);
	commandKey = "" // Que Comando lo crea

	value =  _startVal; // Valor que cambia real/porcentual
	type  = _startType;
	
	// Se marca que el efecto termino
	ready = false;
	
	turn = 0; // En que turno va
	turnMarkStart = 0;   // En que turno global empezo
	turnMarkEnd   = 0;   // En que turno global termino
	turnType      = 0;
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
	iteratorEnd.countLimits = (is_array(_turnEnd) ) ?
		irandom_range(_turnEnd[0], _turnEnd[1]) :
		_turnEnd;

	
	#region METHODS
	funAdded = "" // Evento a ejecutar cuando se agrega en un partyControl
	
	/// @desc Evento a ejecutar cuando inicio el turno
	funTurnStart = "";
	
	/// @desc Evento a ejecutar cuando termina el turno
	funTurnEnd   = "";
	
	/// @desc Evento a ejecutar cuando es completado
	funReady  = "";
	
	/// @desc Evento a ejecutar cuando es eliminado
	funRemove = "";

	/// @param {struct.PartyEntity} partyEntity
	exAdded = function(_entity)
	{
		static fun = dark_get_function(funAdded);
		return (fun(_entity) );
	}

	/// @param {struct.PartyEntity} partyEntity
	exReady = function(_entity)
	{
		static fun = dark_get_function(funReady);
		return (fun(_entity) );
	}
	
	/// @param {struct.PartyEntity} partyEntity
	exRemove =  function(_entity)
	{
		static fun = dark_get_function(funRemove);
		return (fun(_entity) );
	}
	
	/// @param {Real} turnType
	/// @param {struct.PartyEntity} partyEntity
	exTurn = function(_type=0, _entity)
	{
		static tstart = dark_get_function(funTurnStart);
		static tend   = dark_get_function(funTurnEnd);
		return (!_type) ? tstart(_entity) : tend(_entity)
	}
	
	
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
	
	/// @desc Guarda este componente
	static save = function() 
	{
		var _this = self;
		var _save = {};
		with (_save) {
			version = MALL_VERSION;
			is      =     _this.is;
			
			key        = _this.key       ;
			commandKey = _this.commandKey; // Guardar llave del comando
			
			value = _this.value;
			
			// Funciones
			turnStart = _this.turnStart;
			turnEnd   = _this.turnEnd  ;
			remove    = _this.remove   ;
			
			// Guardar iteradores
			iteratorStart  = _this.iteratorStart.save();
			iteratorEnd    = _this.iteratorEnd.save()  ;
			
			return self;
		}
	}
	
	/// @desc Cargar este componente
	/// @param {Struct} loadStruct
	static load = function(_load)
	{
		if (_load.is != is) exit;
		//var _newEffect = new DarkEffect();
	}
	
	
	#endregion
}