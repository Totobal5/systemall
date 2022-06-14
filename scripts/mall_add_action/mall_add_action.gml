/// @param action_key
/// @param [prefix_keys]
/// @desc Añade acciones globalmente
function mall_add_action(_key) {
    var _action = new MallAction(_key);
    
    // Rellenar sub-tipos
    var i = 1; repeat (argument_count - 1) {
		_action.set(argument[i++] ); 
	}
	
	global.__mall_actions_index[$ _key] = _action;
	array_push(global.__mall_actions_master, _key);
}