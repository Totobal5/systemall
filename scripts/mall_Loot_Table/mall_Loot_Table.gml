/// @desc Defines the base template for a loot table.
/// @param {String} key Unique loot table template key.
/// @return {Struct.MallLootTable}
function MallLootTable(_key) : Mall(_key) constructor 
{
	/// @desc List of item drop entries. Each entry is a struct: { key, quantity, chance }
	/// @type {Array<Struct>}
	items = [];

	/// @desc Gold drop definition. [min, max] or fixed value.
	/// @type {Array<Real>|Real}
	gold_drop = [0, 0];

	/// @desc Optional: EXP drop definition. [min, max] or fixed value.
	/// @type {Array<Real>|Real}
	exp_drop = [0, 0];

	#region API

	/// @desc Exports the loot table data to a struct, typically for saving or database storage.
	/// @returns {Struct} Struct with the loot table data.
	static Export = function()
	{
		var _this = self;
		with(method(self, Mall.Export)() )
		{
			items =		_this.items;
			gold_drop = _this.gold_drop;
			exp_drop =	_this.exp_drop;

			return self;
		}
	}
	
	/// @desc Loads loot table data from a struct (JSON or GML).
	/// @param {Struct} data Data struct.
	/// @returns {Struct.MallLootTable}
	static Import = function(_data)
	{
		// Parent import.
		method(self, Mall.Import) (_data);

		items =		_data[$ "items"]		?? items;
		gold_drop =	_data[$ "gold_drop"]	?? gold_drop;
		exp_drop =	_data[$ "exp_drop"]		?? exp_drop;
		
		return self;
	}

	#endregion
}