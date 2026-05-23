/// @desc Base container for components that expose event hooks.
/// @param {String} key Component template key.
function MallBehavior(_key) : Mall(_key) constructor
{
	/// @ignore
	/// @type {Struct<Function>} Cache for events to avoid redundant lookups. Maps event keys to resolved function references.
	__cache = {};

	// --- Event keys ---
	// These fields store FUNCTION KEY STRINGS, not callables.
	// The callable is resolved from __Systemall.__events when needed.
	
	// -- Component lifecycle hooks. --

	/// @desc Runs at the start of the component lifecycle (for example, when a battle starts for battle behaviors).
	/// @context Struct.MallBehavior
	event_on_start = "";

	/// @desc Runs at the end of the component lifecycle (for example, when a battle ends for battle behaviors).
	/// @context Struct.MallBehavior
	event_on_end = "";

	/// @desc Runs on each update of the component lifecycle (for example, each turn for battle behaviors).
	/// @context Struct.MallBehavior
	event_on_update = "";
	
	/// @desc Runs on each turn update of the battle manager.
	/// @context Struct.MallBehavior
	event_on_turn_update = "";

	/// @desc Runs at the start of the entity turn.
	/// @context Struct.MallBehavior
	event_on_turn_start = "";

	/// @desc Runs at the end of the entity turn.
	/// @context Struct.MallBehavior
	event_on_turn_end = "";
	
	/// @desc Runs when an item is equipped in any entity slot.
	/// @context Struct.MallBehavior
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @param {Struct.MallSlotInstance} slot_instance The slot where the item was equipped.
	event_on_equip = "";

	/// @desc Runs when an item is unequipped from any entity slot.
	/// @context Struct.MallBehavior
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @param {Struct.MallSlotInstance} slot_instance The slot from which the item was unequipped.
	event_on_desequip = "";

	#region PRIVATE API

	/// @ignore
	/// @desc Loads event strings to be used later.
	/// @param {Struct} data The struct containing the behavior data.
	static __LoadEvents = function(_data)
	{
		// Assign event keys.
		event_on_start =		variable_get_hash(_data[$ "event_on_start"]  ?? "");
		event_on_end =			variable_get_hash(_data[$ "event_on_end"]    ?? "");
		event_on_update =		variable_get_hash(_data[$ "event_on_update"] ?? "");
		
		// Turn events.
		event_on_turn_update =	variable_get_hash(_data[$ "event_on_turn_update"] ?? "");
		event_on_turn_start =	variable_get_hash(_data[$ "event_on_turn_start"]  ?? "");
		event_on_turn_end =		variable_get_hash(_data[$ "event_on_turn_end"]    ?? "");

		// Equipment events.
		event_on_equip =		variable_get_hash(_data[$ "event_on_equip"]     ?? "");
		event_on_desequip =		variable_get_hash(_data[$ "event_on_desequip"]  ?? "");

		return self;
	}

	#endregion

	#region PUBLIC API

	/// @desc Make a Struct containing this behavior's event keys for external use (for example, by items or states that want to call these events).
	/// @returns {Struct}
	static GetEventKeys = function()
	{
		with ({})
		{
			event_on_start =		event_on_start;
			event_on_end =			event_on_end;
			event_on_update =		event_on_update;
			event_on_turn_update =	event_on_turn_update;
			event_on_turn_start =	event_on_turn_start;
			event_on_turn_end =		event_on_turn_end;
			event_on_equip =		event_on_equip;
			event_on_desequip =		event_on_desequip;
			
			return self;
		}
	}

	/// @desc Exports the base instance state to a save struct.
	/// @return {Struct} Struct with essential instance data.
	static Export = function()
	{
		var _this = self;
		with (method(self, Mall.Export) () )
		{
			event_on_start =		_this.event_on_start;
			event_on_end =			_this.event_on_end;
			event_on_update =		_this.event_on_update;
			event_on_turn_update =	_this.event_on_turn_update;
			event_on_turn_start =	_this.event_on_turn_start;
			event_on_turn_end =		_this.event_on_turn_end;
			event_on_equip =		_this.event_on_equip;
			event_on_desequip =		_this.event_on_desequip;
		}
	}

	/// @desc Imports and restores the base instance state from a struct.
	/// @param {Struct} data Struct containing component data.
	static Import = function(_data)
	{
		if (!is_struct(_data) )
		{
			__mall_error("MallBehavior.Import expected a struct payload.");
			exit;
		}

		// Call parent import.
		method(self, Mall.Import) (_data);
		// Always use the correct context to load events, as they are stored as strings and need to be resolved.
		method(self, __LoadEvents) (_data);
	}
	
	/// @desc Returns a string representation of this instance for debugging purposes.
	/// @return {String}
	static toString = function()
	{
		var _parent_str = method(self, Mall.toString) ();
		return $"{_parent_str}\nMallBehavior::\nStart Event: {event_on_start}\nEnd Event: {event_on_end}\nUpdate Event: {event_on_update}\nTurn Update Event: {event_on_turn_update}\nTurn Start Event: {event_on_turn_start}\nTurn End Event: {event_on_turn_end}\nEquip Event: {event_on_equip}\nDesequip Event: {event_on_desequip}";
	}

	#endregion
}