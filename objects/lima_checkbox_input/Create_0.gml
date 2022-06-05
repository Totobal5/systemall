/// @description [CHECKBOX]
#region PRIVATE
event_inherited();

__lima_initalize(LIMA_TYPE.CHECKBOX);

#endregion


#region METHODS
/// @desc Función a ejecutar cada tiempo
onCheck  = function() {}

offCheck = function() {}

#endregion



if (__parent == lima_button_input) event_user(0);