/// @desc Suscribe una función para que se ejecute cuando se publique un evento.
/// @param {String} event_key La llave del evento a escuchar (ej: "ON_ENTITY_DEFEATED").
/// @param {Function} callback La función a ejecutar. Recibirá un struct con los datos del evento.
function mall_broadcast_subscribe(_event_key, _callback)
{
    // Crear el array de listeners si no existe
    if (!variable_struct_exists(Systemall.__broadcast, _event_key))
    {
        Systemall.__broadcast[$ _event_key] = [];
    }
    
    // Añadir la función a la lista de listeners
    var _listeners = Systemall.__broadcast[$ _event_key];
    array_push(_listeners, _callback);
}

/// @desc Desuscribe una función de un evento.
/// @param {String} event_key La llave del evento.
/// @param {Function} callback La misma referencia de función que se usó para suscribirse.
function mall_broadcast_unsubscribe(_event_key, _callback)
{
    if (!variable_struct_exists(Systemall.__broadcast, _event_key) ) exit;
	
    var _listeners = Systemall.__broadcast[$ _event_key];
    var _index = array_get_index(_listeners, _callback);
        
    if (_index > -1) { array_delete(_listeners, _index, 1); }
}

/// @desc Publica un evento, ejecutando todas las funciones suscritas.
/// @param {String} event_key La llave del evento a publicar.
/// @param {Struct} [data] Un struct opcional con datos relevantes para el evento.
function mall_broadcast_post(_event_key, _data = {})
{
    if (!variable_struct_exists(Systemall.__broadcast, _event_key) ) exit;
	
    var _listeners = Systemall.__broadcast[$ _event_key];
        
    // Iterar sobre una copia para evitar problemas si un listener se desuscribe a sí mismo
    var _listeners_copy = [];
	array_copy(_listeners_copy, 0, _listeners, 0, array_length(_listeners) );
		
	var i=0; repeat(array_length(_listeners_copy) )
	{
        var _callback = _listeners_copy[i++];
		if (is_callable(_callback) ) { _callback(_data); }			
	}
}