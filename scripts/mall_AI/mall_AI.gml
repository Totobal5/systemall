// -----------------------------------------------------------------------------
// EJEMPLO DE JSON (data/ai/packages.json) - NUEVA ESTRUCTURA MODULAR
// -----------------------------------------------------------------------------
/*
{
    "type": "AI",
    "rules": {
        "RULE_HEAL_LOW_ALLY": {
            "priority": 100,
            "condition": "AI_COND_Ally_HP_Below_30_Percent",
            "action": "AI_ACTION_Use_Heal_Spell",
            "target": "AI_TARGET_Ally_With_Lowest_HP"
        },
        "RULE_ATTACK_DEFAULT": {
            "priority": 0,
            "condition": "AI_COND_Always_True",
            "action": "AI_ACTION_Use_Default_Attack",
            "target": "AI_TARGET_Random_Enemy"
        },
        "RULE_BOSS_SPECIAL_ATTACK": {
            "priority": 80,
            "condition": "AI_COND_Turn_Is_Multiple_Of_3",
            "action": "AI_ACTION_Use_Ultimate_Skill",
            "target": "AI_TARGET_All_Enemies"
        }
    },
    "packages": {
        "AI_PACKAGE_SIMPLE_ATTACKER": {
            "rules": [ "RULE_ATTACK_DEFAULT" ]
        },
        "AI_PACKAGE_HEALER_SUPPORT": {
            "rules": [ "RULE_HEAL_LOW_ALLY", "RULE_ATTACK_DEFAULT" ]
        },
        "AI_PACKAGE_BOSS": {
            "rules": [
                "RULE_BOSS_SPECIAL_ATTACK",
                "AI_PACKAGE_HEALER_SUPPORT" 
            ]
        }
    }
}
*/

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