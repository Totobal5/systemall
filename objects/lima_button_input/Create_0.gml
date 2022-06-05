/// @description [INTERACTIVO]
#region PRIVATE
event_inherited();

__lima_initalize(LIMA_TYPE.INTERACTIVE);
/// @type {Array<Real>}
__delayKeys = [];
array_copy(__delayKeys, 0, delayKeys, 0, 5);

#endregion

#region PUBLIC
// Seleccion vertical o horizontal (Se utiliza en repeater)
directionRepeat = false;	// 1 vertical 0 horizontal 

number = 0;
numberLast = number - 1;

#endregion

#region METHODS
/// @desc Template para interactivos (Select, Deselect, Aim, Desactive)
updateTemplate = function() {
	if (isActive) {
		if (isFocus) {
			if (templatesActual != "Select") {
				lima_template_execute("Select");	 
				templatesActual = "Select";
			}
		}
		else {
			if (templatesActual != "Deselect") {
				lima_template_execute("Deselect"); 
				templatesActual = "Deselect";
			}
		}	
	}
	else {
		if (isFocus) {
			if (templatesActual != "Aim") {
				lima_template_execute("Aim");
				templatesActual = "Aim";
			}
		}
		else {
			if (templatesActual != "Desactive") {
				lima_template_execute("Desactive"); 
				templatesActual = "Desactive";
			}
		}
	}
}

pressUp		= function(_number=0) {lima_swap_focus(_number); }
releaseUp	= global.__lima_dummy_function;

pressLeft	= function(_number) {lima_swap_focus(1); }
releaseLeft = global.__lima_dummy_function;

pressRight	 = function(_number) {lima_swap_focus(2); }
releaseRight = global.__lima_dummy_function;

pressDown	 = function(_number) {lima_swap_focus(3); }
releaseDown  = global.__lima_dummy_function;

pressAction	  = function(_number) {};
releaseAction = global.__lima_dummy_function;

#endregion

if (__parent == lima_parent) event_user(0);