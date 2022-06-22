/// @param {String} element_key
/// @param [prefix_keys]
/// @desc Crea un elemento y agrega estadistica al storage en base a este, mediante prefijos para trabajar con ellos
function mall_add_element(_key) 
{
    var _prefix = [MALL_ELEMENT_PREFIX_ATTACK, MALL_ELEMENT_PREFIX_DEFEND];
    // Agregar estadisticas default
	mall_add_stat(_key + MALL_ELEMENT_PREFIX_ATTACK);
	mall_add_stat(_key + MALL_ELEMENT_PREFIX_DEFEND);
	
	#region Agregar estadisticas extras
    var i=1; repeat(argument_count - 1) 
	{
        var _in = argument[i++];    
            
        // Guardar los prefijos de elemento    
        array_push(_prefix, _in);
		// Agrega una estadistica relacionado al elemento
        mall_add_stat(_key + _in);
    }
    #endregion
	
    // Añadir a la base de datos
	array_push(global.__mall_elements_master, _key);
	global.__mall_elements_prefix[$ _key] = _prefix;
}