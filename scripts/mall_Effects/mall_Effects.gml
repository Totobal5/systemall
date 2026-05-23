/// @desc Template for an effect applied to an entity through a state.
/// @param {String} key Unique effect key.
/// @returns {Struct.MallEffect}
function MallEffect(_key) : MallBehavior(_key) constructor
{
	/// @type {String} State key associated with this effect.
	state_key = "";
	
	/// @type {Bool} Boolean value this effect attempts to apply to the target state.
	state_set_value = true;
	
	/// @type {Struct} Stats modified by this effect using [value, num_type, is_passive].
	stats = {};
	
	/// @type {Real} Numeric effect value, for example 15 damage.
	value = 0;
	
	/// @type {Enum.MALL_NUMTYPE} Value type, either real or percent.
	num_type = MALL_NUMTYPE.REAL;
	
	/// @type {Enum.MALL_EFFECT_TURN} Defines which part of the turn runs this effect.
	turn_type = MALL_EFFECT_TURN.START;
	
	/// @type {Struct.MallIterator} Iterator configuration used when the effect starts.
	iterator_start_config = {};
	
	/// @type {Struct.MallIterator} Iterator configuration used when the effect ends.
	iterator_end_config = {};

	#region EVENTS

	/// @desc Runs when the effect is added to a state.
	/// @context Struct.MallEffectInstance
	/// @param {Struct.MallEntity} entity Owning entity.
	/// @param {Struct.MallStateInstance} state_instance State instance that owns this effect.
	/// @returns {undefined}
	// event_on_start = "";
	
	/// @desc Runs when the effect is removed from a state.
	/// @context Struct.MallEffectInstance
	/// @param {Struct.MallEntity} entity Owning entity.
	/// @param {Struct.MallStateInstance} state_instance State instance that used to own this effect.
	/// @returns {undefined}
	// event_on_end = "";
	
	/// @desc Runs at the start of the entity turn.
	/// @context Struct.MallEffectInstance
	/// @param {Struct.MallEntity} entity Owning entity.
	/// @param {Struct.MallStateInstance} state_instance State instance that owns this effect.
	/// @returns {undefined}
	// event_on_turn_start = "";

	/// @desc Runs at the end of the entity turn.
	/// @context Struct.MallEffectInstance
	/// @param {Struct.MallEntity} entity Owning entity.
	/// @param {Struct.MallStateInstance} state_instance State instance that owns this effect.
	/// @returns {undefined}
	// event_on_turn_end = "";
	
	/// @desc Runs to calculate the value to apply.
	/// @context Struct.MallEffectInstance
	/// @param {Struct.MallEntity} entity Owning entity.
	/// @param {Struct.MallStateInstance} state_instance State instance that owns this effect.
	/// @returns {Real}
	event_on_calculate = "";
	
	#endregion

	#region PRIVATE API

	/// @ignore
	/// @desc Loads event strings to be used later.
	/// @param {Struct} data The struct containing the behavior data.
	static __LoadFunction = function(_data)
	{
		// Parent load.
		method(self, MallBehavior.__LoadFunctions) (_data);

		// Load event keys.
		event_on_calculate = _data[$ "event_on_calculate"] ?? "";

		return self;
	}
	
	/// @ignore
	/// @desc Loads and normalizes stat modifiers from the data struct.
	/// @param {Struct} data Effect data struct.
	static __LoadStats = function(_data)
	{
		if (!struct_exists(_data, "stats") ) { return; }

		var _source_stats = _data[$ "stats"];
		var _stat_keys = struct_get_names(_source_stats);
		var _value, _is_passive;

		var i=0; repeat(array_length(_stat_keys) )
		{
			var _key = _stat_keys[i++];
			var _stat_data_value = _source_stats[$ _key];

			// --- Determine stat_key and num_type from the key. ---
			var _len = string_length(_key);
			var _suffix = string_char_at(_key, _len);
			var _num_type = MALL_NUMTYPE.REAL;
			
			if (_suffix == "%" || _suffix == "+") 
			{
				_key = string_delete(_key, _len, 1);
				if (_suffix == "%") _num_type = MALL_NUMTYPE.PERCENT;
			}
			
			// --- Determine value and is_passive from the value. ---
			if (is_array(_stat_data_value) ) 
			{
				_value = _stat_data_value[0];
				_is_passive = (array_length(_stat_data_value) > 1) ? _stat_data_value[1] : false;
			} 
			else 
			{
				// By default, scalar values are active modifiers.
				_value = _stat_data_value;
				_is_passive = false;
			}
			
			// Store in the normalized format.
			stats[$ _key] = [_value, _num_type, _is_passive];
		}

		return self;
	}
	
	#endregion

	#region API

	/// @desc Exports the base instance state to a save struct.
	/// @return {Struct} Struct with essential instance data.
	static Export = function(_data)
	{
		var _this = self;
		with (method(self, MallBehavior.Export) () )
		{
			// Values.
			state_key =	_this.state_key;
			state_set_value = _this.state_set_value;
			value = _this.value;
			
			// Convert num_type to string for export.
			num_type = (_this.num_type == MALL_NUMTYPE.PERCENT) ? "PERCENT" : "REAL";
			
			// Convert turn_type to string for export.
			switch (_this.turn_type)
			{
				case MALL_EFFECT_TURN.START: turn_type = "START"; break;
				case MALL_EFFECT_TURN.END:   turn_type = "END"; break;
				case MALL_EFFECT_TURN.BOTH:  turn_type = "BOTH"; break;
			}

			stats = _this.stats;

			// Iterators.
			if (is_instanceof(_this.iterator_start_config, MallIterator) ) { iterator_start_config = method(_this.iterator_start_config, MallIterator.Export) (); }
			if (is_instanceof(_this.iterator_end_config, MallIterator) )   { iterator_end_config =   method(_this.iterator_end_config, MallIterator.Export) ();   } 

			return self;
		}
	}

	/// @desc Imports and restores the base instance state from a struct.
	/// @param {Struct} data Struct containing component data.
	static Import = function(_data)
	{
		// Call parent import.
		method(self, MallBehavior.Import) (_data);

		// Load Effect data.
		state_key =			_data[$ "state_key"]		?? state_key;
		state_set_value =	_data[$ "state_set_value"]	?? state_set_value;
		value =				_data[$ "value"]			?? value;
		
		// Load number Type.
		var _data_numtype = _data[$ "num_type"] ?? "REAL";
		if (is_string(_data_numtype) ) {_data_numtype = string_upper(_data_numtype); }

		switch (_data_numtype)
		{
			case "PERCENT":	num_type = MALL_NUMTYPE.PERCENT;	break;
			case "REAL":	num_type = MALL_NUMTYPE.REAL;		break;

			default:
				__mall_alert($"Invalid num_type '{_data_numtype}' for effect '{self.key}'. Defaulting to REAL.");
				num_type = MALL_NUMTYPE.REAL;
				break;
		}
		
		// Load turn Type.
		var _data_turntype = _data[$ "turn_type"] ?? "start";
		if (is_string(_data_turntype) ) {_data_turntype = string_upper(_data_turntype); }
		switch (_data_turntype)
		{
			case "START":	turn_type = MALL_EFFECT_TURN.START;		break;
			case "END":		turn_type = MALL_EFFECT_TURN.END;		break;
			case "BOTH":	turn_type = MALL_EFFECT_TURN.BOTH;		break;

			default:
				__mall_alert($"Invalid turn_type '{_data_turntype}' for effect '{self.key}'. Defaulting to START.");
				turn_type = MALL_EFFECT_TURN.START;
				break;
		}
		
		// Load iterators.
		var _iterator_start_data = _data[$ "iterator_start_config"];
		if (is_struct(_iterator_start_data) ) { iterator_start_config = (new MallIterator() ).Import(_iterator_start_data); }

		var _iterator_end_data = _data[$ "iterator_end_config"];
		if (is_struct(_iterator_end_data) ) { iterator_end_config = (new MallIterator() ).Import(_iterator_end_data); }

		// Load stats.
		__LoadStats(_data);
		
		return self;
	}

	/// @desc Returns a string representation of this instance for debugging purposes.
	/// @return {String}	
	static toString = function()
	{
		var _parent_str = method(self, MallBehavior.toString) ();
		return $"{_parent_str}\nMallEffect::\nState Key: {state_key}\nState Set Value: {state_set_value}\nValue: {value}\nNum Type: {num_type}\nTurn Type: {turn_type}\nStats: {struct_to_string(stats)}";
	}

	#endregion
}