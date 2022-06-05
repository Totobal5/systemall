/// @param halign
/// @returns {string}
function string_from_halign(_h) {
	switch (_h) {
		case fa_left :	return "fa_left";	break;
		case fa_right:	return "fa_right";	break;
		case fa_center: return "fa_center";	break;	
	}
}

/// @param valign
/// @returns {string}
function string_from_valign(_v) {
	switch (_v) {
		case fa_top:		return "fa_top";		break;
		case fa_bottom:		return "fa_bottom";		break;
		case fa_middle:		return "fa_middle";		break;
	}
}

/// @param {string} halign
/// @returns {number}
function string_to_halign(_h) {
	switch (_h) {
		case "fa_left" :	return fa_left;		break;
		case "fa_right":	return fa_right;	break;
		case "fa_center":	return fa_center;	break;	
	}	
}

/// @param {string} valign
/// @returns {number}
function string_to_valign(_v) {
	switch (_v) {
		case "fa_top":		return fa_top;		break;
		case "fa_bottom":	return fa_bottom;	break;
		case "fa_middle":	return fa_middle;	break;
	}
}
