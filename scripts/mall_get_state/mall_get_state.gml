/// @param {String} state_key
/// @desc Obtiene el estado en el grupo actual
/// @return {Struct.MallState}
function mall_get_state(_KEY)
{
	return (global.__mallStatesMaster[$ _KEY] );
}