/// @description [FOLLOW LAYER]
if (followLayer) {
	var _x = round(layer_get_x(layer) );
	var _y = round(layer_get_y(layer) );		
	
	if (layerX != _x) {x = startX + _x; }
	if (layerY != _y) {y = startY + _y; }
}