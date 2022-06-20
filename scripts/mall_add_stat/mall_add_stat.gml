/// @desc Crear un (o varios) stat globalmente
/// @param {String} stat_key
/// @param ...
function mall_add_stat() 
{
    var i=0; repeat(argument_count) {
		array_push(global.__mall_stats_master, argument[i++] );
	}
}