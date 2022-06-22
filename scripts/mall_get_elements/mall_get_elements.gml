/// @desc Devuelve todos las llaves de elemento
/// @return {Array<String>}
function mall_get_elements()
{
	return (global.__mall_elements_master);
}

/// @desc Devuelve una copia de todas las llaves los elemento creados
/// @return {Array<String>}
function mall_get_states_copy() 
{
	var __elements = mall_get_elements();
	var _array = [];
	
	array_copy(_array, 0, __elements, 0, array_length(__elements) );
	return _array;
}