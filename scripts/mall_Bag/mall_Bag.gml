/// @desc Base constructor for all bag types.
/// @param {String} key Unique bag key.
/// @returns {Struct.MallBag}
function MallBag(_key) : Mall(_key) constructor
{
	/// @desc Whether this bag should be included in save/import flow.
	/// @type {Bool}
	is_persistent = false;
	
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
	/// @returns {undefined}
	static __LoadFunction = function(_data)
	{
		event_on_add_item = method(self, mall_get_event(_data[$ "event_on_add_item"] ) );
		event_on_remove_item = method(self, mall_get_event(_data[$ "event_on_remove_item"] ) );			
	}
	
	#endregion
	
	#region API
	
	/// @desc Virtual. Configures the bag from data. Must be overridden.
	/// @param {Struct} data Bag data struct.
	/// @returns {Struct.MallBag} Configured bag instance.
	static FromData = function(_data)
	{
		// Super call to load base data. 
		method(self, Mall.FromData)(_data);

		is_persistent = _data[$ "is_persistent"] ?? false;
		
		// Load functions.
		__LoadFunction(_data);
		
		return self;
	}

	/// @desc Virtual. Creates a new instance from this bag template. Must be overridden.
	/// @param {String} instance_key Key for the new bag instance.
	/// @returns {undefined}
	static CreateInstance = function(_instance_key)
	{
		__mall_error("Method CreateInstance must be implemented by a child constructor.");
		return;
	}
	
	#endregion
}