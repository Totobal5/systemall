/// @desc Subscribes a callback to a broadcast event.
/// @param {String} _event_key Event key to listen to (for example "ON_ENTITY_DEFEATED").
/// @param {Function} _callback Callable to execute with event payload.
function mall_broadcast_subscribe(_event_key, _callback)
{
    if (!is_callable(_callback))
    {
		__mall_error($"Broadcast subscribe expects a callable callback for event '{_event_key}'.");
		exit;
	}

    // Create listeners array if it does not exist.
    if (!struct_exists(__Systemall.__broadcast, _event_key) )
    {		
        __Systemall.__broadcast[$ _event_key] = [];
		__mall_alert($"Broadcast event '{_event_key}' did not exist and was created.");
    }
    
    // Add callback to listeners list.
    var _listeners = __Systemall.__broadcast[$ _event_key];
    array_push(_listeners, _callback);
}

/// @desc Unsubscribes a callback from an event.
/// @param {String} _event_key Event key.
/// @param {Function} _callback Same callable reference used in subscribe.
function mall_broadcast_unsubscribe(_event_key, _callback)
{
    if (!struct_exists(__Systemall.__broadcast, _event_key) )
	{
		__mall_alert($"Broadcast event '{_event_key}' does not exist.");
		exit;
	}
	
    var _listeners = __Systemall.__broadcast[$ _event_key];
    var _index = array_get_index(_listeners, _callback);
        
    if (_index > -1) { array_delete(_listeners, _index, 1); }
}

/// @desc Publishes an event and executes all subscribed callbacks.
/// @param {String} _event_key Event key to publish.
/// @param {Struct} [_data={}] Optional payload struct.
function mall_broadcast_post(_event_key, _data = {})
{
    if (!struct_exists(__Systemall.__broadcast, _event_key) )
	{
        // Posting to an event with no listeners is a valid no-op for runtime/test flows.
        if (__MALL_BROADCAST_ALERT) { __mall_alert($"Broadcast event '{_event_key}' has no listeners."); }
        exit;
	}
	
    var _listeners = __Systemall.__broadcast[$ _event_key];
        
    // Iterate on a copy to avoid mutation issues if listeners unsubscribe during dispatch.
    var _listeners_copy = [];
	array_copy(_listeners_copy, 0, _listeners, 0, array_length(_listeners) );
	
	var i=0; repeat(array_length(_listeners_copy) )
	{
        var _callback = _listeners_copy[ i++ ];
		if (is_callable(_callback) ) { method_call(_callback, [_data]); }
	}
}

/// @desc Adds a new message to the UI queue.
/// @param {String} _text Message text.
/// @param {Constant.Color} [_color=c_white] Text color.
/// @param {Asset.Sprite} [_icon=undefined] Optional message icon.
function mall_message_add(_text, _color = c_white, _icon = undefined)
{
    var _message = new MallBroadcastMessage(_text, _color, _icon);
    array_push(__Systemall.__messages, _message);
}

/// @desc Gets and removes the next message from the queue.
/// @return {Struct.MallBroadcastMessage|Undefined} Oldest message, or undefined if queue is empty.
function mall_message_get_next()
{
    if (mall_message_is_empty() )
    {
        return undefined;
    }
    
    var _message = __Systemall.__messages[0];
    array_delete(__Systemall.__messages, 0, 1);
    
    return _message;
}

/// @desc Checks whether the message queue is empty.
/// @return {Bool}
function mall_message_is_empty()
{
    return (array_length(__Systemall.__messages) == 0);
}

/// @desc Removes all queued messages.
function mall_message_clear()
{
    __Systemall.__messages = [];
}