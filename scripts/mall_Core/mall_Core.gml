/// @ignore
/// @desc Base class for all Systemall components.
/// @param {String} [_key=""] Component identifier key.
function Mall(_key="") constructor 
{
	/// @type {String} Reference to the instance constructor type.
	is = instanceof(self);

	/// @type {String} Optional note or comment.
	comment = "";

	/// @type {String} Unique key for this component, used to reference templates within the same component type.
	/// Used as an identifier.
	key = _key;
	
	/// TODO: Implement this later.
	/// @type {Real} Instance index inside an array, when applicable.
	/// This is used to track the instance inside its parent group array and should be updated on array modifications.
	index = -1;

	/// @type {Struct} Struct used to pass custom event arguments.
	/// Allows flexible event hooks without requiring a fixed set of fields for every possible argument.
	/// Example: a command with a "power" argument that can be modified by events and persisted in saves without adding a "power" field to the MallCommand class.
	args = __MALL_DEFAULT_ARGS;
	
	/// @type {Struct} Struct used to store custom instance variables.
	/// Allows custom variable storage without requiring pre-defined fields on the class.
	/// Example: a custom sword with a "sharpness" variable that can be modified by events and persisted in saves without adding a "sharpness" field to the MallItem class.
	vars = __MALL_DEFAULT_VARS;

	/// @type {Array<String>} General type category for this component, used for organizational purposes.
	/// Is used in conjunction with the Type system of Systemall, but is not strictly required to be unique.
	type = __MALL_TYPE_DEFAULT;
	
	#region PUBLIC API

	/// @desc Check whether the provided struct contains the same fields and values as this instance's vars struct.
	/// Used for matching items with variable-dependent stats or effects.
	/// @param {Struct} other_vars Struct to compare with this instance's vars.
	/// @return {Bool} Whether the provided struct matches this instance's vars.
	static SameVars = function(_other_vars)
	{
		var _this_vars_names = struct_get_names(vars);
		var _other_vars_names = struct_get_names(_other_vars);

		// Quick check for different number of variables.
		if (array_length(_this_vars_names) != array_length(_other_vars_names) ) { return false; }

		var i=0; repeat(array_length(_this_vars_names) )
		{
			// Check that the variable name exists in the other struct.
			var _var_name = _this_vars_names[i++];
			if (!struct_exists(_other_vars, _var_name) ) { return false; }

			// Now check for variable value equality.
			var _var_value = vars[$ _var_name];
			var _other_var_value = _other_vars[$ _var_name];

			if (_var_value != _other_var_value) { return false; }
		}

		return true;
	}

	/// @desc Set a custom variable in this instance's vars struct.
	/// @param {String|Real} key_or_hash Variable name or hash.
	/// @param {Any} value Variable value.
	static SetVar = function(_key_or_hash, _value)
	{
		if (is_numeric(_key_or_hash) )
		{
			struct_set_from_hash(vars, _key_or_hash, _value);
		}
		else if(is_string(_key_or_hash) )
		{
			struct_set(vars, _key_or_hash, _value);
		}
		else
		{
			__mall_error($"Mall.SetVar expected a string or numeric (hash) key. Received: {_key_or_hash}");
		}
		
		return self;
	}

	/// @desc Get a custom variable from this instance's vars struct.
	/// @param {String|Real} key_or_hash Variable name or hash.
	/// @param {Any} default_value Value to return if the variable is not found.
	static GetVar = function(_key_or_hash, _default)
	{
		var _value = _default;

		if (is_numeric(_key_or_hash) )
		{
			_value = struct_get_from_hash(vars, _key_or_hash, _value);
		}
		else if(is_string(_key_or_hash) )
		{
			_value = struct_get(vars, _key_or_hash, _value);
		}
		else
		{
			__mall_error($"Mall.GetVar expected a string or numeric (hash) key. Received: {_key_or_hash}");
		}

		return _value;
	}	

	/// @desc Export the base instance state to a save struct.
	/// Call this via Function.static_get (aka super) inside child classes' Export methods.
	/// @return {Struct} Struct with essential instance data.
	static Export = function()
	{
		var _this = self;
		with ({})
		{
			version =   __MALL_VERSION_MINE;
			is =        _this.is;
			key =       _this.key;
			index =     _this.index;
			args =      _this.args;
			vars =      _this.vars;
			type =		variable_clone(_this.type);

			return self;
		}
	};
	
	/// @desc Import and restore the base instance state from a struct.
	/// Call this via Function.static_get (aka super) inside child classes' Import methods.
	/// @param {Struct} data Struct containing component data.
	static Import = function(_data)
	{
		var _type_old = type;

		// Struct validation.
		if (!is_struct(_data) )
		{
			__mall_error("Mall.Import expected a struct payload.");
			exit;
		}
		is =		_data[$ "is"]		?? is;
		comment =	_data[$ "comment"]	?? comment;
		key =   _data[$ "key"]		?? key;
		index = _data[$ "index"]	?? index;
		args =  _data[$ "args"]		?? args;
		vars =  _data[$ "vars"]		?? vars;
		type =	_data[$ "type"]		?? type;

		if (!is_array(type) )
		{
			if (is_string(type) ) 
			{
				type = [type];
				__mall_alert($"Mall.Import expected 'type' field to be an array. Converted string to array. Value: {type}");
			}
			else
			{
				type = _type_old;
				__mall_alert($"Mall.Import expected 'type' field to be an array. Using old value. Value: {type}");
			}
		}

		return self;
	};

	/// @desc Return a string representation of this instance for debugging.
	/// Call this via Function.static_get (aka super) from child classes' toString methods.
	/// @return {String}
	static toString = function()
	{
		return $"Systemall Component::\n		Core:: (Type: {type}, Key: {key})";
	}

	#endregion
}

