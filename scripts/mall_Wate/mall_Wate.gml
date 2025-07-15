#region TEMPLATES
/// @desc Crea un template de batalla.
/// @param	{String}	template_key	Llave de la plantilla de combate.
/// @param	{Function}	template		Funcion a ejecutar.
function wate_template_create(_key, _fn)
{
    if (!struct_exists(Systemall.wate, _key) ) 
    {
        Systemall.wate[$ _key] = _fn;
        #region TRACE
        if (__MALL_WATE_TRACE) {show_debug_message($"M_Wate: template {_key} creada"); }
        #endregion
    }
}

/// @param	{String}	template_key	Llave de la plantilla de combate
function wate_template_get(_key)
{
    return (Systemall.wate[$ _key] );
}

#endregion

#region MESSAGES
/// @ignore
/// @param {Any*} message
function WateDispatch(_msg) constructor
{
    msg = _msg;
    ready = false;
}

/// @param	{Any}	message		Mensaje a enviar.
/// @param	{Bool}	[at_start]	Si agregar el mensaje al final o al comienzo.
function wate_message_send(_msg, _atstart = false)
{
	// Insertar mensaje al comienzo o al final.
	if (!_atstart) 
	{
		array_push(Systemall.messages, _msg);
	}
	else
	{
		array_insert(Systemall.messages, 0, _msg);
	}
}

/// @desc Limpia todos los mensajes.
function wate_message_clean()
{
    Systemall.messages = [];
    Systemall.mcurrent = undefined;
}

/// @param	{Function}	[function]
function wate_message_dispatch(_fn)
{
    var _message = array_shift(Systemall.messages);
    if (!is_undefined(_message) )
    {
		// Ejecutar un funcion al ejecutar.
        if (is_callable(_fn) ) _message = _fn(_message);
        // Crear nuevo dispatch.
        Systemall.mcurrent = new WateDispatch(_message);
        
		return (Systemall.mcurrent);
    }
    
    return undefined;
}

/// @return {Any}
function wate_message_get()
{
    return (Systemall.mcurrent);
}

/// @desc Establece el mensaje actual como ready.
function wate_message_set_ready()
{
    if (Systemall.mcurrent != undefined) 
    {
        Systemall.mcurrent.ready = true;
    }
}

/// @return {Bool}
function wate_message_is_ready()
{
    if (Systemall.mcurrent != undefined) 
    {
        return Systemall.mcurrent.ready;
    }
}

#endregion