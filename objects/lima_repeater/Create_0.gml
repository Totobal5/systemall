/// @description [ELEMENTO QUE REPITE OTROS]
event_inherited();

#region PRIVATE
__is = LIMA_TYPE.REPEATER;
__parent = object_get_parent(object_index);

#endregion

#region VARIABLES
// Indice de los interactivos que crea
index = 0;
index_last = 0;

position = {
	x: repeats_x, 
	y: repeats_y
};

// Tiempo presionado
pressed = 0;

#endregion

#region METODOS

/// @param xpos
/// @param ypos
/// @param count
Execute = function(xpos, ypos, count) {return {x:0, y:0}; }
/// @param [number]
Advance = function(number) {
	index_last = index;
	index += number;
	// Limites
	if (index > repeats - 1) {index = 0; } else
	if (index < 0)			 {index = repeats - 1; }
}
/// @desc Se utiliza para obtener datos
Fetch = function() {}

Obtain = function() {
	if (!is_undefined(use) ) {repeats = array_length(use); } else 
	if ( is_struct(use) )	 {repeats = array_length(variable_struct_get_names(use) ); }
	else {
		switch (ds_grid) {
			default: repeats = 0;
		}	
	}
}

#endregion

if (__parent == lima_parent) event_user(0);