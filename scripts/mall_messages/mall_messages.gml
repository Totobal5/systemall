/**
 * Agrega un mensaje al sistema
 * @param {String} message_key Description
 * @param {String} message	Description
 */
function mall_message_add(_KEY, _MSG)
{
	if (!variable_struct_exists(global.__mallMessages, _KEY) )
	{
		global.__mallMessages[$ _KEY] = _MSG;
	}
}

/**
 * Obtiene un mensaje
 * @param {any*} _KEY Description
 */
function mall_message_get(_KEY)
{
	return (global.__mallMessages[$ _KEY] );
}

/**
 * obtiene un mensaje para pasarlo a una funcion y obtener un resultado
 * @param {any*} _KEY Description
 * @param {any*} _FUN Description
 * @param {any*} _PASS Description
 */
function mall_display_message(_KEY, _FUN, _PASS)
{
	static fun = function(_KEY, _MSG, _FLAGS) {
		return (_MSG);	
	}
	
	var _msg = mall_message_get(_KEY);
	if (!is_undefined(_FUN) ) {return fun(_KEY, _msg, _PASS); } else {return _FUN(_KEY, _msg, _PASS); }
}