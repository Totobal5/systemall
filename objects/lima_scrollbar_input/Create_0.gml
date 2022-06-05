/// @description [SCROLLBAR]
#region PRIVATE
event_inherited();

__stepsTime = stepsTime;

#endregion

#region PUBLIC
scrollHold = 0;
scrollX = x;
scrollY = y;

elements = [];

#endregion

#region METHODS
makeSlide = function() {
	static timer = 0;
	
}

reorganize = function() {
	elements = undefined;
	if (is_array(pointer) ) {
		var _len = array_length(pointer);
		elements = array_create(_len);
	}
	else if (is_struct(pointer) ) {
		var _len = variable_struct_get_names(pointer);
		elements = array_create(_len);
	}
	
	var i=0; repeat(_len) elements[i] = pointer[i++];
}

pressExit	= function(_number) {}
releaseExit = function(_number) {}

scroll = function(_value) {
	#region Control
	var _len = array_length(elements);
	switch (scrollMode) {
		case "Clip":
			number = clip (number + _value, 0, _len);
		break;
		
		case "Clamp":
			number = clamp(number + _value, 0, array_length(elements) );
		break;
	}
	// Limite del ultimo
	if (number == 0) {numberLast = _len; } else {numberLast = number - 1; }
	#endregion
	
	#region Instancias Lima
	if (array_empty(elements) ) exit;
	
	var _aIns = elements[number], _lIns = elements[numberLast];
	
	if (instance_exists(_aIns) ) _lIns.isFocus = false;
	if (instance_exists(_lIns) ) _aIns.isFocus =  true;
	
	#endregion
}


#endregion

if (__parent == lima_button_input) event_user(0);