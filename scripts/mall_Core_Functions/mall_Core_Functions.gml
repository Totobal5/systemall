/// @desc (EVENTO) Calcula y aplica daño físico a un objetivo.
/// @param {Struct.PartyEntity} caster El que ejecuta la acción.
/// @param {Struct.PartyEntity} target El objetivo de la acción.
/// @param {Struct} params Parámetros del comando (ej: { base_power: 10, scaling_stat: "FUERZA" }).
/// @return {Struct.MallResult}
function EVT_CORE_PhysicalDamage(_caster, _target, _params)
{
    var _power = _params.base_power ?? 10;
    var _scaling_stat = _params.scaling_stat ?? "FUERZA";
    
    var _caster_atk = _caster.StatGet(_scaling_stat).control_value;
    var _target_def = _target.StatGet("DEFENSA").control_value;
    
    // Fórmula de daño simple (se puede hacer tan compleja como se quiera)
    var _damage = max(1, (_caster_atk + _power) - _target_def);
    
    _target.StatAdd("EN", -_damage);
    
    // Devolver un resultado estándar
    var _result = new MallResult();
    _result.Push(
        _target.StatGet("EN").current_value <= 0,	// defeated
        0,											// value (para curaciones)
        _damage,									// damage
        0,											// consumed
        0											// used
    );
    return _result;
}

/// @desc (EVENTO) Aplica un efecto a un objetivo.
/// @param {Struct.PartyEntity} caster El que ejecuta la acción.
/// @param {Struct.PartyEntity} target El objetivo de la acción.
/// @param {Struct} params Parámetros del comando (ej: { effect_key: "EFFECT_POISON_TICK" }).
/// @return {Struct.MallResult}
function EVT_CORE_ApplyEffect(_caster, _target, _params)
{
    var _effect_key = _params.effect_key;
    if (!is_undefined(_effect_key))
    {
        _target.EffectAdd(_effect_key);
    }
    
    return new MallResult(); // Aplicar un efecto no hace daño directo
}

/// @desc Script estándar para el crecimiento de stats usando AnimationCurves.
/// Se usa como event_on_level_up en las estadísticas que tengan configuración de crecimiento.
/// 
/// @param {Struct.EntityStatInstance} stat_inst La instancia de la estadística.
/// @return {Real} El nuevo valor de peak_value calculado.
function EVT_Standard_GrowthWithCurve(stat_inst)
{
    // Obtener valores base
    var _base = stat_inst.base_value;
    var _growth = stat_inst.growth;
    var _curve = stat_inst.growth_curve;
    var _level = stat_inst.level;
    
    // Si no hay crecimiento configurado, devolver el valor base
    if (_growth == 0 || is_undefined(_curve))
    {
        return _base;
    }
    
    // Normalizar el nivel a un rango 0-1 (asumiendo nivel máximo 100)
    var _normalized_level = clamp(_level / __MALL_PARTY_LEVEL_MAX, 0, 1);
    
    // Evaluar la curva en la posición normalizada
    var _curve_value = stat_inst.Curve(_normalized_level);
    
    // Fórmula: base + (growth * curve_value)
    var _total = _base + (_growth * _curve_value);
    
    return round(_total);
}

mall_create_function("EVT_CORE_PhysicalDamage", EVT_CORE_PhysicalDamage);
mall_create_function("EVT_CORE_ApplyEffect", EVT_CORE_ApplyEffect);
mall_create_function("EVT_Standard_GrowthWithCurve", EVT_Standard_GrowthWithCurve);