/// @param {Real} _type
/// @param {Real} _value
/// @param {Real} _div
/// @param {Bool} _unique
function __PartyControlAtom(_type, _value, _div, _unique=false) constructor {
	type = _type;	// Tipo de estadistica
	init = _value;	// Valor al que reinicia
	use  =  false;	/// Si esta siendo afectado
	update = [_value, _div, false]; // Valores que varian en el tiempo [real, percentual, booleano]
	same   = false;					// Si acepta el mismo control varias veces
	
	box = (_unique) ? undefined : []; 	
}