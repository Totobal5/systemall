/// @param {Real} _repeats	Repeticiones
/// @desc Establece letras al azar
function string_random_letter(_repeats) {
	var _letter1 = irandom_range(65,  90);
	var _letter2 = irandom_range(97, 122);
	
	var _txt = ""; repeat(_repeats) {
		_txt += chr(choose(_letter1, _letter2) );		
	}
	return _txt;
}