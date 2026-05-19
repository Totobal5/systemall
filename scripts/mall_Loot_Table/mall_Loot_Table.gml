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
	/// @desc Loads loot table data from a struct (JSON or GML).
	/// @param {Struct} data Data struct.
	/// @return {Struct.MallLootTable}
	FromData = function(_data)
	{
		if (is_struct(_data) ) 
		{
			items = _data[$ "items"] ??	items;
			gold_drop = _data[$ "gold_drop"] ?? gold_drop;
			exp_drop = _data[$ "exp_drop"] ?? exp_drop;
		}

		return self;
	}

	#endregion
}