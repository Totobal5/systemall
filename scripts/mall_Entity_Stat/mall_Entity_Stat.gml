/// @desc Represents a stat instance owned by an entity.
/// @param {Struct.MallStat} stat_template Stat template to instantiate.
/// @param {Struct.MallEntity} parent_entity Entity that owns this instance.
function MallStatInstance(_template, _entity) constructor
{
	/// @desc Entity that owns this stat instance.
	/// @type {Struct.MallEntity}
	parent_entity = _entity;
	
	/// @desc MallStat template referenced by this instance.
	/// @type {Struct.MallStat}
	template = _template;
	
	/// @desc Current stat level.
	/// @type {Real}
	level = template.base_level;
	
	/// @desc Base value before recalculation.
	/// @type {Real}
	base_value = template.base_value;
	
	// Calculated values.
	
	/// @desc Maximum value after applying level scaling.
	/// @type {Real}
	peak_value = 0;
	
	/// @desc Value after applying equipment modifiers.
	/// @type {Real}
	equipment_value = 0;
	
	/// @desc Final value after applying state modifiers.
	/// @type {Real}
	control_value = 0;
	
	/// @desc Current runtime value, for example current HP.
	/// @type {Real}
	current_value = 0;
	
	/// @desc Previous peak value snapshot.
	/// @type {Real}
	last_peak_value = peak_value;
	
	/// @desc Previous current value snapshot.
	/// @type {Real}
	last_current_value = current_value;
	
	// --- Growth configuration. ---
	
	/// @desc Growth amount applied per level.
	/// @type {Real}
	growth = 0;
	
	/// @desc Curve name, for example "linear".
	/// @type {String}
	curve_name = "";
	
	/// @desc Reference to an AnimationCurveChannel.
	/// @type {Any|undefined}
	growth_curve = undefined;
	
	#region EVENTS
	
	/// @desc Runs once when the instance is created for an entity.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStatInstance} stat_instance Current instance.
	/// @returns {undefined}
	event_on_start = method(parent_entity, mall_get_event( template[$ "event_on_start"] ) );
	
	/// @desc (Not currently implemented by the engine.)
	/// @returns {undefined}
	event_on_end = method(parent_entity, mall_get_event( template[$ "event_on_end"] ) );
	
	/// @desc Runs on each RecalculateStats call after peak_value is calculated.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStatInstance} stat_instance Current instance.
	/// @returns {undefined}
	event_on_update = method(parent_entity, mall_get_event( template[$ "event_on_update"] ) );
	
	/// @desc Runs to calculate the stat peak_value. Must return the new value.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStatInstance} stat_instance Current instance.
	/// @returns {Real}
	event_on_level_up =	method(parent_entity, __mall_get_event_stat_level_up( template[$ "event_on_level_up"] ) );	
	
	/// @desc (For standalone stats.) Checks whether the stat can level up. Must return a boolean.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStatInstance} stat_instance Current instance.
	/// @returns {Bool}
	event_on_level_check = method(parent_entity, __mall_get_event_check_true( template[$ "event_on_level_check"] ) );	

	/// @desc Runs when an item is equipped in any entity slot.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStatInstance} stat_instance Current instance.
	/// @param {Struct.MallSlotInstance} slot_instance The slot where the item was equipped.
	/// @returns {undefined}
	event_on_equip = method(parent_entity, mall_get_event( template[$ "event_on_equip"] ) );
	
	/// @desc Runs when an item is unequipped from any entity slot.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStatInstance} stat_instance Current instance.
	/// @param {Struct.MallSlotInstance} slot_instance The slot from which the item was unequipped.
	/// @returns {undefined}
	event_on_desequip = method(parent_entity, mall_get_event( template[$ "event_on_desequip"] ) );

	// Turn events.
	
	/// @desc Runs on each turn update of the WateManager.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStatInstance} stat_instance Current instance.
	/// @returns {undefined}
	event_on_turn_update = method(parent_entity, mall_get_event( template[$ "event_on_turn_update"] ) );
	
	/// @desc Runs at the start of the entity turn.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStatInstance} stat_instance Current instance.
	/// @returns {undefined}
	event_on_turn_start = method(parent_entity, mall_get_event( template[$ "event_on_turn_start"] ) );
	
	/// @desc Runs at the end of the entity turn.
	/// @context Struct.MallEntity
	/// @param {Struct.MallStatInstance} stat_instance Current instance.
	/// @returns {undefined}
	event_on_turn_end = method(parent_entity, mall_get_event( template[$ "event_on_turn_end"] ) );	
	
	#endregion

	#region METHODS

	/// @desc Recalculates the base stat value (peak_value).
	/// @param {Struct.MallEntity} entity The owning entity.
	/// @returns {undefined}
	static Recalculate = function(_entity)
	{
		// Handle independent stat leveling.
		if (template.is_standalone_level)
		{
			if (is_callable(event_on_level_check) && event_on_level_check(self) ) 
			{
				event_on_level_up(self);
				exit;
			}
		}
		
		peak_value = is_callable(event_on_level_up) ? event_on_level_up(self) : base_value;
		// General stat update event.
		if (is_callable(event_on_update) ) event_on_update(self);
	}
	
	/// @desc Returns a specific stat value.
	/// @param {MALL_STAT_TARGET} target Target value to read.
	/// @returns {Real}
	static ReturnValueTarget = function(_numtarget)
	{
		switch (_numtarget) 
		{
			case MALL_STAT_TARGET.CURRENT:		return current_value;
			case MALL_STAT_TARGET.LAST_CURRENT:	return last_current_value;
			case MALL_STAT_TARGET.PEAK:			return peak_value;
			case MALL_STAT_TARGET.LAST_PEAK:	return last_peak_value;
			case MALL_STAT_TARGET.EQUIPMENT:	return equipment_value;
			case MALL_STAT_TARGET.CONTROL:		return control_value;
			default:
				__mall_alert($"Unknown stat value target: {_numtarget}. Returning 0 by default.");
			return 0;
		}
	}

	/// @desc Exports the current stat instance state.
	/// @returns {{level: Real, current_value: Real, base_value: Real}}
	static Export = function()
	{
		return {
			level: level,
			current_value: current_value,
			base_value: base_value
		};
	}
	
	/// @desc Imports the stat instance state.
	/// @param {{level: Real, current_value: Real, base_value: Real}} data State data to import.
	/// @returns {undefined}
	static Import = function(_data)
	{
		level =			_data[$ "level"]			?? template.base_level;
		current_value = _data[$ "current_value"]	?? 0;
		base_value =	_data[$ "base_value"]		?? template.base_value;
	}

	/// @desc Evaluates an animation curve at a normalized position (0-1).
	/// @param {Real} position Position along the curve from 0 to 1.
	/// @returns {Real} Value evaluated at that position.
	static Curve = function(_position)
	{
		if (curve_name == "") return 0;
		
		// When this is an AnimationCurve asset.
		if (mall_asset_exists(curve_name) )
		{
			var _curve = mall_asset_get(curve_name);
			return animcurve_channel_evaluate(_curve, clamp(_position, 0, 1) );
		}
		
		return 0;
	}
	
	#endregion
}
