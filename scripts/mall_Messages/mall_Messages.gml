/// @desc Representa un mensaje para la cola de la UI.
/// @param {String} text El texto del mensaje.
/// @param {Constant.Color} [color]=c_white El color del texto.
/// @param {Asset.Sprite} [icon]=undefined Un ícono opcional para el mensaje.
function MallMessage(_text, _color = c_white, _icon = undefined) constructor
{
    text =	_text;
    color =	_color;
    icon =	_icon;
}

/// @desc Añade un nuevo mensaje a la cola de la UI.
/// @param {String} text El texto del mensaje.
/// @param {Constant.Color} [color]=c_white El color del texto.
/// @param {Asset.Sprite} [icon]=undefined Un ícono opcional para el mensaje.
function mall_message_add(_text, _color = c_white, _icon = undefined)
{
    var _message = new MallMessage(_text, _color, _icon);
    array_push(Systemall.__messages, _message);
}

/// @desc Obtiene y elimina el siguiente mensaje de la cola.
/// @return {Struct.MallBroadcastMessage} El mensaje más antiguo, o undefined si la cola está vacía.
function mall_message_get_next()
{
    if (mall_message_is_empty() ) return undefined;
	
    var _message = Systemall.__messages[0];
    array_delete(Systemall.__messages, 0, 1);
	
    return _message;
}

/// @desc Comprueba si la cola de mensajes está vacía.
/// @return {Bool}
function mall_message_is_empty()
{
    return (array_length(Systemall.__messages) == 0);
}

/// @desc Elimina todos los mensajes de la cola.
function mall_message_clear()
{
    Systemall.__messages = [];
}