/// @desc Defines a shop template.
/// @param {String} key Unique shop key.
function MallShop(_key) : Mall(_key) constructor
{
    /// @desc Multiplier applied to buy prices.
    /// @type {Real}
    buy_multiplier = 1.0;
    
    /// @desc Multiplier applied to sell prices.
    /// @type {Real}
    sell_multiplier = 0.5;
    
    /// @desc Array of item keys sold by this shop.
    /// @type {Array<String>}
    inventory = [];
    
    /// @desc Event string for shop availability condition.
    /// @type {String}
    condition_event = "";
    
    /// @desc Configures the shop from a data struct.
    /// @param {Struct} data The struct containing the shop data.
    /// @returns {Struct.MallShop}
    static FromData = function(_data)
    {
        buy_multiplier =	_data[$ "buy_multiplier"]	?? 1.0;
        sell_multiplier =	_data[$ "sell_multiplier"]	?? 0.5;
        inventory =			_data[$ "inventory"]		?? [];
        condition_event =	_data[$ "condition_event"]	?? "";
        
		return self;
    }
}