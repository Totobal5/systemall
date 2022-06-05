/// @param {Real} percent
/// @param {Mixed} winner_value	Si obtiene el porcentaje este valor es devuelto
/// @param {Mixed} loser_value	Valor si no se obtiene
/// @return {Mixed}
function percent_set(_percent, _winner, _loser) {
	return (percent_chance(_percent) ) ? _winner : _loser;
}