/// @description [VARIABLES DE LIMA]
#region PRIVATE
__lima_initalize(LIMA_TYPE.PARENT);

#endregion

#region METODOS
/// @desc Indicar que realizar al intentar activar
enable = function() {}
/// @desc Indicar que realizar al intentar desactivar
desactivate = function() {}

/// @desc Funcion tipica para ejecutar acciones
execute = function(_arg) {}

/// @desc Funcion tipica al iniciar funciones
eventStart = global.__lima_dummy_function;
/// @desc Funcion tipica al finalizar funciones
eventEnd   = global.__lima_dummy_function;

/// @desc Reorganizar variables, funciones, templates, etc de un elemento lima.
reorganize = function() {}

/// @desc Template default presente es todos los elementos lima.
defaultTemplate = function() {}

/// @desc Logica para seleccionar un template
selectTemplate = function() {}

/// @desc Actualizar variables y funciones respecto al template actual
updateTemplate = function() {}

#region Tools
/// @param {Real} _x1
/// @param {Real} _y1
/// @param {Real} _x2
/// @param {Real} _y2
/// @return {Bool}
inRegion = function(_x1, _y1, _x2, _y2) {
	return (
		(x > _x1) && (x < _x2) &&
		(y > _y1) && (y < _y2)	
	);
}

/// @param {Real} _x1
/// @param {Real} _y1
/// @param {Real} _x2
/// @param {Real} _y2
/// @return {Bool}
inRegionBox = function(_x1, _y1, _x2, _y2) {
	return (
		(bbox_left > _x1) && (bbox_right  < _x2) &&
		(bbox_top  > _y1) && (bbox_bottom < _y2)	
	);
}

/// @param {Real} _x
/// @param {Real} [_y]
move = function(_x, _y=_x) {
	startX = x
	startY = y;
	
	x = _x;
	y = _y;
}

#endregion

outsideIn  = function() {}
outsideOut = function() {}
	
#endregion

#region VARIABLES
startX = xstart;
startY = ystart;

templates = {};
templatesActual = "";

childrens = []; // Hijos que tiene 
group = noone;  // Al grupo que pertenece
groupName = "";	// Nombre del grupo que pertenece

creator = noone;	// Quien es su creador
creations = {	// Creaciones
    vis: [],
    act: [],
    foc: [],
    evr: [],
}

// Relativo
relative = false;	// Bool o instance
relative_x = 0;
relative_y = 0;

// Para selecciones
dir = false;	// false arriba,abajo true: izquierda,derecha
vert = false;
horz = false;

// Para seguir a la layer
layerX = round(layer_get_x(layer) );
layerY = round(layer_get_y(layer) );

//  Propiedades
w = 0;
h = 0;

isOutside = !inRegion(0, 0, display_get_gui_width(), display_get_gui_height() );

#endregion

#region INICIAR
lima_template_initialize();

#endregion