/// @ignore
/// @desc Base element for most Systemall components.
/// @param {String} [_key=""] Component identifier key.
function Mall(_key="") constructor 
{
	/// @desc Reference to the instance constructor type.
	/// @type {String}
	is = instanceof(self);
	
	/// @desc Base template key for this component.
	/// @type {String}
	key = _key;
	
	/// @desc Instance index inside an array, when applicable.
	/// @type {Real}
	index = -1;
	
	/// @desc Struct used to pass custom event arguments.
	/// @type {Struct}
	args = {};
	
	#region API
	
	/// @desc Exports the base instance state to a save struct.
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
			
			return self;
		}
	};
	
	/// @desc Imports and restores the base instance state from a struct.
	/// @param {{is: String, key: String, index: Real}} import Struct containing saved data.
	static Import = function(_import)
	{
		if (!is_struct(_import))
		{
			__mall_error("Mall.Import expected a struct payload.");
			exit;
		}

		is =    _import[$ "is"]		?? "";
		key =   _import[$ "key"]	?? "";
		index = _import[$ "index"]	?? -1;
	};
	
	/// @desc Configures the component from data. Must be overridden.
	/// @param {Struct} data Struct containing component data.
	static FromData = function(_data) 
	{
		// Struct validation.
		if (!is_struct(_data) )
		{
			__mall_error("Mall.FromData expected a struct payload.");
			exit;
		}

		// Type check.
		if (!struct_exists(_data, "is") || _data[$ "is"] != instanceof(self) )
		{
			__mall_error("Mall.FromData received a struct that is not of the expected type.");
			exit;
		}
		
		// Load base data.
		is = _data[$ "is"] ?? is;
		key = _data[$ "key"] ?? key;
		index = _data[$ "index"] ?? index;
		args = _data[$ "args"] ?? args;

		return self;
	}

	#endregion
}

/// @ignore
/// @desc Lightweight iterator used to track cycle duration and repeats.
function MallIterator() : Mall() constructor
{
	/// @desc Whether the iterator is currently running.
	/// @type {Bool}
	active = false;
	
	/// @desc Number of ticks that compose one full cycle.
	/// @type {Real}
	duration = 1;
	
	/// @desc Number of ticks elapsed in the current cycle.
	/// @type {Real}
	ticks_elapsed = 0;
	
	/// @desc Number of repeats for the cycle. 0 = one execution, infinity = infinite repeats.
	/// @type {Real}
	repeats = 0;
	
	/// @desc Number of repeats already completed.
	/// @type {Real}
	repeats_done = 0;
	
	#region API
	
	/// @desc Configures and activates the iterator.
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
		
		// Allow infinite durations/repeats.
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
	
	/// @desc Returns whether the iterator is currently active.
	/// @return {Bool}
	static IsActive = function()
	{
		return active;
	}
	
	/// @desc Returns current cycle progress as a normalized value in range [0, 1].
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
	/// @param {Struct} import Struct containing saved data.
	static Import = function(_import)
	{
		if (!is_struct(_import))
		{
			__mall_error("MallIterator.Import expected a struct payload.");
			exit;
		}
		
		if (struct_exists(_import, "is") && _import[$ "is"] == instanceof(self) )
		{
			// Call parent import.
			method(self, Mall.Import) (_import);
			
			// Load iterator variables.
			active =			_import[$ "active"]			?? false;
			duration =			_import[$ "duration"]		?? 1;
			ticks_elapsed =		_import[$ "ticks_elapsed"]	?? 0;
			repeats =			_import[$ "repeats"]		?? 0;
			repeats_done =		_import[$ "repeats_done"]	?? 0;

			if (duration <= 0) duration = infinity;
			if (repeats < 0) repeats = infinity;
		}
		else
		{
			__mall_error("MallIterator.Import received a struct with incompatible 'is' field.");
		}
	}
	
	#endregion
}

/// @desc Standardized result container for combat actions.
function MallResult() constructor
{
	/// @desc Overall operation success flag.
	/// @type {Bool}
	success = true;
	
	/// @desc Per-target flags indicating whether each target was defeated.
	/// @type {Array<Bool>}
	defeated = [];
	
	/// @desc Per-target generic numeric values (for example, healing amount).
	/// @type {Array<Real>}
	value = [];
	
	/// @desc Per-target damage values.
	/// @type {Array<Real>}
	damage = [];
	
	/// @desc Per-target consumed resource values (for example, MP cost).
	/// @type {Array<Real>}
	consumed = [];
	
	/// @desc Per-target used item quantities.
	/// @type {Array<Real>}
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
	
	/// @desc Checks whether at least one target was defeated.
	/// @return {Bool}
	static WasAnyDefeated = function()
	{
		var i = 0;
		repeat (array_length(defeated))
		{
			if (defeated[i++]) return true;
		}

		return false;
	}

	#endregion
}