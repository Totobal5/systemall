enum MZ {W, H, I}

/// @param {Real}	width	
/// @param {Real}	height	
/// @returns {Id.mz}
function mz_create(_w, _h) {
	return ([
		_w, 
		_h, 
		"mzins"
	]);	
}

/// @param {Id.mz} mz
/// @returns {Real}
function mz_w(_mz) {
	return _mz[0];
}

/// @param {Id.mz} mz
/// @returns {Real}
function mz_h(_mz) {
	return _mz[1];
}

/// @param {Id.mz} mz
/// @returns {Real}
function mz_area(_mz) {
	return (_mz[0] * _mz[1]);
}

/// @param {Id.mz} mz
/// @returns {Real}
function mz_perimeter(_mz) {
	return (_mz[0] * 2) + (_mz[1] * 2);
}