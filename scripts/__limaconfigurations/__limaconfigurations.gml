/// SE DEFINEN ENUMS, MACROS, GLOBALES Y FUNCIONES TIPICAS
enum LIMA_TYPE {
    PARENT,
	REPEATER,
	FRAME,
	INTERACTIVE,
	SLIDER,
	TEXT,
	CHECKBOX,
    __SIZE__
}

enum LIMA_INPUT {
	UP, LEFT, DOWN, RIGHT, ACTION, EXIT
}

global.__lima_groups = [undefined];	// [0] = room
/// @param [_extra]
global.__lima_dummy_function = function(_extra) {};

global.__lima_templates_name  = {
	Select:		global.__lima_dummy_function,	// Seleccionado			(Active &  Focus)
	Deselect:	global.__lima_dummy_function,	// Deseleccionado		(Active & !Focus)
	Pointed:	global.__lima_dummy_function,	// Si es apuntado		(!Active &  Focus)
	Desactive:	global.__lima_dummy_function,	// Desactive			(!Active & !Focus)
	Change:		global.__lima_dummy_function,	// Cambio de valores
	
	Pressed:	global.__lima_dummy_function,	// Ejecutar al ser interactuado
	Release:	global.__lima_dummy_function	// Ejecutar al liberar interaccion
};
global.__lima_templates_index = ["Select", "Deselect", "Pointed", "Desactive", "Change", "Pressed", "Release"];

#macro lima_templates global.__lima_templates_name

/*
	case 0:	return selectUp;
	case 1: return selectLeft;
	case 2: return selectRight;
	case 3: return selectDown;
		
	isFocus = true  && isActive = true:		Select
	isFocus = false && isActive = true:		Deselect
	isFocus = true  && isActive = false:	Aim
	isFocus = false && isActive = false:	Desactive
*/

/// @param {Real} _type
/// @param [_extra1]
/// @param [_extra2]
/// @ignore
function __lima_initalize(_type, _extra1, _extra2) {
	/// @ignore
	__is = _type;
	/// @ignore
	__parent  = object_get_parent(object_index);
	/// @ignore
	__number  = instance_count;
	/// @ignore
	__numberId = name + string(__number);
	/// @ignore
	__extra1 = noone;
	/// @ignore
	__extra2 = noone;		
}