/**
 * Function Description
 * @param {string} message 
 */
function mall_message_send(_MSG)
{
	static enqueueID = MallDatabase.messages;
	// Enviar mensaje
	ds_queue_enqueue(enqueueID, _MSG);
}

/**
 * Function Description
 * @param   {Function} [dispatch_method] Description
 * @returns {string} Description
 */
function mall_message_dispatch(_FUN)
{
	static enqueueID = MallDatabase.messages;
	var _msg = ds_queue_dequeue(enqueueID);
	return (!is_method(_FUN) ) ? (_msg) : _FUN(_msg);
}

function mall_get_message()
{
	return MallDatabase.messages;
}