/// @desc Lightweight iterator used to track cycle duration and repeats.
function MallIterator(_key="") : Mall(_key="") constructor
{
	/// @ignore 
	/// @type {Real} Static ID counter for all MallIterator instances. Used to assign unique keys.
	static __id = 1;
	
	/// @ignore 
	/// @type {Struct<Struct.MallIterator>} Static registry of all MallIterator instances
	static __all = {};

	/// @type {Bool} Whether the iterator is currently running.
	active = false;
	
	/// @type {Real} Number of ticks that compose one full cycle.
	duration = 1;
	
	/// @type {Real} Number of ticks elapsed in the current cycle.
	ticks_elapsed = 0;
	
	/// @type {Real} Number of repeats for the cycle. 0 = one execution, infinity = infinite repeats.
	repeats = 0;
	
	/// @type {Real} Number of repeats already completed.
	repeats_done = 0;
	
	// Register this instance in the static registry.
	struct_set(__all, $"_key_{__id++}", self);

	#region API
	
	/// @desc Get all MallIterator instances.
	/// @return {Struct<Struct.MallIterator>}
	static GetAll = function()
	{
		return static_get(self)[$ "__all"];
	}

	/// @desc Remove all inactive MallIterator instances from the static registry.
	static AllCleanup = function()
	{
		struct_foreach(GetAll(), function(_key, _value) {
			if (!_value.active) { delete _value; struct_remove(static_get(self)[$ "__all"], _key); }
		});
	}

	/// @desc Configure and activate the iterator.
	/// @param {Real} [duration=1] Tick count for one cycle.
	/// @param {Real} [repeats=0] Number of times to repeat.
	static Configure = function(_duration=1, _repeats=0)
	{
		active = true;
		
		duration =	_duration;
		repeats =	_repeats;
		
		// Reset counters.
		ticks_elapsed = 0;
		repeats_done = 0;
		
		// Allow infinite duration or repeats.
		if (duration <= 0) duration = infinity;
		if (repeats < 0) repeats = infinity;
		
		return self;
	}
	
	/// @desc Advances the iterator one tick and returns its current state.
	/// @return {Enum.MALL_ITERATOR_STATE} Iterator state after the tick.
	static Tick = function()
	{
		if (!active) return MALL_ITERATOR_STATE.INACTIVE;

		if (duration <= 0)
		{
			__mall_error("MallIterator.Tick detected invalid duration <= 0. Falling back to infinity.");
			duration = infinity;
		}
		
		ticks_elapsed++;
		
		// Check whether the current cycle has ended.
		if (ticks_elapsed >= duration)
		{
			// Cycle ended. Check if it should repeat.
			if (repeats_done < repeats)
			{
				repeats_done++;
				ticks_elapsed = 0; // Reset for the next cycle.
				return MALL_ITERATOR_STATE.CYCLE_END;
			}
			else
			{
				active = false;
				return MALL_ITERATOR_STATE.COMPLETED;
			}
		}
		
		// Cycle is still running.
		return MALL_ITERATOR_STATE.WORKING;
	}
	
	/// @desc Return whether the iterator is currently active.
	/// @return {Bool}
	static IsActive = function()
	{
		return active;
	}
	
	/// @desc Return current cycle progress as a normalized value in [0, 1].
	/// @return {Real}
	static GetProgress = function()
	{
		if (duration == infinity) return 0;
		return ticks_elapsed / duration;
	}
	
	/// @desc Creates a new iterator with the same configuration (not current runtime state).
	/// @return {Struct.MallIterator}
	static Copy = function()
	{
		return (new MallIterator() ).Configure(duration, repeats);
	}
	
	/// @desc Exports the iterator runtime state to a struct.
	/// @return {Struct}
	static Export = function()
	{
		var _this = self;
		// Call parent export.
		with (method(_this, Mall.Export) () )
		{
			active =			_this.active;
			duration =			_this.duration;
			ticks_elapsed =		_this.ticks_elapsed;
			repeats =			_this.repeats;
			repeats_done =		_this.repeats_done;
			
			return self;
		}
	}
	
	/// @desc Imports iterator state from a struct.
	/// @param {Struct} data Struct containing component data.
	static Import = function(_data)
	{
		if (!is_struct(_data) )
		{
			__mall_error("MallIterator.Import expected a struct payload.");
			return self;
		}
		
		// Call parent import.
		method(self, Mall.Import) (_data);
		
		// Load iterator variables.
		active =			_data[$ "active"]			?? false;
		duration =			_data[$ "duration"]			?? 1;
		ticks_elapsed =		_data[$ "ticks_elapsed"]	?? 0;
		repeats =			_data[$ "repeats"]			?? 0;
		repeats_done =		_data[$ "repeats_done"]		?? 0;

		// Allow infinite durations/repeats.
		if (duration <= 0) duration = infinity;
		if (repeats < 0)   repeats =  infinity;

		return self;
	}
	
	/// @desc Return a string representation of this instance for debugging.
	/// @return {String}
	static toString = function()
	{
		var _parent_str = method(self, Mall.toString) ();
		return $"{_parent_str}\nMallIterator:: (Active: {active}, Duration: {duration}, Ticks Elapsed: {ticks_elapsed}, Repeats: {repeats}, Repeats Done: {repeats_done})";
	}

	#endregion
}

