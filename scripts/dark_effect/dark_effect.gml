// Feather ignore all

/// @param {string} effectKey
/// @param {string} stateKey
function DarkEffect(_stateKey, _effectKey) : Mall(_effectKey) constructor 
{
	static effectNumber = 1;
	id = string("{0}{1}:{2}", _effectKey, "DE", effectNumber);
	
	// Estado que afecta o crea
	stateKey = _stateKey
	stateSet = true;
	
	// Valor que cambia real/porcentual
	value = 0;
	type  = MALL_NUMTYPE.REAL;
	
	// Se marca que el efecto termino
	isReady = false;
	
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
	// Inicio turno
	iteratorStart = new MallIterator();
	// Final de turno
	iteratorEnd   = new MallIterator();
	
	#region METHODS
	/// @desc Evento a ejecutar cuando se agrega en un partyControl
	/// @param {Struct.PartyEntity} entity
	static added  = function(entity) 
	{
		var _atom = entity.controlGet(stateKey);
		_atom.state = stateSet;
	}
	
	static entityUpdate = function(entity) {}
	
	static combatEnd = function(entity)
	{
		
	}
	
	/// @desc Evento a ejecutar cuando inicio el turno
	static turnStart = function() {};
	/// @desc Evento a ejecutar cuando termina el turno
	static turnEnd   = function() {};
	
	/// @desc Evento a ejecutar cuando es completado
	static ready  = function() {};
	/// @desc Evento a ejecutar cuando es eliminado
	static remove = function() {};

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
			is =  _this.is;
			// Llaves
			key = _this.key;
			
			// Valores
			value = _this.value;
			type =  _this.type;
			
			// Stats
			stateKey = _this.stateKey;
			stateSet = _this.stateSet;
	
			// Turnos
			isReady = _this.isReady;
			turn =    _this.turn;
			turnMarkStart = _this.turnMarkStart;
			turnMarkEnd =   _this.turnMarkEnd;
			turnType =      _this.turnType;
			
			// Guardar iteradores
			iteratorStart  = _this.iteratorStart.save();
			iteratorEnd    = _this.iteratorEnd.save()  ;
			
			return self;
		}
	}
	
	/// @desc Cargar este componente
	/// @param {Struct} loadStruct
	static load = function(_l)
	{
		// Valores
		value = _l.value;
		type  = _l.type;
		// Set
		stateKey = _l.stateKey;
		stateSet = _l.stateSet;
		
		// Turnos
		isReady = _l.isReady;
		turn =    _l.turn;
		turnMarkStart = _l.turnMarkStart;
		turnMarkEnd =   _l.turnMarkEnd;
		turnType =      _l.turnType;
			
		// Guardar iteradores
		iteratorStart.load(_l.iteratorStart);
		iteratorEnd  .load(_l.iteratorEnd);
	}
	
	
	#endregion
}