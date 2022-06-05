/// @param {Real} x	Componente horizontal a comprobar
/// @param {Real} y	Componente vertical a comprobar
/// @param {Real} left		x1
/// @param {Real} top		y1
/// @param {Real} right		x2
/// @param {Real} bottom	y2
/// @desc Comprueba si unas cordenadas se encuentran entre un rango establecido (Forma rectangular)
/// @return {Bool}
function is_here(_x, _y, _x1, _y1, _x2, _y2) {
	return ((_x > _x1) && (_x < _x2) && (_y > _y1) && (_y < _y2) );
}