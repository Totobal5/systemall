/// @desc Subscribe a callback to a broadcast event.
/// @param {String} event_key Event key to listen for (for example "ON_ENTITY_DEFEATED").
/// @param {Function} callback Callable that receives the event payload.
function mall_broadcast_subscribe(_event_key, _callback)
{
	if (!is_callable(_callback) )
	{
		__mall_error($"Broadcast subscribe expects a callable callback for event '{_event_key}'.");
		exit;
	}

	// Create the listeners array if it does not exist.
	if (!struct_exists(__Systemall.__broadcast, _event_key) )
	{		
		__Systemall.__broadcast[$ _event_key] = [];
		if (__MALL_BROADCAST_ALERT) { __mall_alert($"Broadcast event '{_event_key}' did not exist and was created."); }
	}
	
	// Add callback to listeners list.
	var _listeners = __Systemall.__broadcast[$ _event_key];
	array_push(_listeners, _callback);
}

/// @desc Unsubscribe a callback from a broadcast event.
/// @param {String} event_key Event key.
/// @param {Function} callback The same callable reference used when subscribing.
function mall_broadcast_unsubscribe(_event_key, _callback)
{
	if (!struct_exists(__Systemall.__broadcast, _event_key) )
	{
		if (__MALL_BROADCAST_ALERT) { __mall_alert($"Broadcast event '{_event_key}' does not exist."); }
		exit;
	}
	
	var _listeners = __Systemall.__broadcast[$ _event_key];
	var _index = array_get_index(_listeners, _callback);
		
	if (_index > -1) { array_delete(_listeners, _index, 1); }
}

/// @desc Publish an event and execute all subscribed callbacks.
/// The callbacks are invoked in the context where they were defined.
/// @param {String} event_key Event key to publish.
/// @param {Struct} [data={}] Optional payload struct.
function mall_broadcast_post(_event_key, _data = {})
{
	// Posting to an event with no listeners is a valid no-op.
	if (!struct_exists(__Systemall.__broadcast, _event_key) )
	{
		if (__MALL_BROADCAST_ALERT) { __mall_alert($"Broadcast event '{_event_key}' has no listeners."); }
		exit;
	}
	
	var _listeners = __Systemall.__broadcast[$ _event_key];
	
	// Iterate on a copy to avoid mutation issues if listeners unsubscribe during dispatch.
	var _listeners_copy = [];
	array_copy(_listeners_copy, 0, _listeners, 0, array_length(_listeners) );
	
	var i=0; repeat(array_length(_listeners_copy) )
	{
		var _callback = _listeners_copy[i++];
		if (is_callable(_callback) ) { method_call(_callback, [_data]); }
	}
}

/// @desc Add a new message to the queue.
/// The end-user is responsible for deciding how queued messages are displayed.
/// @param {String|Array<String>} text Message text.
function mall_message_add(_text)
{
	array_push(__Systemall.__messages, _text);
}

/// @desc Get and remove the next message from the queue.
/// @return {String|Undefined} The oldest message, or undefined if the queue is empty.
function mall_message_get_next()
{
	if (mall_message_is_empty() ) { return undefined; }
	
	var _message = __Systemall.__messages;
	return array_pop(_message);
}

/// @desc Check whether the message queue is empty.
/// @return {Bool}
function mall_message_is_empty()
{
	return (array_length(__Systemall.__messages) == 0);
}

/// @desc Remove all queued messages.
function mall_message_clear()
{
	__Systemall.__messages = [];
}