/// @description [DESACTIVATE]
#region Afuera de pantalla
if (outsideCheck) {
	var _check = inRegion(0, 0, display_get_gui_width(), display_get_gui_height() );
	// Afuera
	if (!isOutside) {
		if (_check) {
			outsideOut();
			isOutside = true;
		}
	}
	// Adentro
	else {
		if (!_check) {
			outsideIn();
			isOutside = false;
		}		
	}
}

alarm[10] = 15;