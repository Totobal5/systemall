/// @desc Donde se guardan las propiedades de los estados
/// @param {String}	stateKey
/// @param {Bool} [useIterator]
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
	/**
	* Establece el valor inicial y el limite de este mismo estado (-1 es infinitos)
	* @param {Bool} initial_bool		Description
	* @param {Real} default_probability	Description
	* @param {Real} [control_max]=-1	Description
	* @param {Bool} [accept_same]=true	Description
	*/
	static setControl = function(_BOOL, _PROBABILITY, _CONTROLS=-1, _SAME=true)
	{
		init = _BOOL;
		percent = _PROBABILITY;
		
		controls = _CONTROLS;
		same = _SAME;
		
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
	static states = MallDatabase().states;
	static keys   = MallDatabase().statesKeys;
	
    var i=0; repeat(argument_count) {
		var _key = argument[i];
		if (!variable_struct_exists(states, _key) ) {
			states[$ _key] = new MallState(_key);
			array_push(keys, _key);
			if (MALL_TRACE) {show_debug_message("MallRPG (addState): {0} added", _key); }
		}

		i = i+1;
	}
}

/// @param {String} state_key
/// @desc Obtiene el estado en el grupo actual
/// @return {Struct.MallState}
function mall_get_state(_stateKey)
{
	static states = MallDatabase().states;
	return (states[$ _stateKey] );
}

/// @param {String}	stateKey
function mall_exists_state(_stateKey)
{
	static states = MallDatabase().states;
	return (variable_struct_exists(states, _stateKey) );
}

/// @param	{String}	stateKey		llave del estado
/// @param	{Real}		startBoolean	boleano inicial
/// @param	{Real}		probability		probabilidad default
/// @param	{Real}		[controlMax]	limites de estados en los controles
/// @param	{Bool}		[acceptSame]	si permite el mismo estado en los controles
/// @param	{String}	[displayKey]	llave para las traducciones
/// @returns {Struct.MallState}
function mall_customize_state(_stateKey, _startBool, _probability, _controlMax, _acceptSame, _displayKey) 
{	
	if (MALL_ERROR) {
		if (!mall_exists_state(_stateKey) ) show_error("MallRPG (customState): no existe la llave de estadistica", false);
	}
	
    var _state = mall_get_state(_stateKey);
	_state.setControl(_startBool, _probability, _controlMax, _acceptSame);
    return ( _state.setDisplayKey(_displayKey) );
}

/// @desc Devuelve todos las llaves de estado
/// @returns {Array<String>}
function mall_get_state_keys(_copy=false)
{
	static keys = MallDatabase().statesKeys;
	if (_copy) {
		var _array = array_create(0);
		array_copy(_array, 0, keys, 0, array_length(keys) );
		return _array;
	} else {
		return (keys);
	}
}