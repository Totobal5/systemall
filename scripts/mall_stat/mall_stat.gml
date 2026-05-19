/// @desc Defines the base template for a game stat.
/// @param {String} key
function MallStat(_key) : MallBehavior(_key) constructor 
{
	/// @desc The type of value used by the stat (REAL or PERCENT).
	/// @type {Enum.MALL_NUMTYPE}
	num_type = MALL_NUMTYPE.REAL;
	
	/// @desc Whether the entity can have multiple effects affecting this stat.
	/// @type {Bool}
	allow_multiple_effects = false;
	
	/// @desc How many effects of this stat an entity can have. -1 for infinite.
	/// @type {Real}
	max_effects = -1;
	
	/// @desc Whether the current value is restored to maximum when equipping something that modifies it.
	/// @type {Bool}
	restore_on_equip = false;
	
	/// @desc The minimum limit the stat value can reach.
	/// @type {Real}
	min_value = __MALL_STAT_MIN;
	
	/// @desc The maximum limit the stat value can reach.
	/// @type {Real}
	max_value = __MALL_STAT_MAX;
	
	/// @desc The minimum level of the stat.
	/// @type {Real}
	min_level = __MALL_STAT_LEVEL_MIN;
	
	/// @desc The maximum level of the stat.
	/// @type {Real}
	max_level = __MALL_STAT_LEVEL_MAX;
	
	/// @desc Whether this stat levels up independently of the entity's level.
	/// @type {Bool}
	is_standalone_level = false;
	
	/// @desc An iterator for passive or degenerative effects (e.g., regeneration per turn).
	/// @type {Struct.MallIterator}
	iterator = new MallIterator();
	
	#region EVENTS
	
	/// @desc Runs once when the instance is created for an entity.
	/// @context Struct.MallStatInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @returns {undefined}
	event_on_start = "";
	
	/// @desc (Not currently implemented by the engine.)
	/// @returns {undefined}
	event_on_end = "";
	
	/// @desc Runs on each RecalculateStats call after peak_value is calculated.
	/// @context Struct.MallStatInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @returns {undefined}
	event_on_update = "";
	
	/// @desc Runs to calculate the stat peak_value. Must return the new value.
	/// @context Struct.MallStatInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @returns {Real}
	event_on_level_up = "";
	
	/// @desc (For standalone stats.) Checks whether the stat can level up. Must return a boolean.
	/// @context Struct.MallStatInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @returns {Bool}
	event_on_level_check = "";
	
	/// @desc Runs when an item is equipped in any entity slot.
	/// @context Struct.MallStatInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @param {Struct.MallSlotInstance} slot_instance The slot where the item was equipped.
	/// @returns {undefined}
	event_on_equip = "";
	
	/// @desc Runs when an item is unequipped from any entity slot.
	/// @context Struct.MallStatInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @param {Struct.MallSlotInstance} slot_instance The slot from which the item was unequipped.
	/// @returns {undefined}
	event_on_desequip = "";

	// Turn events.
	
	/// @desc Runs on each turn update of the WateManager.
	/// @context Struct.MallStatInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @returns {undefined}
	event_on_turn_update = "";
	
	/// @desc Runs at the start of the entity turn.
	/// @context Struct.MallStatInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @returns {undefined}
	event_on_turn_start = "";
	
	/// @desc Runs at the end of the entity turn.
	/// @context Struct.MallStatInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @returns {undefined}
	event_on_turn_end = "";

	#endregion

	#region PRIVATE

	/// @ignore
	/// @desc Loads event strings to be used later.
	/// @param {Struct} data The struct containing the stat data.
	/// @returns {undefined}
	static __LoadFunctions = function(_data)
	{
		// Assign event keys.
		event_on_start =		_data[$ "event_on_start"]			?? "";
		event_on_end =			_data[$ "event_on_end"]				?? "";
		event_on_update =		_data[$ "event_on_update"]			?? "";
		event_on_level_up =		_data[$ "event_on_level_up"]		?? "";
		event_on_level_check =	_data[$ "event_on_level_check"]		?? "";
		event_on_equip =		_data[$ "event_on_equip"]			?? "";
		event_on_desequip =		_data[$ "event_on_desequip"]		?? "";
		
		// Turn events.
		event_on_turn_update =	_data[$ "event_on_turn_update"]		?? "";
		event_on_turn_start =	_data[$ "event_on_turn_start"]		?? "";
		event_on_turn_end =		_data[$ "event_on_turn_end"]		?? "";
	}
	
	#endregion
	
	#region API
	
	/// @desc Configures the stat from a data struct (read from JSON).
	/// @param {Struct} data The struct containing the stat data.
	/// @returns {MallStat}
	static FromData = function(_data)
	{
		// Data type.
		num_type = (_data[$ "num_type"] == "percent") ? MALL_NUMTYPE.PERCENT : MALL_NUMTYPE.REAL;
		
		allow_multiple_effects = _data[$ "allow_multiple_effects"] ?? false;
		max_effects = _data[$ "max_effects"] ?? -1;
		
		restore_on_equip = _data[$ "restore_on_equip"] ?? false;
		
		base_value = _data[$ "base_value"] ?? 0;
		min_value = _data[$ "min_value"] ?? __MALL_STAT_MIN;
		max_value = _data[$ "max_value"] ?? __MALL_STAT_MAX;
		
		base_level = _data[$ "base_level"] ?? 1;
		min_level = _data[$ "min_level"] ?? __MALL_STAT_LEVEL_MIN;
		max_level = _data[$ "max_level"] ?? __MALL_STAT_LEVEL_MAX;
		
		is_standalone_level = _data[$ "is_standalone_level"] ?? false;
		
		// Configure iterator if iterator data exists.
		if (struct_exists(_data, "iterator") )
		{
			var _iterator_data = struct_get(_data, "iterator");
			iterator.Configure(
				_iterator_data[$ "duration"] ?? 1,
				_iterator_data[$ "repeats"] ?? 0
			);
		}
		
		// Load event keys.
		__LoadFunctions(_data);

		return self;
	}
	
	#endregion
}