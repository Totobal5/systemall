/// @desc Base container for components that expose event hooks.
/// @param {String} key Component template key.
function MallBehavior(_key) : Mall(_key) constructor
{
    // --- Event keys ---
    // These fields store FUNCTION KEY STRINGS, not callables.
    // The callable is resolved from __Systemall.__events when needed.
    
    // Component lifecycle hooks.
    event_on_start = "";
    event_on_end = "";
    event_on_update = "";
    
    // Turn hooks.
    event_on_turn_update = "";
    event_on_turn_start = "";
    event_on_turn_end = "";
    
    // Equipment hooks.
    event_on_equip = "";
    event_on_desequip = "";
}