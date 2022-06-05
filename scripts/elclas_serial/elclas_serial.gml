#macro SERIAL_ACTIVE true

/// @param {String} message		%s
/// @param {String} [replace]
/// @desc Permite remplazar caracteres Ejemplo: print("Hola %s", playerName) -> "Hola Antonio"
function print(_message) {
	if (!SERIAL_ACTIVE) exit;
    var i=1; repeat(argument_count - 1) {
        _message = string_replace(_message, "%s", argument[i++] );    
    }
	
    show_debug_message(_message);	
}
	
/// @param {String} [message]
/// @param [...]
function log() {	
    if (!SERIAL_ACTIVE) exit;
        
	var _obj = "";
	var _id  = "";
		
	#region Quien llama
	if (is_struct(other) ) {
		_obj = string(instanceof(other) ); 
	} 
	else {
		if (other.id == 0) {
			_id  = "Room Creation Code"
			_obj = ""; 
		}
		else {
			_id = string(other.id);
			_obj = object_get_name(_id.object_index); 
		}
	}
    #endregion

	var _event = "";

	switch(event_type) {
		#region Obtener event_type
	    case ev_create:		_event = "create";		break;
	    case ev_destroy:	_event = "destroy";		break;
	    case ev_alarm:		_event = "alarm["+string(event_number)+"]";	break;
	
	
	    case ev_keyboard:	_event = "keyboard";		break;
	    case ev_keypress:	_event = "keypress";		break;
	    case ev_keyrelease: _event = "ev_keyrelease";	break;
	    case ev_mouse:		_event = "ev_mouse";		break;
	    case ev_collision:	_event = "ev_collision";	break;

	    case ev_step: 
	        switch (event_number) {
	            case ev_step_begin: _event = "begin ";	break;
	            case ev_step_end:	_event = "end ";	break;
	        }
	        _event += "step";
	    break;

		case ev_draw:
	        switch (event_number) {
	            case ev_draw_begin:		_event = "begin ";	break;
	            case ev_draw_end:		_event = "end ";	break;
	        }
	        _event += "draw";
	    break;
			
	    case ev_other:		_event = "ev_other";		break;
	    case ev_gesture:	_event = "ev_gesture";		break;
			
		#endregion
	}
		
	var _log = "[" + _obj + " - " + _id + " - " + _event + "]\n";
	
	// Argumentos
	if (argument_count < 2) {
		_log  += string(argument[0] );	
	}
	else {
		var i = 0; repeat( argument_count div 2) {
			var _one = argument[i], _two = argument[i + 1] ?? "";
			_log += string(_one) + ": " + string(_two) + "\n";	
		}
	}
		
	show_debug_message(_log);       	
}	

/// @desc Devuelve el tiempo que se demora una función en ejecutar
function show_debug_timer() {
	if (!SERIAL_ACTIVE) exit;
	
	static get = false;
	static timer1 = 0;
	static timer2 = 0;
	
	if (!get) {
		timer1 = get_timer(); 
		get = true;
	} else {
		timer2 = get_timer();
		
		show_debug_message("Timer: " + string((timer2 - timer1) / 1000 ) + " [ms]");
		get = false;
	}
}