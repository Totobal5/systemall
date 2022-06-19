/// @param {String}	pocket_key
/// @param {String}	event_key
function pocket_execute(_key, _event)
{
	return (pocket_get(_key).events[$ _event] () );
}