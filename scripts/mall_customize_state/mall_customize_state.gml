/// @param {String}	state_key
/// @param {Real}	start_value
/// @param numtype
/// @returns {Struct.MallState}
function mall_customize_state(_key, _init, _numtype=NUMTYPE.BOOLEAN) {
    var _state = mall_get_state(_key);
    
	_state.__init    = numtype(_init, _numtype);
	_state.__compare = numtype(_init, _numtype);
    
    // Estadistica default que lo defiende [0]
    _state.setResists (_key + MALL_STATE_PREFIX_DEFEND);
	_state.SetAffected(_key + MALL_STATE_PREFIX_ATTACK);
	
    return (_state);
}