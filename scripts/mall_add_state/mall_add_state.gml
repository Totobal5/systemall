/// @param	{String} state_key
/// @param	{String} [prefix_keys]
/// @desc	Crea un estado y agrega una estadistica al Storage en base al nuevo estado 
/// 		utiliza prefijos para crear las estadisticas relacionadas
function mall_add_state(_key) {
    var _prefix = [MALL_STATE_PREFIX_ATTACK, MALL_STATE_PREFIX_DEFEND];
    // Agregar estadisticas default
	mall_add_stat(_key + MALL_STATE_PREFIX_ATTACK);
	mall_add_stat(_key + MALL_STATE_PREFIX_DEFEND);
	
	#region Agregar estadisticas extras
    var i=1; repeat(argument_count - 1) {
        var _in = argument[i++]; // Obtener prefijos de Stat
        
        // Guardar los prefijos de stats
        array_push(_prefix, _in);
		// Agrega una estadistica relacionado al estado
        mall_add_stat(_key + _in);
    }
	#endregion
    
	// Añadir a la base de datos
	array_push(global.__mall_states_master, _key);
	global.__mall_states_prefix[$ _key] = _prefix;
}