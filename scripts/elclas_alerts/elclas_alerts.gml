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
/// @param {Enums.ALERTS_MODE} event_mode
/// @param {Function} event
/// @desc Basado en el sensor de temperatura TZN Series
function Alerts(_entity, _value_name, _set_value, _deviation_high, _deviation_low, _event_mode=ALERTS_MODE.ABS_HIGH, event) constructor 
{
	#region PRIVATE
	__entity = _entity;			// Entidad a seguir
	__valueName  = _value_name;	// Nombre de la variable
	__value = 0;				// Valor de la variable	
	
	__setValue = _set_value;	// Comparar a este valor
	__devH = _deviation_high;	// Limites arriba
	__devL = _deviation_low;	// Limites abajo
	
	__eventMode = _event_mode;
	__event = event ?? __nofun__;
	
	__time = undefined;
	#endregion
	
	#region PUBLIC
	trigger = false;
	
	#endregion
	
	#region METHODS
	static work = function() 
	{
		// Obtener valor desde la entidad
		__value = checkValue();
		
		switch (__eventMode) 
		{
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
	static checkValue = function() 
	{
		if (is_struct(__entity) ) {
			return (variable_struct_get(__entity, __valueName) );
		}
		else if (instance_exists(__entity) ) {
			return (variable_instance_get(__entity, __valueName) );
		}
	}
	
	/// @return {Bool}
	static isTriggered = function()
	{
		return (trigger); 	
	}
	
	/// @ignore
	static __nofun__ = function() {}
	
	#endregion
	
	// -- Crear time_source
	__time = time_source_create(time_source_game, 1, time_source_units_frames, work, [], -1);
	time_source_start(__time);
}