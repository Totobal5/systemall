/// @param	{String}		part_key
/// @param	{Array<Bool>}	number		Cantidad de estas partes y su valor inicial EJ: [true, false, false] 
/// @param	{Real}			equip_max	
/// @returns {MallPart}
function mall_customize_part(_key, _number, _equip = 1) {
    var _part = mall_get_part(_key);
    
    // Copiar nuevos valores iniciales para cada numero
    if (is_array(_number) ) {
        // Copiar activos y cantidad de mismas partes
        var _len = array_length(_number);
        
        array_copy(_part.active, 0, _number, 0, _len);
        _part.__numbers = _len;
    } else {    // 1 solo valor sin array 
        var _temp = _number ?? true;
        
        _part.__active  = array_create(1,_temp);
        _part.__numbers = 1; 
    }
    
    _part.__equipMax = _equip;
    
    return (_part );
}

