/// @param {Id.DsList}	id
/// @desc Elimina los valores identicos de una lista. Devuelve la cantidad de elementos eliminados
/// @return {Real}
function ds_list_delete_same(_list){
	if (!ds_exists(_list, ds_type_list) ) exit;

	var _size  = ds_list_size(_list);
	var _count = 0;	
		
	for (var i = 0; i < _size; ++i) 
	{
		var _value = _list[| i];
		// Comparar con los de adelante
		for (var j = i+1; j < _size - i; ++j) 
		{
			var _comp = _list[| j]; 
				
			if (_value == _comp) 
			{
				ds_list_delete(_list, i);
				_size--;
				_count++;
			}
		}
	}
	
	return (_count);
}