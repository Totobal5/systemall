/// @desc Defines the base template for an altered state (for example: poison, blessed).
/// @param {String} key Unique state template key.
/// @return {Struct.MallState}
function MallState(_key) : MallBehavior(_key) constructor
{
	/// @desc State category (for example: "BUFF", "AILMENT").
	/// @type {String}
	state_type = "AILMENT";
	
	/// @desc Priority used to resolve conflicts with other states.
	/// @type {Real}
	priority = 0;
	
	/// @desc List of state keys this state clears when applied.
	/// @type {Array<String>}
	clears_states = [];
	
	/// @desc List of state keys that cannot be applied while this one is active.
	/// @type {Array<String>}
	prevents_states = [];
	
	/// @desc If true, the entity cannot execute commands while this state is active.
	/// @type {Bool}
	restricts_action = false;
	
	/// @desc Initial boolean value for this state.
	/// @type {Bool}
	boolean_value = false;
	
	/// @desc Value the boolean state resets to.
	/// @type {Bool}
	reset_value = false;
	
	/// @desc Whether the entity can hold multiple effects of this state at once.
	/// @type {Bool}
	allow_multiple = false;
	
	/// @desc Maximum number of effects that can stack when allow_multiple is true.
	/// @type {Real}
	max_effects = 1;
	
	/// @desc Struct with passive stat modifiers applied by this state.
	/// @type {Struct}
	stats = {};
	
	/// @desc Iterator that controls this state's duration.
	/// @type {Struct.MallIterator}
	iterator = new MallIterator();

	#region EVENTS
	
	/// @desc Runs once when a state instance is created for an entity.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Affected state instance.
	/// @param {Struct.MallEffectInstance} effect_instance Added effect that triggered the initial activation (optional).
	event_on_start = "";
	
	/// @desc Runs when the state returns to its reset value after all effects are removed.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Affected state instance.
	event_on_end = "";
	
	/// @desc Runs on each RecalculateStats call.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Affected state instance.
	event_on_update = "";
	
	/// @desc Runs on each WateManager turn update.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Affected state instance.
	event_on_turn_update = "";
	
	/// @desc Runs at the start of the entity turn.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Affected state instance.
	event_on_turn_start = "";
	
	/// @desc Runs at the end of the entity turn.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Affected state instance.
	event_on_turn_end = "";
	
	/// @desc Runs after an effect is added to this state.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Affected state instance.
	/// @param {Struct.MallEffectInstance} effect_instance Effect that was added.
	event_on_add_effect = "";
	
	/// @desc Runs after an effect is removed from this state.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Affected state instance.
	/// @param {Struct.MallEffectInstance} effect_instance Effect that was removed.
	event_on_remove_effect = "";

	/// @desc Validates whether an effect can be added to this state. Must return bool.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Affected state instance.
	/// @param {Struct.MallEffectInstance} effect_instance Effect being added.
	/// @return {Bool}
	event_can_add_effect = "";
	
	/// @desc Validates whether an effect can be removed from this state. Must return bool.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStateInstance} state_instance Affected state instance.
	/// @param {Struct.MallEffectInstance} effect_instance Effect being removed.
	/// @return {Bool}
	event_can_remove_effect = "";
	
	#endregion

	#region PRIVATE
	
	/// @ignore
	/// @desc Loads event keys from the data struct.
	/// @param {Struct} data Struct containing event keys.
	static __LoadFunctions = function(_data)
	{
		event_on_start =			_data[$ "event_on_start"]			?? "";
		event_on_end =				_data[$ "event_on_end"]				?? "";
		event_on_update =			_data[$ "event_on_update"]			?? "";
		event_on_turn_update =		_data[$ "event_on_turn_update"]		?? "";
		event_on_turn_start =		_data[$ "event_on_turn_start"]		?? "";
		event_on_turn_end =			_data[$ "event_on_turn_end"]		?? "";
		event_on_add_effect =		_data[$ "event_on_add_effect"]		?? "";
		event_on_remove_effect =	_data[$ "event_on_remove_effect"]	?? "";
		event_can_add_effect =		_data[$ "event_can_add_effect"]		?? "";
		event_can_remove_effect =	_data[$ "event_can_remove_effect"]	?? "";
	}
	
	#endregion
	
	#region API
	
	/// @desc Configures the state from a data struct.
	/// @param {Struct} data Struct containing state data.
	/// @return {Struct.MallState} Configured state instance.
	static FromData = function(_data)
	{
		// Load current state properties.
		state_type =		string_upper(_data[$ "state_type"] ?? "AILMENT");
		priority =			_data[$ "priority"] 		?? 0;
		clears_states =		_data[$ "clears_states"] 	?? [];
		prevents_states =	_data[$ "prevents_states"]	?? [];
		restricts_action =	_data[$ "restricts_action"] ?? false;
		
		// Load legacy/current boolean-stack fields.
		boolean_value =		_data[$ "boolean_value"]	?? false;
		reset_value =		_data[$ "reset_value"]		?? false;
		allow_multiple =	_data[$ "allow_multiple"]	?? false;
		max_effects =		_data[$ "max_effects"]		?? 1;
		
		if (struct_exists(_data, "stats") ) { stats = variable_clone(_data[$ "stats"]); }
		
		if (struct_exists(_data, "iterator") )
		{
			var _iterator_data = _data[$ "iterator"];
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