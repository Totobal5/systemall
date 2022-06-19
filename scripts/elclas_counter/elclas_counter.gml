/// @param {Real} min
/// @param {Real} max
/// @param {Real} [amount]
/// @param {Real} {type]
/// @param {Real} [iterate_time]
/// @param {Bool} [repeat]
/// @desc Devuelve un contador capaz de contar o iterar por ciclos.
/// @return {Struct.Counter}
function Counter(_min, _max, _amount=1, _type=false, _iterate_time=infinity, _repeat=false) constructor {
	#region PRIVATE
		#region Iniciales
	/// @ignore
	__initMax = _min;
	/// @ignore
	__initMin = _max;
	/// @ignore
	__initAmount = _amount;
	/// @ignore
	__initType   = _type;
	/// @ignore
	__initIterate = _iterate_time;
	/// @ignore
	__initRepeat  = _repeat;

	#endregion
	
	/// @ignore
	__min = _min;	// Minimo valor de la cuenta
	/// @ignore
	__max = _max;	// Maximo valor de la cuenta
	/* @ignore @type {Real} */
	__count  = _min;	// Valor de la cuenta
	/* @ignore @type {Real} */
	__amount = _amount; // Cada cuanto aumenta el valor de la cuenta
	/// @ignore
	__active = false;	// Si esta activo puede trabajar
	/* @ignore @type {Bool} */
	__type = _type;			// Tipo de iteracion Contador (True) o Adicion por ciclos (False)
	/// @ignore
	__repeat  =  _repeat;	// Si al terminar reinicia el valor de la cuenta
	/// @ignore
	__iterateTime = _iterate_time; // Cuantas iteracciones trabajará. infinity: indefinidamente
	
	#endregion
	
	#region METHODS
	
	/// @desc Trabajar el contador. Posee 2 modos que dependen: Contador o Adiccion por ciclos
	/// @return {Bool}
	static work = function() {
		return (!__type ? count() : iterate() );
	}
		
	/// @desc Trabajar como contador
	/// @return {Bool}
	static count = function() {
		if (!__active) return false;
	
		__count += __amount;
		
		if (__count >= __max) {
			if (__iterateTime > 1 || __iterateTime == infinity) {
				__active = __repeat;	// Si hay que repetir o no
				__count = __min * __repeat;	// Reiniciar contador si repite
				
				// Quitar iteraciones
				if (__iterateTime != infinity) __iterateTime--;
				return true;
			}
			else {
				__active = false;
				__iterateTime = 0;
			}
		}
		
		return false;
	}
	
	/// @desc Trabajar como adicion por ciclos
	/// @return {Bool}
	static iterate = function() {
		if (!__active) return false;
		
		if (__iterateTime >= 0 || __iterateTime == infinity) {
			__count += __amount;	
			if (__iterateTime != infinity) __iterateTime--;
			
			return true;
		}
		
		return false;
	}
	
	/// @param amount
	/// @param iterate_time
	/// @param [repeat]
	/// @return {Struct.Counter}
	static modify = function() {
		if (__type) {
			__amount = argument0;
			__iterateTime = argument1;
		}
		else {
			__amount = argument0;					
			__iterateTime = argument1;
			__repeat = argument2;	
		}
		
		return self;
	}
	
	/// @return {Real}
	static getCount = function() {
		return __count;	
	}
	
	/// @param {Real} min
	/// @param {Real} max
	/// @return {Struct.Counter}
	static setLimit = function(_min, _max) {
		__min = _min;
		__max = _max;
		return self;
	}
	
	/// @param {Real} [iterate_time]
	/// @return {Struct.Counter}
	static changeType = function(_iterate_time) {
		__type = !__type;
		__iterateTime = _iterate_time ?? __initIterate;
		
		return self;
	}
	
	/// @param {Bool} [active]
	/// @return {Struct.Counter}
	static activate = function(_active=true) {
		__active = _active;
		return self;
	}
	
	/// @return {Struct.Counter}
	static copy = function() {
		return (new Counter(__initMin, __initMax, __initAmount, __initType, __initIterate, __initRepeat) );
	}
		
	/// @return {String}
	static toString = function() {
		return ("min: "      + string(__min) + 
				"\nmax: "    + string(__max) + 
				"\ncount: "  + string(__count) + 
				"\nactive: " + string(__active)
		);
	}
	
	#endregion
}

/// @param {Struct.Counter} counter
/// @return {Bool}
function is_counter(_counter) {
	return (is_struct(_counter) && (instanceof(_counter) == "Counter") );
}