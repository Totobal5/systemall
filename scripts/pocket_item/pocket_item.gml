/// @param	{String}	itemKey
/// @param	{String}	typeKey
/// @param	{Real}		[buy]
/// @param	{Real}		[sell]
/// @return {Struct.PocketItem}
function PocketItem(_itemKey, _typeKey, _buy=0, _sell=0) : MallMod(_itemKey) constructor 
{
	type = _typeKey; // Tipo de objeto
	
	// Añadir type a la database
	var _t=MallDatabase().pocket.type;
	if (!variable_struct_exists(_t, type) ) {
		var _str = {};
		_str[$ _itemKey] = type;
		_t[$ type] = _str;
	} else {
		_t[$ type][$ _itemKey] = type;
	}
	
	buy  =  _buy;    // Valor al que se compra
	sell = _sell;    // Valor al que se vende
	
	canSell = true; // Si puede vender
    canBuy  = true;	// Si puede compra
	
    stats = {}; // Donde se guardan sus estadisticas [value, type]
	mods  = {}; // Modificaciones que utiliza este objeto
	
	targets = 1; // A cuantos objetivos afecta
	
	// -- Eventos
	/// @desc Establece un evento a ejecutar cuando se compra
	eventBuy  = __dummy;
	
	/// @desc Establece un evento a ejecutar cuando se vende
	eventSell = __dummy;
	
	/// @desc Establece un evento a ejecutar cuando se encuentra en el mundo
	eventWorld = __dummy

	/// @desc Establece un evento a ejecutar cuando se equipa
	eventEquip    = __dummy;
	
	/// @desc Establece un evento a ejecutar cuando se desequipa
	eventDesequip = __dummy;

    #region METHODS
    
	/// @desc Pone valores a las estadisticas
	/// @param	{String}            statKey
	/// @param	{Real}              value
	/// @param	{Enum.MALL_NUMTYPE} type
	/// @return {Struct.PocketItem}
	static setStat = function(_statKey, _value, _numType=MALL_NUMTYPE.REAL) 
	{
		static s = MallDatabase().stats;
		var i=0; repeat(argument_count div 3) {
			var _key = argument[i];
			if (variable_struct_exists(s, _key) ) {
				var _v = argument[i + 1]; // Valor
				var _t = argument[i + 2]; // Tipo
				stats[$ _key] = [_v, _t];
			} else {
				if (MALL_ERROR) {
					show_debug_message("MallRPG Pocket (pkItemSetStat): {0} no existe", _key);
				}
			}
			
			i = i + 3;
		}
		
		return self;
    }

	/// @param {String}	statKey
	static getStat = function(_statKey)
	{
		return (stats[$ _statKey] );
	}

	/// @desc Permite devolver las estadisticas de este objeto normal
	static getStats = function() 
	{
        return stats;
    }

	/// @param	{Real}	buyValue
	/// @param	{Real}	sellValue
	/// @param	{Bool}	[canBuy]=true
	/// @param	{Bool}	[canSell]=true
	/// @return {Struct.PocketItem}
	static setTrade  = function(_buy=0, _sell=0, _canBuy=true, _canSell=true) 
	{
		buy  =  _buy;
		sell = _sell;
		
		canBuy  =  _canBuy;
		canSell = _canSell;
		
        return self;
    }


	static setEventEquip = function(_EVENT)
	{
		eventEquip = _EVENT;
		return self;
	}


	static setEventDesequip = function(_EVENT)
	{
		eventDesequip = _EVENT;
	}

	/// @desc Establece un evento a ejecutar cuando se usa
	/// @param {Function}	use_event function(caster, target, flags) {}
	static setEventUse = function(_EVENT)
	{
		eventObjectStart = _EVENT;
		return self;
	}
	
	/// @desc function(caster, target, flags) {}
	/// @return {Function}
	static getEventUse = function() 
	{
		return (eventObjectStart);
	}

    #endregion
}