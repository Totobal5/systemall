/// @param {Array} array_index	Array para agregar datos	
/// @param {Mixed} [...]		Datos para agregar
/// @desc Agrega dato(s) al inicio del array.
function array_sneak(_array) {
	var i=0; repeat(argument_count)	{
		array_insert(_array, 0, argument[i++] );
	}
}