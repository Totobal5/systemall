/// @param	{String} _key	Llaves
/// @desc	Crear un (o varios) partes globalmente
function mall_add_part(_key) {
	var i=0; repeat(argument_count) {
		array_push(global.__mall_parts_master, argument[i++] );
	}	
}