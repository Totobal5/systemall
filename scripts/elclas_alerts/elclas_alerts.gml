enum ALERTS_MODE {
	DEV_H,		// Deviation High
	DEV_L,		// Deviation Low
	DEV_HL,		// Deviation High-Low
	DEV_HLR,	// Deviation High-Low Reverse	
	ABS_HIGH,	// Absolute High
	ABS_LOW		// Absolute Low
}

/// @param entity
/// @param {String} value_name
/// @param {Real} set_value
/// @param {Real} deviation_high
/// @param {Real} deviation_low
/// @param {ALERTS_MODE} event_mode
/// @param {Function} event
/// @desc Basado en el sensor de temperatura TZN Series
function Alerts(entity, value_name, set_value, deviation_high, deviation_low, event_mode=ALERTS_MODE.ABS_HIGH, event) constructor {
	#region PRIVATE
	__entity = entity; // Entidad a seguir
	__valueName  = value_name;	// Nombre de la variable
	__value = 0;		// Valor de la variable	
	
	__setValue = set_value;		// Comparar a este valor
	__devH = deviation_high;	// Limites arriba
	__devL = deviation_low;		// Limites abajo
	
	__event   = event ?? function() {};
	__eventMode = event_mode;
	
	__time = undefined;
	#endregion
	
	#region PUBLIC
	trigger = false;
	
	#endregion
	
	#region METHODS
	static work = function() {
		__value = checkValue();
		
		switch (__eventMode) {
			case ALERTS_MODE.DEV_H:
				#region Deviation High
				if (__value - __setValue > __devH) {
					trigger = true;
					__event();
				}
				else trigger = false;
				#endregion				
				break;
			
			case ALERTS_MODE.DEV_L:
				#region Deviation Low
				if (__value - __setValue < __devL) {
					trigger = true;
					__event();
				} else trigger = false;
				#endregion
				break;
				
			case ALERTS_MODE.DEV_HL:
				#region Deviation High-Low
				var _temp = __value - __setValue;
				if (_temp > __devH && _temp < __devL) {
					trigger = true;
					__event();
				} else trigger = false;
				#endregion
				break;
				
			case ALERTS_MODE.DEV_HLR:
				#region Deviation High-Low Reverse
				var _temp = __value - __setValue;
				if (!(_temp > __devH && _temp < __devL) ) {
					trigger = true;
					__event();
				} else trigger = false;				
				#endregion
				break;
				
			case ALERTS_MODE.ABS_HIGH:
				#region Absolute High
				if (__value > __setValue) {
					trigger = true;
					__event();
				} else trigger = false;
				
				#endregion
				break;
				
			case ALERTS_MODE.ABS_LOW:
				#region Absolute Low
				if (__value < __setValue) {
					trigger = true;
					__event();
				} else trigger = false;
				
				#endregion
				break;
		}
	}
	
	/// @desc Obtiene el valor
	/// @returns {Real}
	static checkValue = function() {
		if (is_struct(__entity) ) {
				
		}
		else if (instance_exists(__entity) ) {
			return (__entity[$ __valueName] );
		}
	}
	
	#endregion
	
	// -- Crear time_source
	__time = time_source_create(time_source_global, 1, time_source_units_frames, work, 1, time_source_expire_after);
	time_source_start(__time);
}