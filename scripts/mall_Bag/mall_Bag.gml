/// @desc Base constructor for all bag types.
/// @param {String} key Unique bag key.
/// @returns {Struct.MallBag}
function MallBag(_key) : MallBehavior(_key) constructor
{
	/// @type {String} Type of bag, used for categorization and UI. Should be overridden by child constructors.
	bag_type = "BASE";

	/// @type {Bool} Whether this bag should be included in save/import flow.
	is_persistent = false;
	
	/// @type {Real} Maximum number of item stacks (not total count) allowed in this bag.
	limit = 99;

	#region EVENTS

	/// @context Struct.MallBag
	/// @desc Fired after one or more items are added successfully.
	/// @param {String} item_key Added item key.
	/// @param {Real} count_added Amount that was actually added.
	/// @param {Struct} args Optional callback context payload.
	/// @returns {undefined}
	event_on_add_item = "";
	
	/// @context Struct.MallBag
	/// @desc Fired after one or more items are removed.
	/// @param {String} item_key Removed item key.
	/// @param {Real} count_removed Amount that was actually removed.
	/// @param {Struct} args Optional callback context payload.
	/// @returns {undefined}
	event_on_remove_item =	"";
	
	#endregion

	#region PRIVATE
	
	/// @ignore
	/// @desc Loads event callbacks from bag data.
	/// @param {Struct} data Bag data struct.
	static __LoadEvents = function(_data)
	{
		method(self, MallBehavior.__LoadEvents) (_data);

		event_on_add_item =		variable_get_hash(_data[$ "event_on_add_item"]	?? "");
		event_on_remove_item =	variable_get_hash(_data[$ "event_on_remove_item"] ?? "");

		return self;
	}
	
	#endregion
	
	#region API
	
	/// @desc Exports bag data to a struct, typically for database storage or saving.
	/// @returns {Struct}
	static Export = function()
	{
		var _this = self;
		with(method(self, MallBehavior.Export)())
		{
			bag_type = _this.bag_type;
			is_persistent = _this.is_persistent;
			limit = _this.limit;
			
			// Events
			event_on_add_item =		_this.event_on_add_item;
			event_on_remove_item =	_this.event_on_remove_item;

			return self;
		}
	}

	/// @desc Imports bag data from a struct, typically from a database payload or a saved game.
	/// @param {Struct} data Bag data struct.
	static Import = function(_data)
	{
		// Parent import.
		method(self, MallBehavior.Import)(_data);
		
		// Type import with validation.
		var _original_bag_type = bag_type;
		bag_type = _data[$ "bag_type"] ?? bag_type;
		if (is_string(bag_type) ) 
		{
			bag_type = string_upper(bag_type); 
		}
		else
		{
			__mall_alert($"Mall bag '{key}' has invalid bag_type '{bag_type}' in import data. Falling back to default.");
			bag_type = _original_bag_type;
		}

		is_persistent =		_data[$ "is_persistent"]	?? is_persistent;
		limit =				_data[$ "limit"]			?? limit;

		return self;
	}

	#endregion
}