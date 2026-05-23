/// @desc Defines the base template for an altered state (for example: poison, blessed).
/// @param {String} key Unique state template key.
/// @return {Struct.MallState}
function MallState(_key) : MallBehavior(_key) constructor
{
	// Replace default type with default state type for states.
	array_set(type, 0, __MALL_STATE_DEFAULT_TYPE);

	/// @type {Real} Priority used to resolve conflicts with other states.
	priority = 0;
	
	/// @type {Array<String>} List of state keys this state clears when applied.
	clears_states = [];
	
	/// @type {Array<String>} List of state keys that cannot be applied while this one is active.
	prevents_states = [];
	
	/// @type {Bool} If true, the entity cannot execute commands while this state is active.
	restricts_action = false;
	
	/// @type {Bool} Initial boolean value for this state.
	boolean_value = false;
	
	/// @type {Bool} Value the boolean state resets to.
	reset_value = false;
	
	/// @type {Bool} Whether the entity can hold multiple effects of this state at once.
	allow_multiple = false;
	
	/// @type {Real} Maximum number of effects that can stack when allow_multiple is true.
	max_effects = 1;
	
	/// @type {Struct} Struct with passive stat modifiers applied by this state.
	stats = {};
	
	/// @type {Struct.MallIterator} Iterator that controls this state's duration.
	iterator = new MallIterator();

	#region EVENTS
	
	/// @desc Runs once when a state instance is created for an entity.
	/// @context Struct.MallEntity
	/// @param {Struct.MallState} state_template The state template.
	// event_on_start = "";
	
	/// @desc Runs when the state returns to its reset value after all effects are removed.
	/// @context Struct.MallEntity
	/// @param {Struct.MallState} state_template The state template.
	// event_on_end = "";
	
	/// @desc Runs on each RecalculateStats call.
	/// @context Struct.MallEntity
	/// @param {Struct.MallState} state_template The state template.
	// event_on_update = "";
	
	/// @desc Runs on each 'MallBattleManager' turn update.
	/// @context Struct.MallEntity
	/// @param {Struct.MallState} state_template The state template.
	// event_on_turn_update = "";
	
	/// @desc Runs at the start of the entity turn.
	/// @context Struct.MallEntity
	/// @param {Struct.MallState} state_template The state template.
	// event_on_turn_start = "";
	
	/// @desc Runs at the end of the entity turn.
	/// @context Struct.MallEntity
	/// @param {Struct.MallState} state_template The state template.
	// event_on_turn_end = "";
	
	/// @desc Runs after an effect is added to this state.
	/// @context Struct.MallEntity
	/// @param {Struct.MallState} state_template The state template.
	/// @param {Struct.MallEffectInstance} effect_instance Effect that was added.
	event_on_add_effect = "";
	
	/// @desc Runs after an effect is removed from this state.
	/// @context Struct.MallEntity
	/// @param {Struct.MallState} state_template The state template.
	/// @param {Struct.MallEffectInstance} effect_instance Effect that was removed.
	event_on_remove_effect = "";

	/// @desc Validates whether an effect can be added to this state. Must return bool.
	/// @context Struct.MallEntity
	/// @param {Struct.MallState} state_template The state template.
	/// @param {Struct.MallEffectInstance} effect_instance Effect being added.
	/// @return {Bool}
	event_can_add_effect = "";
	
	/// @desc Validates whether an effect can be removed from this state. Must return bool.
	/// @context Struct.MallEntity
	/// @param {Struct.MallState} state_template The state template.
	/// @param {Struct.MallEffectInstance} effect_instance Effect being removed.
	/// @return {Bool}
	event_can_remove_effect = "";
	
	#endregion

	#region PRIVATE

	/// @ignore
	/// @desc Parses a stat entry from the data struct and stores it in the stats struct.
	/// @param {String} key The stat key, potentially with suffixes.
	/// @param {Real} value The stat value.
	static __Parse = function(_key, _value)
	{
		var _type = MALL_NUMTYPE.REAL;
		var _stat_key = _key;

		// Check for suffixes in the stat key.
		var _len = string_length(_key);
		var _suffix = string_char_at(_key, _len);
		if (_suffix == "%" || _suffix == "+") 
		{
			_stat_key = string_delete(_key, _len, 1);
			if (_suffix == "%") { _type = MALL_NUMTYPE.PERCENT; }
		}
		
		// Store as [value, type].
		stats[$ _stat_key] = [_value, _type];
	}

	/// @ignore
	/// @desc Loads stats from the data struct.
	/// @param {Struct} data Struct containing the item data.
	/// @returns {undefined}
	static __LoadStats = function(_data)
	{
		if (struct_exists(_data, "stats") ) 
		{ 
			struct_foreach(_data[$ "stats"], __Parse); 
		}
		else
		{
			__mall_alert($"Mall item '{key}' has no stats defined.");
		}
	}

	/// @ignore
	/// @desc Loads event keys from the data struct.
	/// @param {Struct} data Struct containing event keys.
	static __LoadEvents = function(_data)
	{
		// Parent load._data
		method(self, MallBehavior.__LoadEvents) (_data);

		event_on_add_effect =		variable_get_hash(_data[$ "event_on_add_effect"]		?? "");
		event_on_remove_effect =	variable_get_hash(_data[$ "event_on_remove_effect"]		?? "");
		event_can_add_effect =		variable_get_hash(_data[$ "event_can_add_effect"]		?? "");
		event_can_remove_effect =	variable_get_hash(_data[$ "event_can_remove_effect"]	?? "");

		return self;
	}
	
	#endregion
	
	#region API

	/// @desc Exports the state data to a struct, typically for saving or database storage.
	/// @return {Struct} Struct with the state data.
	static Export = function()
	{
		var _this = self;
		with (method(self, MallBehavior.Export)() )
		{
			// Core state properties.
			priority =			_this.priority;
			clears_states =		variable_clone(_this.clears_states);
			prevents_states =	variable_clone(_this.prevents_states);
			restricts_action =	_this.restricts_action;
			boolean_value =		_this.boolean_value;
			reset_value =		_this.reset_value;
			allow_multiple =	_this.allow_multiple;
			max_effects =		_this.max_effects;
			stats =				variable_clone(_this.stats);

			// Iterator runtime data.
			iterator = _this.iterator.Export();

			return self;
		}
	}
	
	/// @desc Configures the state from a data struct.
	/// @param {Struct} data Struct containing state data.
	/// @return {Struct.MallState} Configured state instance.
	static Import = function(_data)
	{
		// Parent import.
		method(self, MallBehavior.Import) (_data);
		
		// Load current state properties.
		priority =			_data[$ "priority"] 		?? priority;
		clears_states =		_data[$ "clears_states"] 	?? clears_states;
		prevents_states =	_data[$ "prevents_states"]	?? prevents_states;
		restricts_action =	_data[$ "restricts_action"] ?? restricts_action;
		
		// Load legacy/current boolean-stack fields.
		boolean_value =		_data[$ "boolean_value"]	?? boolean_value;
		reset_value =		_data[$ "reset_value"]		?? reset_value;
		allow_multiple =	_data[$ "allow_multiple"]	?? allow_multiple;
		max_effects =		_data[$ "max_effects"]		?? max_effects;
		
		if (struct_exists(_data, "iterator") )
		{
			var _iterator_data = _data[$ "iterator"];
			iterator.Import(_iterator_data);
		}
		
		// Load event keys.
		__LoadStats(_data);
		
		return self;
	}

	#endregion
}