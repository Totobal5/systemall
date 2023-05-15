/// @param	{String}	itemKey
/// @param	{String}	typeKey
/// @param	{Real}		[buy]
/// @param	{Real}		[sell]
/// @return {Struct.PocketItem}
function PocketItem(_itemKey, _typeKey, _buy=0, _sell=0) : MallMod(_itemKey) constructor 
{
	type = _typeKey; // Tipo de objeto
	
	#region Añadir type a la database
	var _t = pocket_data_get_types(); // Obtener todos los itemtypes
	if (!variable_struct_exists(_t, type) ) {
		var _str = {};
		_str[$ _itemKey] = type;
		_t[$ type] = _str;
	} 
	else {
		_t[$ type][$ _itemKey] = type;
	}
	#endregion
	
	buy  =  _buy;    // Valor al que se compra
	sell = _sell;    // Valor al que se vende
	
	canSell = true; // Si puede vender
    canBuy  = true;	// Si puede compra
	
	/// @ignore Donde se guardan sus estadisticas [value, type]
    stats = {statKey: [0]};
	variable_struct_remove(stats, "statKey");
	/// @ignore Modificaciones que utiliza este objeto 
	mods = {};
	
	targets = 1; // A cuantos objetivos afecta
	
	// -- Funciones
	
	/// @ignore Funciones a ejecutar cuando se usa este objeto
	funUse = "";
	/// @ignore Establece un evento a ejecutar cuando se compra
	funBuy  = "";
	/// @ignore Establece un evento a ejecutar cuando se vende
	funSell = "";
	
	/// @ignore Establece un evento a ejecutar cuando se encuentra en el mundo
	funWorldStep  = "";
	/// @ignore Establece un evento a ejecutar cuando se entra al mundo
	funWorldEnter = "";
	/// @ignore Establece un evento a ejecutar cuando se sale del mundo
	funWorldExit  = "";

    #region METHODS
    
	/// @desc Pone valores a las estadisticas
	/// @param	{String}            statKey
	/// @param	{Real}              value
	/// @param	{Enum.MALL_NUMTYPE} [type]
	/// @return {Struct.PocketItem}
	static setStat = function(_statKey, _value, _numType=MALL_NUMTYPE.REAL) 
	{
		static dataStat = MallDatabase.stats;
		var i=0; repeat(argument_count div 3) {
			var _key = argument[i];
			if (MALL_ERROR) {
				if (MALL_POCKET_TRACE && !variable_struct_exists(dataStat, _key) ) {
					show_debug_message("MallRPG Pocket (pkItemSetStat): {0} no existe", _key);
				}
			}
			
			// Establecer valor en las estadisticas
			var _v = argument[i + 1];                      // Valor
			var _t = argument[i + 2] ?? MALL_NUMTYPE.REAL; // Tipo
			stats[$ _key] = [_v, _t];

			i = i + 3;
		}
		
		return self;
    }

	/// @param  {String} statKey
	/// @return {Array<real>}
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
	static setTrade = function(_buy, _sell, _canBuy=true, _canSell=true) 
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
	
	/// @param {string} funEquip funcion a ejecutar cuando se usa este objeto
	static setFunUse      = function(_fun) 
	{
		funUse = _fun;
		return self;
	}
	
	/// @param {string} funBuy
	/// @param {string} funSell
	static setFunBuySell  = function(_funB="", _funS="")
	{
		funBuy  = _funB;
		funSell = _funS;
		return self;
	}
	
	#region Utils
	// exDesequip   Establece un evento a ejecutar cuando se desequipa (Definido en MallMod)
	// exEquip      Establece un evento a ejecutar cuando se equipa    (Definido en MallMod)
	
	/// @desc Funcion que ejecutar cuando se consume o usa este objeto
	exUse  = function(_caster, _target) 
	{
		static fun = method(self, dark_get_function(funUse) ?? function() {return false;} );
		return (fun(_caster, _target) );
	}
	
	exBuy  = function(_caster, _target)
	{
		static fun = dark_get_function(funBuy)  ?? function() {return true;};
		return (fun(_caster, _target) );
	}
	
	exSell = function(_caster, _target)
	{
		static fun = dark_get_function(funSell) ?? function() {return true;};
		return (fun(_caster, _target) );
	}
	

	#endregion

    #endregion
}