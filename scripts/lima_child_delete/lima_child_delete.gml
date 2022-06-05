/// @param {Real} [_index]		
/// @param {Real} [_number]	
/// @desc Entrega el tamaño del array de hijos luego de borrar
/// @return {Real}
function lima_child_delete(_index=0, _number=1) {
	array_delete(childrens, _index, _number);
	return (array_length(childrens) );
}