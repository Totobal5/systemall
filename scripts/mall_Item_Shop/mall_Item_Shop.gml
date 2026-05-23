/// @desc Defines a shop template.
/// @param {String} key Unique shop key.
function MallShop(_key) : MallBehavior(_key) constructor
{
	/// @type {Real} Multiplier applied to buy prices.
	buy_multiplier = 1.0;
	
	/// @type {Real} Multiplier applied to sell prices.
	sell_multiplier = 0.5;
	
	/// @type {Array<String>} Array of item keys sold by this shop.
	inventory = [];
	
	#region EVENTS
	/// @type {String} Event string for shop availability selling.
	event_can_sell = "";
	
	/// @type {String} Event string for shop availability buying.
	event_can_buy = "";

	#endregion

	#region PRIVATE API

	/// @ignore
	/// @desc Loads event callbacks from the shop data struct.
	/// @param {Struct} data The struct containing the shop data.
	function __LoadEvents(_data)
	{
		method(self, MallBehavior.__LoadEvents) (_data);

		event_can_sell = variable_get_hash(_data[$ "event_can_sell"] ?? event_can_sell);
		event_can_buy =  variable_get_hash(_data[$ "event_can_buy"]  ?? event_can_buy);

		return self;
	}

	#endregion

	#region PUBLIC API

	/// @desc Exports the shop data to a struct, typically for saving or database storage.
	/// @returns {Struct} Struct with the shop data.
	static Export = function()
	{
		var _this = self;
		with(method(self, MallBehavior.Export)())
		{
			buy_multiplier =  _this.buy_multiplier;
			sell_multiplier = _this.sell_multiplier;
			inventory =		  _this.inventory;
			
			// Events
			event_can_sell = _this.event_can_sell;
			event_can_buy =  _this.event_can_buy;

			return self;
		}
	}

	/// @desc Configures the shop from a data struct.
	/// @param {Struct} data The struct containing the shop data.
	/// @returns {Struct.MallShop}
	static Import = function(_data)
	{
		// Parent configuration.
		method(self, MallBehavior.Import) (_data);

		buy_multiplier =	_data[$ "buy_multiplier"]	?? buy_multiplier;
		sell_multiplier =	_data[$ "sell_multiplier"]	?? sell_multiplier;
		inventory =			_data[$ "inventory"]		?? inventory;
		
		return self;
	}

	#endregion
}