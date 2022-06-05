/// @param _object
/// @param _direction
/// @param _distance
/// @desc Detecta objetos en una direccion y devuelve una lista con los que encontró
/// @return {Array<Mixed>}
function instance_detect(_object, _direction, _distance) {
	static list = ds_list_create();
	
	var _len = -1;
	var _xOff = abs(sprite_xoffset - (sprite_width  / 2) );
	var _yOff = abs(sprite_yoffset - (sprite_height / 2) );
	
	// Dependiendo de la direccion
	switch(_direction) {
		case 0:
			_len = collision_line_list(x + _xOff, y - _yOff, x + (_xOff + _distance), y - _yOff, _object, false, true, list, true);
			break;
		
		case 90:
			_len = collision_line_list(x + _xOff, y - _yOff, x + _xOff, y - (_xOff + _distance), _object, false, true, list, true);
			break;
		
		case 180:
			_len = collision_line_list(x + _xOff, y - _yOff, x - (_xOff + _distance), y - _yOff, _object, false, true, list, true);
			break;
		
		case 270:
			_len = collision_line_list(x + _xOff, y - _yOff, x + _xOff, y + (_yOff - _distance) , _object, false, true, list, true);
			break;

		default: 
			show_error("instance_detect directions Error", false); 
			break;
	}

	return [list, _len];
}