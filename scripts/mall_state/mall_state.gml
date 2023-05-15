// Feather ignore all

/// @desc Donde se guardan las propiedades de los estados
/// @param {String} stateKey
/// @param {Bool}   [useIterator]
function MallState(_KEY) : MallMod(_KEY) constructor
{
	init = false;             // Valor inicial del estado
	type = MALL_NUMTYPE.REAL; // Tipo de numero que utiliza
	
	same = false;   // Si acepta el mismo efecto varias veces
	controls = -1;  // Cuantos se pueden agregar en party. -1 para infinitos (NO PUEDE SER 0)
	percent  =  0;  // Probabilidad default
	
	/// @desc Si puede actuar en PartyControl
	/// @param {Any*} [vars]
	checkStart = "";
	
	/// @desc Comprobar si puede usar su final event
	/// @param {Any*} [vars]
	checkEnd   = "";
	
	#region METHODS
	/// @desc Establece el valor inicial y el limite de este mismo estado (-1 es infinitos)
	/// @param {Bool, Real} startValue        Boleano inicial
	/// @param {Real}       probability       Probabilidad default
	/// @param {Real}       [controlMax]=-1   Limites de estados en los controles
	/// @param {Bool}       [acceptSame]=true Si permite el mismo estado en los controles
	static setControl = function(_initBool, _prob, _controls=-1, _same=true)
	{
		init     = _initBool;
		percent  = _prob;
		
		controls = _controls;
		same     = _same;
		
		return self;
	}
	
	/// @desc Function Description
	/// @param {String} checkStart  Description
	/// @param {String} [checkEnd]  Description
	/// @returns {struct} Description
	static setCheckSE = function(_checkS, _checkE)
	{
		checkStart = _checkS ?? checkStart;
		checkEnd   = _checkE ??   checkEnd;
		return self;
	}
	

	#endregion
}

/// @param	{String} stateKey
/// @desc	Crea un estado
function mall_add_state() 
{
	static states = MallDatabase.states;
	static keys   = MallDatabase.statesKeys;
	static DebugMessage = MallDatabase.statesDebugMessage;
	
    var i=0; repeat(argument_count) {
		var _key = argument[i];
		if (!variable_struct_exists(states, _key) ) {
			states[$ _key] = new MallState(_key);
			array_push(keys, _key);
			if (MALL_TRACE) DebugMessage("(AddState): " + _key + " added");
		}

		i = i+1;
	}
}

/// @param {String} state_key
/// @desc Obtiene el estado en el grupo actual
/// @return {Struct.MallState}
function mall_get_state(_stateKey)
{
	static states = MallDatabase.states;
	return (states[$ _stateKey] );
}

/// @param {String}	stateKey
function mall_exists_state(_stateKey)
{
	static states = MallDatabase.states;
	return (variable_struct_exists(states, _stateKey) );
}

/// @param	{String}    stateKey        Llave del estado
/// @param	{Bool,Real} startBoolean    Boleano inicial
/// @param	{Real}      probability     Probabilidad default
/// @param	{Real}      [controlMax]    Limites de estados en los controles
/// @param	{Bool}      [acceptSame]    Si permite el mismo estado en los controles
/// @param	{String}    [displayKey]    Llave para las traducciones
/// @returns {Struct.MallState}
function mall_customize_state(_stateKey, _startBool, _probability, _controlMax, _acceptSame, _displayKey) 
{	
	if (MALL_ERROR) {
		if (!mall_exists_state(_stateKey) ) show_error(string("MallRPG (customState): {0} no existe", _stateKey), false);
	}
	var _state = mall_get_state(_stateKey);
	_state.setControl(_startBool, _probability, _controlMax, _acceptSame);
    return (_state.setDisplayKey(_displayKey) );
}

/// @desc Devuelve todos las llaves de estado
/// @returns {Array<String>}
function mall_get_state_keys(_copy=false)
{
	static keys = MallDatabase.statesKeys;
	if (_copy) {
		var _array = array_create(0);
		array_copy(_array, 0, keys, 0, array_length(keys) );
		return _array;
	} else {
		return (keys);
	}
}