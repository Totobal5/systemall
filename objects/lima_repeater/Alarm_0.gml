/// @description [EJECUTAR REPEAT]
if (!is_undefined(use) ) {
	if (is_array(use) ) {
		repeats = array_length(use);
	}
	else if (is_struct(use) ) {
		var _names = variable_struct_get_names(use);
		repeats = array_length(_names);	
	}
}

var i=0; repeat(repeats) {
	var _pos = Execute(position.x, position.y, i++);
	position.x += xoffset + _pos.x;
	position.y += yoffset + _pos.y;
}

// Reiniciar
position.x = repeats_x;
position.y = repeats_y;
	
// Asignar
var _active = creations.act
var _len = array_length(_active);
var i=0; repeat(array_length(_active) ) {
	var _ins = _active[i];
	with (_ins) {
		// Asegurar que sea un interactivo
		if (__extra1 == lima_button_input) {
			if (dir) {
				if (i==0) {
					select_up   = _active[_len - 1];
					select_down = _active[i + 1];
					isFocus = true;
				}
				else if (i == _len - 1) {
					select_up   = _active[i - 1];
					select_down = _active[0];
				}
				else {
					select_up   = _active[i - 1];
					select_down = _active[i + 1];
				}
			}
		}
	}
}

alarm[0] = -1;
