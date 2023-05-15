// Feather ignore all

/// @param {String} slotKey
/// @return {Struct.MallSlot}
function MallSlot(_KEY) : MallStat(_KEY) constructor 
{
	/// @desc Devuelve la comparación entre 2 objetos en un mismo slot function(_entity, _itemA, _itemB) {return struct<reals>}
	/// @return {struct}
	/*
		{ STAT_KEY: DIFERENCE_VALUE}
	*/
	funCompare = "";
	
	/// @desc Comprueba si un objeto pasa alguna prueba para equiparse function(_entity, _item) {return bool}
	checkItem  = "";
	
	// init: Indica si inicia activado o desactivado (Definido en MallState)
	init = true;
	
	#region METHODS
	
	/// @desc function(_item) {return <bool>}
	/// @param {string} checkItem Dark function
	static setCheckItem  = function(_fn)
	{
		checkItem = _fn;
		return self;
	}

	/// @desc 
	/// @param {string} funCompare Dark function
	static setFunCompare = function(_fn) 
	{
		funCompare = _fn;
		return self;
	}
	
	static setInitalState = function(_isActive) 
	{
		init = _isActive;
	}
	
	#endregion
}

/// @desc	Crear un (o varios) ranura globalmente
/// @param	{String} slotKey Llaves
function mall_add_slot() 
{
	static slots = MallDatabase.slots;
	static keys  = MallDatabase.slotsKeys;
	static DebugMessage = MallDatabase.slotsDebugMessage;
	var i=0; repeat(argument_count) 
	{
		var _key = argument[i];
		if (!variable_struct_exists(slots, _key) ) {
			slots[$ _key] =new MallSlot(_key);
			array_push(keys, _key);
			if (MALL_TRACE) DebugMessage("(AddSlot): " + _key + " added");
		}
		
		i = i+1;
	}
}

/// @param {String}	slotKey
function mall_exists_slot(_slotKey)
{
	static slots = MallDatabase.slots;
	return (variable_struct_exists(slots, _slotKey) );
}

/// @desc	Devuelve el equipamiento
/// @param	{String} slotKey
/// @returns {Struct.MallSlot}
function mall_get_slot(_key) 
{
	static slots = MallDatabase.slots;
	return (slots[$ _key] );
}

/// @param {String} slotKey         
/// @param {Bool}   initialState    Si inicia activo o no
/// @param {String} [displayKey]    Llave para traducciones en lexicon
/// @returns {Struct.MallSlot}
function mall_customize_slot(_slotKey, _isActive, _displayKey)
{
	var _slot = mall_get_slot(_slotKey);
	_slot.setInitalState(  _isActive);
	_slot.setDisplayKey( _displayKey);
	return (_slot);
}

/// @desc Devuelve todos las llaves de partes
/// @returns {Array<String>}
function mall_get_slot_keys(_copy=false) 
{
	static keys = MallDatabase.slotsKeys;
	if (_copy) {
		var _array = array_create(0);
		array_copy(_array, 0, keys, 0, array_length(keys) );
		return _array;
	} else {
		return (keys);
	}
}