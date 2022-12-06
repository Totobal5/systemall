/// @param	{String}	itemKey
/// @param	{String}	typeKey
/// @param	{Real}		[buy]
/// @param	{Real}		[sell]
/// @return {Struct.PocketItem}
function PocketItem(_itemKey, _typeKey, _buy=0, _sell=0) : MallMod(_itemKey) constructor 
{
	type = _typeKey; // Tipo de objeto
	
	// Añadir type a la database
	var _t = pocket_data_get_types(); // Obtener todos los itemtypes
	if (!variable_struct_exists(_t, type) ) {
		var _str = {};
		_str[$ _itemKey] = type;
		_t[$ type] = _str;
	} 
	else {
		_t[$ type][$ _itemKey] = type;
	}
	
	buy  =  _buy;    // Valor al que se compra
	sell = _sell;    // Valor al que se vende
	
	canSell = true; // Si puede vender
    canBuy  = true;	// Si puede compra
	
    stats = {}; // Donde se guardan sus estadisticas [value, type]
	mods  = {}; // Modificaciones que utiliza este objeto
	
	targets = 1; // A cuantos objetivos afecta
	
	// -- Funciones
	
	/// @desc Funciones a ejecutar cuando se usa este objeto
	funStart = ""; // inicio
	funEnd   = ""; // Final
	
	/// @desc Establece un evento a ejecutar cuando se compra
	funBuy  = "";
	
	/// @desc Establece un evento a ejecutar cuando se vende
	funSell = "";
	
	/// @desc Establece un evento a ejecutar cuando se encuentra en el mundo
	funWorldStep  = "";
	funWorldEnter = "";
	funWorldExit  = "";
	
	/// @desc Establece un evento a ejecutar cuando se equipa
	funEquipStart = "";
	funEquipEnd   = "";
	
	/// @desc Establece un evento a ejecutar cuando se desequipa
	funDesequip = "";

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
				if (MALL_POCKET_TRACE) {
					show_debug_message("MallRPG Pocket (pkItemSetStat): {0} no existe", _key);
				}
			}
			
			i = i + 3;
		}
		
		return self;
    }

	/// @param {String}	statKey
	static getStat  = function(_statKey)
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
	static setTrade    = function(_buy=0, _sell=0, _canBuy=true, _canSell=true) 
	{
		buy  =  _buy;
		sell = _sell;
		
		canBuy  =  _canBuy;
		canSell = _canSell;
		
        return self;
    }

	/// @desc Function Description
	/// @param {string} funEquip funcion a ejecutar cuando se equipa este objeto
	static setFunDesequip = function(_fun)
	{
		funDesequip = _fun;
		return self;
	}

	#region Utils
	
	/// @param {struct.PartyEntity} partyEntity
	exDesequip = function(_entity)
	{
		static fun = dark_get_function(funDesequip);
		return (fun(_entity) );
	}

	
	#endregion

    #endregion
}