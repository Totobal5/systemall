/// @desc Defines the base template for a game stat.
/// @param {String} key
function MallStat(_key) : MallBehavior(_key) constructor 
{
	/// @type {Real} The default base value of the stat.
	base_value = 1;

	/// @type {Real} The default base level of the stat (for growth calculations).
	base_level = 1;

	/// @type {Real} Growth amount applied per level when using a curve.
	growth = 0;

	/// @type {String} Curve name used for level progression.
	curve_name = "linear";

	/// @type {Any|undefined} Reference to an AnimationCurveChannel used for growth.
	growth_curve = undefined;
	
	/// @type {Enum.MALL_NUMTYPE} The type of value used by the stat (REAL or PERCENT).
	num_type = MALL_NUMTYPE.REAL;
	
	/// @type {Bool} Whether the entity can have multiple effects affecting this stat.
	allow_multiple_effects = false;
	
	/// @type {Real} How many effects of this stat an entity can have. -1 for infinite.
	max_effects = -1;
	
	/// @type {Bool} Whether the current value is restored to maximum when equipping something that modifies it.
	restore_on_equip = false;
	
	/// @type {Real} The minimum limit the stat value can reach.
	min_value = __MALL_STAT_MIN;
	
	/// @type {Real} The maximum limit the stat value can reach.
	max_value = __MALL_STAT_MAX;
	
	/// @type {Bool} Whether this stat levels up independently of the entity's level.
	is_standalone_level = false;

	/// @type {Real} The minimum level of the stat.
	min_level = __MALL_STAT_LEVEL_MIN;
	
	/// @type {Real} The maximum level of the stat.
	max_level = __MALL_STAT_LEVEL_MAX;
	
	/// @type {Struct.MallIterator} An iterator for passive or degenerative effects (e.g., regeneration per turn).
	iterator = new MallIterator();

	#region EVENTS
	
	/// @desc Runs once when the instance is created for an entity.
	/// @context Struct.MallStatInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @returns {undefined}
	// event_on_start = "";
	
	/// @desc (Not currently implemented by the engine.)
	/// @returns {undefined}
	// event_on_end = "";
	
	/// @desc Runs on each RecalculateStats call after peak_value is calculated.
	/// @context Struct.MallStatInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @returns {undefined}
	// event_on_update = "";
	
	/// @desc Runs to calculate the stat peak_value. Must return the new value.
	/// @context Struct.MallStatInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @returns {Real}
	event_on_level_up = "";
	
	/// @desc (For standalone stats.) Checks whether the stat can level up. Must return a boolean.
	/// @context Struct.MallStatInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @returns {Bool}
	event_can_level_up = "";
	
	/// @desc Runs when an item is equipped in any entity slot.
	/// @context Struct.MallStatInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @param {Struct.MallSlotInstance} slot_instance The slot where the item was equipped.
	/// @returns {undefined}
	// event_on_equip = "";
	
	/// @desc Runs when an item is unequipped from any entity slot.
	/// @context Struct.MallStatInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @param {Struct.MallSlotInstance} slot_instance The slot from which the item was unequipped.
	/// @returns {undefined}
	// event_on_desequip = "";

	// Turn events.
	
	/// @desc Runs on each turn update of the 'MallBattleManager'.
	/// @context Struct.MallStatInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @returns {undefined}
	// event_on_turn_update = "";
	
	/// @desc Runs at the start of the entity turn.
	/// @context Struct.MallStatInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @returns {undefined}
	// event_on_turn_start = "";
	
	/// @desc Runs at the end of the entity turn.
	/// @context Struct.MallStatInstance
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @returns {undefined}
	// event_on_turn_end = "";

	#endregion

	#region PRIVATE

	/// @ignore
	/// @desc Loads event strings to be used later.
	/// @param {Struct} data The struct containing the stat data.
	/// @returns {undefined}
	static __LoadEvents = function(_data)
	{
		// Parent functions.
		method(self, MallBehavior.__LoadEvents) (_data);
		
		// Level-up events
		event_on_level_up =		_data[$ "event_on_level_up"]		?? "";
		event_can_level_up =	_data[$ "event_can_level_up"]		?? "";
	}
	
	#endregion
	
	#region API
	
	/// @desc Exports the stat data to a struct, typically for database storage or saving.
	/// @returns {Struct}
	static Export = function()
	{
		var _this = self;
		with(method(self, MallBehavior.Export)())
		{
			num_type = (_this.num_type == MALL_NUMTYPE.PERCENT) ? "percent" : "real";
			allow_multiple_effects =	_this.allow_multiple_effects;
			max_effects =				_this.max_effects;
			restore_on_equip =			_this.restore_on_equip;

			// Values.
			base_value = _this.base_value;
			growth = _this.growth;
			curve_name = _this.curve_name;
			min_value = _this.min_value;
			max_value = _this.max_value;

			// Levels.
			min_level = _this.min_level;
			max_level = _this.max_level;
			is_standalone_level = _this.is_standalone_level;

			// Iterator
			iterator = _this.iterator.Export();

			return self;
		}
	}

	/// @desc Configures the stat from a data struct (read from JSON).
	/// @param {Struct} data The struct containing the stat data.
	static Import = function(_data)
	{
		// Parent configuration.
		method(self, MallBehavior.Import) (_data);

		// Data type.
		num_type = (_data[$ "num_type"] == "percent") ? MALL_NUMTYPE.PERCENT : MALL_NUMTYPE.REAL;
		// Configure stat properties.
		allow_multiple_effects =	_data[$ "allow_multiple_effects"]	?? allow_multiple_effects;
		max_effects =				_data[$ "max_effects"]				?? max_effects;
		restore_on_equip =			_data[$ "restore_on_equip"]			?? restore_on_equip;

		// Values and growth.
		base_value =	_data[$ "base_value"]	?? base_value;
		growth =		_data[$ "growth"]		?? growth;
		curve_name =	_data[$ "curve_name"]	?? curve_name;
		min_value =		_data[$ "min_value"]	?? __MALL_STAT_MIN;
		max_value =		_data[$ "max_value"]	?? __MALL_STAT_MAX;
		
		// Assign growth curve if it exists.
		if (mall_asset_exists(curve_name) ) { growth_curve = mall_asset_get(curve_name); }

		// Levels.
		is_standalone_level = _data[$ "is_standalone_level"] ?? is_standalone_level;

		base_level = _data[$ "base_level"] ?? 1;
		min_level =  _data[$ "min_level"] ?? __MALL_STAT_LEVEL_MIN;
		max_level =  _data[$ "max_level"] ?? __MALL_STAT_LEVEL_MAX;

		// Configure iterator if iterator data exists.
		if (struct_exists(_data, "iterator") )
		{
			var _iterator_data = struct_get(_data, "iterator");
			iterator.Import(_iterator_data);
		}

		return self;
	}
	
	#endregion
}