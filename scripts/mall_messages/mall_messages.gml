/**
 * Function Description
 * @param {string} message 
 */
function mall_message_send(_MSG)
{
	// Enviar mensaje
	ds_queue_enqueue(global.__mallRadio, _MSG);
}

/**
 * Function Description
 * @param {Function} [dispatch_method] Description
 * @returns {string} Description
 */
function mall_message_dispatch(_FUN)
{
	var _msg = ds_queue_dequeue(global.__mallRadio);
	return (!is_method(_FUN) ) ? (_msg) : _FUN(_msg);
}