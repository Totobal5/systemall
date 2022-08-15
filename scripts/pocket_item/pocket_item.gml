/// @param	{String}	type_key
/// @param	{Real}		[buy]
/// @param	{Real}		[sell]
/// @return {Struct.PocketItem}
function PocketItem(_KEY, _BUY=0, _SELL=0) : MallModify("") constructor 
{
    #region PRIVATE
	
	type = _KEY;
	buy  = _BUY;	// Valor al que se compra
    canBuy  = true;	// Si puede compra
	
	sell = _SELL;		// Valor al que se vende
	canSell = true;	// Si puede vender
    
    stats = {};	// Donde se guardan sus estadisticas [value, type]
	modifyers = {};	// Modificaciones que utiliza este objeto

	eventBuy  = function() {}
	eventSell = function() {}
	
	eventEquip	  = function() {};
	eventDesequip = function() {}
	
	eventWorld = function() {}

	#endregion

    #region METHODS
    
	/// @desc Pone valores a las estadisticas
	/// @param	{String}	stat_key
	/// @param	{Real}		value
	/// @param	{Enum.MALL_NUMTYPE}	type
	/// @return {Struct.PocketItem}
	static setStat = function(_STAT_KEY, _VALUE, _TYPE=MALL_NUMTYPE.REAL) 
	{
		var i=0; repeat(argument_count div 3)
		{
			var _key = argument[i];
			var _val = argument[i + 1];
			var _type = argument[i + 2];
			if (variable_struct_exists(global.__mallStatsMaster, _key) ) 
			{
				stats[$ _key] = [ _val, _type];
			}
			else
			{
				__mall_trace("Pocket Item " + string(_key) + " no existe!" );
			}
			
			
			i = i+3;
		}
		
		return self;
    }
    
	/// @desc Permite devolver las estadisticas de este objeto normal o invertidas
	/// @param {Bool}	[invert_stats]
    static getStats = function(_INVERT=false) 
	{
        return (!_INVERT) ? statsNormal : statsInvert;
    }

    /// @param	{Real}	buy_value
    /// @param	{Real}	buy_sell
    /// @param	{Bool}	[can_buy]
    /// @param	{Bool}	[can_sell]
	/// @return {Struct.PocketItem}
    static setTrade  = function(_BUY=0, _SELL=0, _CAN_BUY=true, _CAN_SELL=true) 
	{
		buy  = _BUY;
		sell = _SELL;
		
		canBuy  =  _CAN_BUY;
		canSell = _CAN_SELL;
		
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
	
    #endregion
}