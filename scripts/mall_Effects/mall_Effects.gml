/// @desc Template for an effect applied to an entity through a state.
/// @param {String} key Unique effect key.
/// @returns {Struct.MallEffect}
function MallEffect(_key) : MallBehavior(_key) constructor
{
	/// @desc State key associated with this effect.
	/// @type {String}
	state_key = "";
	
	/// @desc Boolean value this effect attempts to apply to the target state.
	/// @type {Bool}
	state_set_value = true;
	
	/// @desc Parameters used to configure reusable event callbacks.
	/// @type {Struct}
	params = {};
	
	/// @desc Stats modified by this effect using [value, num_type, is_passive].
	/// @type {Struct}
	stats = {};
	
	/// @desc Numeric effect value, for example 15 damage.
	/// @type {Real}
	value = 0;
	
	/// @desc Value type, either real or percent.
	/// @type {Enum.MALL_NUMTYPE}
	num_type = MALL_NUMTYPE.REAL;
	
	/// @desc Defines which part of the turn runs this effect.
	/// @type {Enum.MALL_EFFECT_TURN}
	turn_type = MALL_EFFECT_TURN.START;
	
	/// @desc Iterator configuration used when the effect starts.
	/// @type {Struct}
	iterator_start_config = {};
	
	/// @desc Iterator configuration used when the effect ends.
	/// @type {Struct}
	iterator_end_config = {};

	#region EVENTS

	/// @desc Runs when the effect is added to a state.
	/// @context Struct.MallEffectInstance
	/// @param {Struct.MallEntity} entity Owning entity.
	/// @param {Struct.MallStateInstance} state_instance State instance that owns this effect.
	/// @returns {undefined}
	event_on_start = "";
	
	/// @desc Runs when the effect is removed from a state.
	/// @context Struct.MallEffectInstance
	/// @param {Struct.MallEntity} entity Owning entity.
	/// @param {Struct.MallStateInstance} state_instance State instance that used to own this effect.
	/// @returns {undefined}
	event_on_end = "";
		
	/// @desc Runs at the start of the entity turn.
	/// @context Struct.MallEffectInstance
	/// @param {Struct.MallEntity} entity Owning entity.
	/// @param {Struct.MallStateInstance} state_instance State instance that owns this effect.
	/// @returns {undefined}
	event_on_turn_start = "";

	/// @desc Runs at the end of the entity turn.
	/// @context Struct.MallEffectInstance
	/// @param {Struct.MallEntity} entity Owning entity.
	/// @param {Struct.MallStateInstance} state_instance State instance that owns this effect.
	/// @returns {undefined}
	event_on_turn_end = "";
	
	/// @desc Runs to calculate the value to apply.
	/// @context Struct.MallEffectInstance
	/// @param {Struct.MallEntity} entity Owning entity.
	/// @param {Struct.MallStateInstance} state_instance State instance that owns this effect.
	/// @returns {Real}
	event_on_calculate = "";
	
	#endregion

	#region PRIVATE API
	/// @ignore
	/// @desc Loads event keys from the data struct.
	static __LoadFunction = function(_data)
	{
		// Event key used when the effect is added.
		event_on_start = _data[$ "event_on_start"] ?? "";
		// Event key used when the effect is removed.
		event_on_end = _data[$ "event_on_end"] ?? "";
		
		event_on_turn_start = _data[$ "event_on_turn_start"] ?? "";
		event_on_turn_end = _data[$ "event_on_turn_end"] ?? "";
		event_on_calculate = _data[$ "event_on_calculate"] ?? "";

		return self;
	}
	
	/// @ignore
	/// @desc Loads and normalizes stat modifiers from the data struct.
	/// @param {Struct} _data Effect data struct.
	static __LoadStats = function(_data)
	{
		if (struct_exists(_data, "stats") )
		{
			var _source_stats = _data[$ "stats"];
			var _mod_keys = struct_get_names(_source_stats);
			var _mod_keys_length = array_length(_mod_keys);
			
			for (var i = 0; i < _mod_keys_length; i++)
			{
				var _mod_key_full = _mod_keys[i];
				var _mod_value_data = _source_stats[$ _mod_key_full];
				
				// --- Determine stat_key and num_type from the key. ---
				var _len = string_length(_mod_key_full);
				var _suffix = string_char_at(_mod_key_full, _len);
				var _stat_key = _mod_key_full;
				var _num_type = MALL_NUMTYPE.REAL;
				
				if (_suffix == "%" || _suffix == "+") 
				{
					_stat_key = string_delete(_mod_key_full, _len, 1);
					if (_suffix == "%") _num_type = MALL_NUMTYPE.PERCENT;
				}
				
				// --- Determine value and is_passive from the value. ---
				var _value;
				var _is_passive;
				
				if (is_array(_mod_value_data) ) 
				{
					_value = _mod_value_data[0];
					_is_passive = (array_length(_mod_value_data) > 1) ? _mod_value_data[1] : false;
				} 
				else 
				{
					// By default, scalar values are active modifiers.
					_value = _mod_value_data;
					_is_passive = false;
				}
				
				// Store in the normalized format.
				self[$ "stats"][$ _stat_key] = [_value, _num_type, _is_passive];
			}
		}

		return self;
	}
	
	#endregion

	#region API
	/// @desc Configures the effect from a data struct.
	/// @param {Struct} _data Effect configuration data.
	/// @returns {Struct.MallEffect}
	static FromData = function(_data)
	{
		state_key = _data[$ "state_key"] ?? "";
		state_set_value = _data[$ "state_set_value"] ?? true;
		value =	_data[$ "value"] ?? 0;
		num_type = (_data[$ "num_type"] == "percent") ? MALL_NUMTYPE.PERCENT : MALL_NUMTYPE.REAL;

		// Load parameters.
		params = variable_clone(_data[$ "params"] ?? {});
		
		// Reset mutable data before loading to avoid stale values.
		self[$ "stats"] = {};
		self[$ "iterator_start_config"] = {};
		self[$ "iterator_end_config"] = {};
		
		var _tt = _data[$ "turn_type"] ?? "start";
		switch (_tt) 
		{
			case "end":		turn_type = MALL_EFFECT_TURN.END;	break;
			case "both":	turn_type = MALL_EFFECT_TURN.BOTH;	break;
			default:		turn_type = MALL_EFFECT_TURN.START; break;
		}
		
		// Load iterators.
		if (struct_exists(_data, "iterator_start_config") ) { self[$ "iterator_start_config"] = variable_clone(_data[$ "iterator_start_config"]); }
		if (struct_exists(_data, "iterator_end_config") )  { self[$ "iterator_end_config"] = variable_clone(_data[$ "iterator_end_config"]); }
		
		// Load stats.
		__LoadStats(_data);
		// Load event keys.
		__LoadFunction(_data);
		
		return self;
	}
	
	#endregion
}