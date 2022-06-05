/// @param {Real} _repeats	Repeticiones
/// @desc Establece caracteres y letras al azar
function string_random(_repeats=1) {
	var _txt = ""; repeat(_repeats) {
		var _symbol = string_random_symbol(1); 
		var _letter = string_random_letter(1);
		
		_txt += choose(_symbol, _letter);
	}
	
	return (_txt);
}