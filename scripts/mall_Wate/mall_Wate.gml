#region TEMPLATES
/// @desc Crea un template de batalla
/// @param {String}   key       llave de la plantilla de combate
/// @param {Function} template  funcion a ejecutar
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

/// @param {String} key llave de la plantilla de combate
function wate_template_get(_key)
{
    return (Systemall.wate[$ _key] );
}

#endregion

#region MESSAGES
/// @param message
function wate_message_send(_msg)
{
    // Enviar mensaje
    array_push(Systemall.messages, _msg);
}

/// @desc Limpia todos los mensajes.
function wate_message_clean()
{
    Systemall.messages = [];
    Systemall.mcurrent = undefined;
}

/// @param {Function} [function]
function wate_message_dispatch(_fn)
{
    var _message = array_shift(Systemall.messages);
    Systemall.mcurrent = {
        msg:    (is_callable(_fn) ) ? _fn(_message) : _message,
        ready:  false,
    }
    
    return Systemall.mcurrent;
}

/// @return {Any}
function wate_message_get()
{
	return Systemall.mcurrent;
}

/// @desc Establece el mensaje actual como ready.
function wate_message_set_ready()
{
    if (Systemall.mcurrent != undefined) {
        Systemall.mcurrent.ready = true;
    }
}

/// @return {Bool}
function wate_message_is_ready()
{
    if (Systemall.mcurrent != undefined) {
        return Systemall.mcurrent.ready;
    }
}

#endregion