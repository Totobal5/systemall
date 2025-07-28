// Feather ignore all
/// @desc El "cerebro" de una entidad, que toma decisiones basadas en un paquete de IA.
/// @param {Struct.PartyEntity} parent_entity La entidad que posee esta IA.
/// @param {String} ai_package_key La llave del paquete de IA a utilizar.
function EntityAIInstance(_parent_entity, _ai_package_key) constructor
{
    parent_entity = _parent_entity;
    
    // Lista final de reglas, aplanada y ordenada por prioridad.
    resolved_rules = [];
    
    // Aquí se podrían guardar variables de estado de la IA (ej: memoria de aggro)
    memory = {};

    // --- Inicialización ---
    var _package = mall_get_ai_package(_ai_package_key);
    if (!is_undefined(_package))
    {
        resolved_rules = __ResolveRules(_package.rules);
        array_sort(resolved_rules, function(ruleA, ruleB) {
            return ruleB.priority - ruleA.priority;
        });
    }
   
    /// @desc (Privado) Procesa un array de llaves de reglas y paquetes para construir una lista plana.
    /// @ignore
    static __ResolveRules = function(_rules_array)
    {
        var _flat_list = [];
        for (var i = 0; i < array_length(_rules_array); i++)
        {
            var _key = _rules_array[i];
            
            if (variable_struct_exists(Systemall.__ai_rules, _key))
            {
                array_push(_flat_list, Systemall.__ai_rules[$ _key]);
            }
            else if (variable_struct_exists(Systemall.__ai_packages, _key))
            {
                var _nested_package = Systemall.__ai_packages[$ _key];
                var _nested_rules = __ResolveRules(_nested_package.rules);
                array_copy(_flat_list, array_length(_flat_list), _nested_rules, 0, array_length(_nested_rules));
            }
        }
        return _flat_list;
    }
	
    /// @desc Selecciona la mejor acción a realizar en el turno actual.
    /// @param {Struct} battle_context Un struct con información del combate (aliados, enemigos, etc.).
    /// @return {Struct.WateAction} La acción a ejecutar, o undefined.
    static SelectAction = function(_battle_context)
    {
        for (var i = 0; i < array_length(resolved_rules); i++)
        {
            var _rule = resolved_rules[i];
            var _condition_func = mall_get_function(_rule.condition);
            
            if (is_callable(_condition_func) && _condition_func(parent_entity, _battle_context))
            {
                var _target_func = mall_get_function(_rule.target);
                var _targets = is_callable(_target_func) ? _target_func(parent_entity, _battle_context) : [];
                
                if (array_length(_targets) > 0)
                {
                    var _action_func = mall_get_function(_rule.action);
                    if (is_callable(_action_func))
                    {
                        var _command_key = _action_func(parent_entity, _targets);
                        var _command_template = mall_get_dark(_command_key);
                        
                        if (!is_undefined(_command_template)) {
                            // Devolver una instancia de WateAction
                            return new WateAction(parent_entity, _command_template, _targets);
                        }
                    }
                }
            }
        }
        
        return undefined;
    }
}

/// @desc Crea las plantillas de IA (reglas y paquetes) desde data.
function mall_ai_create_from_data(_data)
{
    // Cargar Reglas Reutilizables
    if (variable_struct_exists(_data, "rules") )
    {
        var _rules = _data.rules;
        var _rule_keys = variable_struct_get_names(_rules);
        for (var i = 0; i < array_length(_rule_keys); i++)
        {
            var _key = _rule_keys[i];
            Systemall.__ai_rules[$ _key] = _rules[$ _key];
        }
    }
    
    // Cargar Paquetes de IA
    if (variable_struct_exists(_data, "packages") )
    {
        var _packages = _data.packages;
        var _package_keys = variable_struct_get_names(_packages);
        for (var i = 0; i < array_length(_package_keys); i++)
        {
            var _key = _package_keys[i];
            Systemall.__ai_packages[$ _key] = _packages[$ _key];
            array_push(Systemall.__ai_keys, _key);
        }
    }
}

/// @desc Devuelve la plantilla de un paquete de IA.
function mall_get_ai_package(_key)
{
    return Systemall.__ai_packages[$ _key];
}