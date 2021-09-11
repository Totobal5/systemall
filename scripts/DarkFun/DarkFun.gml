global._DARK_COMMANDS = ds_map_create();

#macro DARK global._DARK_COMMANDS
#macro DARK_FUN function(caster, targets, extra)

/// @param {string} key
/// @param {__dark_class_spell} dark_id
/// @returns {__dark_class_spell}
function dark_add(_key, _dark_id) {
    if (!dark_exists(_key) ) {
        ds_map_add(DARK, _key, _dark_id.SetInformation(_key) );
    } 
    
    return DARK[? _key];
}

/// @param {string} dark_subtype
/// @param consume
/// @param include?
/// @param targets
/// @param {string} dark_key
/// @returns {__dark_class_spell}
function dark_create_spell(_subtype = "", _consume = 0, _include = true, _target = 1, _key = "") {
    return (new __dark_class_spell(_subtype, _consume, _include, _target, _key) );
}

/// @param {string} state_type
/// @param value
/// @param turns
/// @param {string} effect_name
/// @returns {__dark_class_effect}
function dark_create_effect(_type, _val, _turns, _name) {
    return (new __dark_class_effect(_type, _val, _turns, _name) );
}

/// @param key
/// @returns {__dark_class_spell}
function dark_get(_key) {
    return (DARK[$ _key] );
}

/// @param key
/// @returns {bool}
function dark_exists(_key) {
    return (ds_map_exists(DARK, _key) );
}

/// @desc Con este codigo se crean todos los hechizos
function dark_init() {
    dark_add("DARK.BATTLE.OBJECT", dark_create_spell("Ataque") );
    dark_add("DARK.BATTLE.ATACK" , dark_create_spell("Objeto") );
    
    dark_add("DARK.WSPEEL.HEAL1", (dark_create_spell("Blanca", 30, true) ).SetSpell(DARK_FUN {
        show_debug_message("DARK SPELL PRUEBA!");    
    }));
}