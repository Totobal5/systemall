/// @param	{String} itemKey
/// @return {Struct.PocketItem}
function PocketItem(_key, _type, _buy=0, _sell=0) : MallMod(_key) constructor 
{
	// script
	
	// Tipo de objeto
	type = _type;
	
	create();
	
	buy  =  _buy;    // Valor al que se compra
	sell = _sell;    // Valor al que se vende
	
	canSell = true; // Si puede vender
	canBuy  = true;	// Si puede compra
	
	/// @ignore Donde se guardan sus estadisticas [value, type]
	stats =     {statKey: [0]};
	statsKeys = [];
	variable_struct_remove(stats, "statKey");
	/// @ignore Modificaciones que utiliza este objeto 
	mods = {};
	
	targets = 1; // A cuantos objetivos afecta
	
	// -- Funciones
	#region METHODS
	
	static canDesequip = function(entity) {return true};
	
	/// @desc Funciones a ejecutar cuando se usa este objeto
	static use =    function() {};
	static CanUse = function() {return true; }
	
	/// @desc Establece un evento a ejecutar cuando se compra
	static buyAction  = function() {};
	/// @desc Establece un evento a ejecutar cuando se vende
	static sellAction = function() {};
	
	/// @desc Establece un evento a ejecutar cuando se encuentra en el mundo
	static worldStep  = function() {};
	/// @desc Establece un evento a ejecutar cuando se entra al mundo
	static worldEnter = function() {};
	/// @desc Establece un evento a ejecutar cuando se sale del mundo
	static worldExit  = function() {};
	
	static send = function(_store="") 
	{
		var this = self;
		return {
			buy : this.buy, 
			sell: this.buy
		}; 
	}
	 
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
			array_push(statsKeys, _key);
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
	
	/// @ignore
	static create = function()
	{
		// Obtener todos los itemtypes
		static types = MallDatabase.pocket.type;
		if (!struct_exists(types, type) ) types[$ type] = {};
		types[$ type][$ key] = is;
	}
	
	#endregion
}