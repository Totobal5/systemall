/// @desc Represents an item entry inside a bag with quantity and unique variables.
/// @param {String} item_key Item template key.
/// @param {Real} count Quantity for this item entry.
/// @param {Struct} [vars] Optional unique data struct (for example { enchantment: "fire" }).
function MallItemInstance(_item_key, _count, _vars = {}) : Mall(_item_key) constructor
{
	// Set item vars to the argument struct or an empty struct if not provided.
	vars = _vars;
	
	/// @type {Real} Amount in this entry.
	count = _count;
	
	#region PUBLIC API
	
	/// @desc Exports this instance to a plain struct for saving.
	/// @returns {Struct}
	static Export = function()
	{
		var _this = self;
		with (method(self, Mall.Export)() )
		{
			count = _this.count;
			return self;
		}
	}
	
	/// @desc Imports data from a saved struct.
	/// @param {Struct} data The data struct to import.
	static Import = function(_data)
	{
		method(self, Mall.Import) (_data);
		count = _data[$ "count"] ?? count;

		return self;
	}
	
	#endregion
}