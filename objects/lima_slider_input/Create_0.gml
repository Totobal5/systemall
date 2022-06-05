/// @description [SLIDER]
#region PRIVATE
event_inherited();
__lima_initalize(LIMA_TYPE.SLIDER);

#endregion

#region PUBLIC
sliderW = (sliderSprite != -1) ? sprite_get_width(sliderSprite) : 1;
sliderH = (sliderSprite != -1) ? sprite_get_width(sliderSprite) : 1;

#endregion

#region METHOD
/// @param {Real} _value
/// @param {Real}  _type	0: Clamp. 1: Restart
/// @desc Aumenta los valores del slider
slide = function(_value, _type="Clamp") { 
	switch (_type) {
		case "Clamp":	slider = clamp(slider + _value, sliderMin, sliderMax);			break;
		case "Restart": slider = max  (sliderMin, min(sliderMax, slider + _value) );	break;
	}
	
	show_debug_message("Slide: " + string(slider) );
}

// Derecha e izquierda
if (isAxis) {
	pressRight = function() {slide( steps, stepsType); reorganize(); }
	pressLeft  = function() {slide(-steps, stepsType); reorganize(); }
}
// Arriba y abajo
else {
	pressUp   = function() {slide(-steps, stepsType); reorganize(); }
	pressDown = function() {slide( steps, stepsType); reorganize(); }	
}


#endregion

// Esperar al padre correcto
if (__parent == lima_button_input) event_user(0);