/// @desc Standardized result container for combat actions.
function MallResult(_success = true) : Mall("MallResult") constructor
{
	/// @type {Bool} Overall operation success flag.
	success = _success;
	
	/// @type {Array<Bool>} Per-target flags indicating whether each target was defeated.
	defeated = [];
	
	/// @type {Array<Real>} Per-target generic numeric values (for example, healing amount).
	value = [];
	
	/// @type {Array<Real>} Per-target damage values.
	damage = [];
	
	/// @type {Array<Real>} Per-target consumed resource values (for example, MP cost).
	consumed = [];
	
	/// @type {Array<Real>} Per-target used item quantities.
	used = [];
	
	#region API
	
	/// @desc Appends one target result entry to all result arrays.
	/// @param {Bool} defeated Whether the target was defeated.
	/// @param {Real} value Generic value (for example, healing).
	/// @param {Real} damage Damage dealt.
	/// @param {Real} consumed Resource consumed (for example, MP).
	/// @param {Real} used Item amount used.
	static Push = function(_defeated, _value, _damage, _consumed, _used)
	{
		array_push(defeated, _defeated);
		array_push(value, _value);
		array_push(damage, _damage);
		array_push(consumed, _consumed);
		array_push(used, _used);
		return self;
	}
	
	/// @desc Returns the number of targets affected by this action.
	/// @return {Real}
	static Size = function()
	{
		return array_length(damage);
	}
	
	/// @desc Returns total damage dealt across all targets.
	/// @return {Real}
	static GetTotalDamage = function()
	{
		var _total = 0;
		var i=0; repeat( Size() ) { _total += damage[i++]; }

		return _total;
	}
	
	/// @desc Returns total generic value across all targets (for example, total healing).
	/// @return {Real}
	static GetTotalValue = function()
	{
		var _total = 0;
		var i=0; repeat( Size() ) { _total += value[i++]; }
		
		return _total;
	}
	
	/// @desc Returns damage for one target index.
	/// @param {Real} [_index=0] Target index (defaults to first target).
	/// @return {Real}
	static GetDamage = function(_index = 0)
	{
		return (_index >= 0 && _index < Size() ) ? damage[_index] : 0;
	}
	
	/// @desc Returns generic value for one target index.
	/// @param {Real} [_index=0] Target index (defaults to first target).
	/// @return {Real}
	static GetValue = function(_index = 0)
	{
		return (_index >= 0 && _index < Size() ) ? value[_index] : 0;
	}
	
	/// @desc Return whether at least one target was defeated.
	/// @return {Bool}
	static WasAnyDefeated = function()
	{
		var i = 0; repeat (array_length(defeated) ) { if (defeated[i++]) return true; }
		return false;
	}

	/// @desc Return a string representation of this result for debugging.
	/// @return {String}
	static toString = function()
	{
		var _parent_str = method(self, Mall.toString) ();
		return $"{_parent_str}\nMallResult:: (Success: {success}, Defeated: {defeated}, Value: {value}, Damage: {damage}, Consumed: {consumed}, Used: {used})";
	}

	#endregion
}