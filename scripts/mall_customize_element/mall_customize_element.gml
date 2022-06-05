/// @param {String} _key
/// @param {String} _produce_state
/// @param {Real}   _produce_probability
/// @returns {Struct.MallElement}
function mall_element_customize(_key, _produce_state, _produce_probability) {
    var _prefix  = mall_get_element_prefix(_key);
    var _element = mall_get_element(_key);
	
	// Agregar defaults    
	_element.addDefend(_key + MALL_ELEMENT_PREFIX_ATTACK);
	_element.addAttack(_key + MALL_ELEMENT_PREFIX_DEFEND);

    // Agregar que estado produce este elemento
    var i = 1; repeat ( (argument_count - 1) div 2) {
        _element.AddProduce(argument[i++], argument[i++] ); 
    }
    
    return (_element);
}