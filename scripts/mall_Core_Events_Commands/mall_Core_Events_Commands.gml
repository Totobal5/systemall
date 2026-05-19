/// Declare default functions/events here.

/// @desc (EVENT) Calculates and applies physical damage to one target.
/// @param {Struct.MallEntity} _caster Acting entity.
/// @param {Struct.MallEntity} _target Target entity.
/// @param {Struct} _params Command parameters (for example, { base_power: 10, scaling_stat: "FUERZA" }).
/// @return {Struct.MallResult}
function EVT_CORE_PhysicalDamage(_caster, _target, _params)
{
    if (!is_struct(_params) || is_undefined(_caster) || is_undefined(_target))
    {
        __mall_error("EVT_CORE_PhysicalDamage received invalid arguments.");
        return new MallResult();
    }

    var _power = struct_exists(_params, "base_power") ? struct_get(_params, "base_power") : 10;
    var _scaling_stat = struct_exists(_params, "scaling_stat") ? struct_get(_params, "scaling_stat") : "FUERZA";
    
    var _caster_atk = _caster.StatGet(_scaling_stat).control_value;
    var _target_def = _target.StatGet("DEFENSA").control_value;
    
    // Simple damage formula.
    var _damage = max(1, (_caster_atk + _power) - _target_def);
    
    _target.StatAdd("EN", -_damage);
    
    // Return standardized result payload.
    var _result = new MallResult();
    _result.Push(
        _target.StatGet("EN").current_value <= 0,	// defeated
        0,											// value (for healing events)
        _damage,									// damage
        0,											// consumed
        0											// used
    );
    return _result;
}

/// @desc (EVENT) Applies an effect to one target.
/// @param {Struct.MallEntity} _caster Acting entity.
/// @param {Struct.MallEntity} _target Target entity.
/// @param {Struct} _params Command parameters (for example, { effect_key: "EFFECT_POISON_TICK" }).
/// @return {Struct.MallResult}
function EVT_CORE_ApplyEffect(_caster, _target, _params)
{
	if (!is_struct(_params) || is_undefined(_target))
	{
		__mall_error("EVT_CORE_ApplyEffect received invalid arguments.");
		return new MallResult();
	}

    var _effect_key = struct_exists(_params, "effect_key") ? struct_get(_params, "effect_key") : undefined;
    if (!is_undefined(_effect_key))
    {
        _target.EffectAdd(_effect_key);
    }
    
    return new MallResult(); // Applying an effect does not deal direct damage.
}

/// @desc Standard script for stat growth using AnimationCurves.
/// Used as event_on_level_up for stats with growth configuration.
/// @param {Struct.MallStatInstance} _stat_inst Stat instance.
/// @return {Real} New calculated peak_value.
function EVT_Standard_GrowthWithCurve(stat_inst)
{
	if (is_undefined(stat_inst) || !is_struct(stat_inst))
	{
		__mall_error("EVT_Standard_GrowthWithCurve expected a valid stat instance.");
		return 0;
	}

    // Read base values.
    var _base = stat_inst.base_value;
    var _growth = stat_inst.growth;
    var _curve = stat_inst.growth_curve;
    var _level = stat_inst.level;
    
    // If no growth is configured, return base value.
    if (_growth == 0 || is_undefined(_curve))
    {
        return _base;
    }
    
    // Normalize level into range [0, 1].
    var _normalized_level = clamp(_level / __MALL_ENTITIES_LEVEL_MAX, 0, 1);
    
    // Evaluate the curve with normalized level.
    var _curve_value = stat_inst.Curve(_normalized_level);
    
    // Formula: base + (growth * curve_value)
    var _total = _base + (_growth * _curve_value);
    
    return round(_total);
}

/// @ignore
/// @desc Registers built-in core event callbacks in the event database.
function __mall_register_core_events_commands()
{
    __Systemall.__events[$ "EVT_CORE_PhysicalDamage"] = EVT_CORE_PhysicalDamage;
    __Systemall.__events[$ "EVT_CORE_ApplyEffect"] = EVT_CORE_ApplyEffect;
    __Systemall.__events[$ "EVT_Standard_GrowthWithCurve"] = EVT_Standard_GrowthWithCurve;
}