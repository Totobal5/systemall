/// @param {Real} _repeats	Repeticiones
/// @desc Establece caracteres al azar
function string_random_symbol(_repeats) {
	var _sym1 = irandom_range(32, 47);		// !"#$%&'()*+,-./
	var _sym2 = irandom_range(58, 64);		// :;<=>?@
	
	var _txt = ""; repeat(_repeats) {
		_txt += chr(choose(_sym1, _sym2) );
	}
	return _txt;
}