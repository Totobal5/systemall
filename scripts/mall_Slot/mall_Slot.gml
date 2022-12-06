// Feather ignore all

/// @param {String} slotKey
/// @return {Struct.MallSlot}
function MallSlot(_KEY) : MallStat(_KEY) constructor 
{
	/// @desc Ejecuta un evento al pasar un tipo de objeto
	funItemtype   = "";
	
	/// @desc Comprueba su un tipo de objeto pasa la prueba
	checkItemType = "";
	
	#region METHODS
	/// @desc Para comparar 2 objetos y sus efectos en la entidad
	static compare = function(_stat, _equiped, _compare)
	{
		var _statKeys = mall_get_stat_keys();
		var _eStat = _EQUIPPED.statsNormal;
		var _cStat = _COMPARE .statsNormal;
		var _return = {};
		var i=0; repeat(array_length(_statKeys) )
		{
			var _key  = _statKeys[i];
			var _atom = _stat.get(_key);
			var _eValue = _eStat[$ _key] ?? [0, 0];
			var _cValue = _cStat[$ _key] ?? [0, 0];
			
			var _comp1=0, _comp2=0;
			switch (_eValue[1] )
			{
				case MALL_NUMTYPE.PERCENT:
				_comp1 = (_stat.peak * _eValue[0] ) / 100;
				break;
				
				case MALL_NUMTYPE.REAL:
				_comp1 = (_stat.peak * _eValue[0] );
				break;
			}
			
			switch (_cValue[1] )
			{
				case MALL_NUMTYPE.PERCENT:
				_comp2 = (_stat.peak * _cValue[0] ) / 100;
				break;
				
				case MALL_NUMTYPE.REAL:
				_comp2 = (_stat.peak * _cValue[0] );
				break;
			}			
			
			_return[$ _key] = (_comp1 - _comp2);
			i = i + 1;
		}
		
		return _return;
	}
	
	static setFunItemtype = function(_fun, _check)
	{
		funItemtype   = _fun ?? funItemtype;
		checkItemType = _fun ?? checkItemType;
		return self;
	}
	
	
	#endregion
}

/// @desc	Crear un (o varios) ranura globalmente
/// @param	{String} slotKey Llaves
function mall_add_slot() 
{
	static slots = MallDatabase().slots;
	static keys  = MallDatabase().slotsKeys;
	var i=0; repeat(argument_count) 
	{
		var _key = argument[i];
		if (!variable_struct_exists(slots, _key) ) {
			slots[$ _key] =new MallSlot(_key);
			array_push(keys, _key);
			if (MALL_TRACE) {show_debug_message("MallRPG (addSlot): {0} added", _key); }
		}
		
		i = i+1;
	}
}

/// @param {String}	slotKey
function mall_exists_slot(_slotKey)
{
	static slots = MallDatabase().slots;
	return (variable_struct_exists(slots, _slotKey) );
}

/// @desc	Devuelve el equipamiento
/// @param	{String} slotKey
/// @returns {Struct.MallSlot}
function mall_get_slot(_key) 
{
	static slots = MallDatabase().slots;
	return (slots[$ _key] );
}

/// @param	{String}	slotKey
/// @param	{String}	[displayKey]		Llave para traducciones en lexicon
/// @returns {Struct.MallSlot}
function mall_customize_slot(_slotKey, _displayKey)
{
    var _slot = mall_get_slot(_slotKey);
	_slot.setDisplayKey(_displayKey);
    return (_slot);
}

/// @desc Devuelve todos las llaves de partes
/// @returns {Array<String>}
function mall_get_slot_keys(_copy=false) 
{
	static keys = MallDatabase().slotsKeys;
	if (_copy) {
		var _array = array_create(0);
		array_copy(_array, 0, keys, 0, array_length(keys) );
		return _array;
	} else {
		return (keys);
	}
}