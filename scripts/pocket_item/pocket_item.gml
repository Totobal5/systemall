/// @param	{String}	equipment_key
/// @param	{Real}		[buy]
/// @param	{Real}		[sell]
/// @return {Struct.PocketItem}
function PocketItem(_KEY, _TYPE, _BUY=0, _SELL=0) : MallModify(_KEY) constructor 
{
    #region PRIVATE
	
	type = _TYPE;
	buy  = _BUY;	// Valor al que se compra
    canBuy  = true;	// Si puede compra
	
	sell = _SELL;		// Valor al que se vende
	canSell = true;	// Si puede vender
    
    statsNormal = {};	// Donde se guardan sus estadisticas [value, type]
    statsInvert = {};	// Las estadisticas de arriba invertidas
	
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
			
			__statsNormal[$ _key] = [ _val, _type];
			__statsInvert[$ _key] = [-_val, _type];
		}
		
		return self;
    }
    
	/// @desc Permite devolver las estadisticas de este objeto normal o invertidas
	/// @param {Bool}	[invert_stats]
    static getStats = function(_INVERT=false) 
	{
        return (!_INVERT) ? __statsNormal : __statsInvert;
    }

    /// @param	{Real}	buy_value
    /// @param	{Real}	buy_sell
    /// @param	{Bool}	[can_buy]
    /// @param	{Bool}	[can_sell]
	/// @return {Struct.PocketItem}
    static setTrade  = function(_BUY=0, _SELL=0, _CAN_BUY=true, _CAN_SELL=true) 
	{
		__buy  = _BUY;
		__sell = _SELL;
		__canBuy  =  _CAN_BUY;
		__canSell = _CAN_SELL;
		
        return self;
    }
	
	static setEventEquip = function(_EVENT)
	{
		__eventEquip = _EVENT;
		return self;
	}
	
	static setEventDesequip = function(_EVENT)
	{
		__eventDesequip = _EVENT;
	}
	
    #endregion
}