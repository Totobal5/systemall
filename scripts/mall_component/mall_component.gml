/// @desc Crea componente de Mall (sistema RPG)
/// @param {String} component_key
/// @return {Struct.MallComponent}
function MallComponent(_KEY="") constructor 
{
    #region PRIVATE
	__is = instanceof(self);

	#endregion
	
    key  = _KEY; // Llave propia
    from = weak_ref_create(self); // Referencia a otra estructura
	from = undefined;

	/// @param {String}	[flag]
	/// @return {String}
	displayMethod = function(_FLAG="") {return key;};	// Función para mostrar valor
	displayKey = _KEY; // Llave para usar en lexicon
	
	// -- Others
	messages = {
		noSet: ""
	};

	iterator = new __MallIterator();

    #region METHODS
	
	/**
	* Hereda ciertas propiedades de otro MallComponent
	* @param {String} component_key Description
	* @returns {struct} Description
	*/
	static inherit = function(_MALL)
	{
		displayMethod = _MALL.displayMethod;
		messages = _MALL.messages;
		return (self);
	}

	/// @param reference
	static setFrom = function(_ENTITY)
	{
		from = weak_ref_create(_ENTITY);
		return self;
	}
	
	/// @param {String} key	Llave propia
	static setKey = function(_KEY)
	{
		key = _KEY;
		return self;
	}
	
	/// @param	{String}	display_key
	/// @param	{Function}	display_method	function(flag) {return string; }
	static setDisplay = function(_DISPLAY_KEY, _DISPLAY_METHOD)
	{
		if (!is_method(_DISPLAY_METHOD) ) __mall_error("display_method tiene que ser method dah");
		
		/// @param {String}	[flag]
		/// @return {String}
		displayMethod = _DISPLAY_METHOD ?? displayMethod;	// No pasar por method para no cargar tanto
		displayKey = _DISPLAY_KEY;
		
		return self;
	}
	
	/// @param {String}	message_key
	/// @param {String}	message
	static addMessage = function(_KEY, _MESSAGE)
	{
		messages[$ _KEY] = _MESSAGE;
		return self;
	}

	/// @param {String}	message_key
	/// @return {String}
	static getMessage = function(_KEY)
	{
		return (messages[$ _KEY] );
	}

	/// @param {String}		message_key
	/// @param {Function}	message_function	function(MESSAGE, MESSAGE_KEY) {return string; }
	/// @return {String}
	static getMessageExt = function(_KEY, _FUN)
	{
		return (_FUN(messages[$ _KEY], _KEY) );
	}

	/// @desc Regresa el texto de display
	/// @return {Function}
	static getDisplay = function()
	{
		return (displayMethod );
	}

	/// @desc Devuelve la llave del componente
	/// @return {String}
	static getKey = function()
	{
		return (key);
	}

	#region Iterator
	/// @param {Bool} iterator_type
	static iterActivate = function(_TYPE)
	{
		iterator.active = true;
		iterator.type = _TYPE;
		return (self );
	}
	
	/**
	 * Function Description
	 * @param {any*} [_COUNT_LIMITS]=1 Description
	 * @param {any*} [_REPEAT]=true Description
	 * @param {any*} [_REPEAT_LIMITS]=-1 Description
	 * @returns {struct} Description
	 */
	static iterToMin = function(_COUNT_LIMITS=1, _REPEAT=true, _REPEAT_LIMITS=-1)
	{
		with (iterator)
		{	
			active = true;	type = false;
			count = 0;
			countLimits = _COUNT_LIMITS;
			
			reset = _REPEAT;
			resetCount	= 0;
			resetLimits	= _REPEAT_LIMITS;
		}
		
		return self;
	}

	/**
	 * Function Description
	 * @param {any*} [_COUNT_LIMITS]=1 Description
	 * @param {any*} [_REPEAT]=true Description
	 * @param {any*} [_REPEAT_LIMITS]=-1 Description
	 * @returns {struct} Description
	 */
	static iterToMax = function(_COUNT_LIMITS=1, _REPEAT=true, _REPEAT_LIMITS=-1) 
	{
		with (iterator)
		{	
			active = true; type = true;
			count = 0;
			countLimits = _COUNT_LIMITS;
			
			reset = _REPEAT;
			resetCount	= 0;
			resetLimits	= _REPEAT_LIMITS;
		}		
		
        return self;
    }
	
	/**
	 * Function Description
	 * @param {any*} _COUNT_LIMITS Description
	 * @param {any*} _REPEAT Description
	 * @param {any*} _REPEAT_LIMITS Description
	 * @param {any*} [_REPEAT_MAX]=-1 Description
	 */
	static iterConfigure = function(_COUNT_LIMITS, _REPEAT, _REPEAT_LIMITS, _REPEAT_MAX=-1)
	{
		with (iterator)
		{
			count = 0;
			countLimits = _COUNT_LIMITS;
			reset = _REPEAT;
			resetCount  = 0;
			resetLimits = _REPEAT_LIMITS;
			
			resetNumber = 0;
			resetMax = _REPEAT_MAX;
		}
		
		return self;
	}

	#endregion

	#endregion
}
  
/// @desc Iterador que utilizan algunos componentes mall
function __MallIterator(_ACTIVE=false) constructor
{
	active = _ACTIVE;
	type   = true;	// true: to min, false: to max
		
	// Cuenta
	count = 0;
	countLimits = 1;
	
	// Resets
	reset = false;	 // Si tiene un reset o no
	resetCount  = 0; // Veces que se ha reseteado
	resetLimits = 1; // Limite de resets
	
	resetNumber = 0;
	resetMax	= -1;
	
	#region METHODS

	/**
	 * -1 se ha desactivado, 0 aun no llega al limite de cuenta, 1 esta iterando para reiniciar, 2 se ha reiniciado
	 * @returns {real} Description
	 */
	static iterate = function()
	{
		// Si ya se cumplio el ciclo
		if (!active) return -1;
		
		count = count + 1;
		if (count > countLimits)
		{
			return 0;
		}
		else
		{
			return (restart() );
		}
	}	
		
	/// @desc Reinicia el iterador si puede, si no lo desactiva
	/// @returns {Real} Description
	static restart = function()
	{
		#region Se el iterador reinicia
		if (reset)
		{	
			#region Cuenta para el reinicio
			if (resetCount > 0)
			{
				if (resetCount < resetLimits) 
				{
					resetCount = resetCount + 1;
					return 1;
				}
				else
				{
					count  = 0;
					resetCount = 0;
					// Veces que puede reiniciar
					if (resetNumber > resetMax) {active = false; } else {resetNumber = resetNumber + 1; }

					return 2;
				}
			}
			#endregion
		}
		#endregion
		
		active = false;
		count  = 0;
		return -1;
	}
		
	/// @desc Devuelve si es toMin (true) o toMax (false)
	/// @returns {bool} Description
	static getType = function()
	{
		return (type);
	}
		
	/// @desc Devuelve si esta activo
	/// @returns {bool} Description
	static isActive = function()
	{
		return (active);
	}

	/**
	* Devuelve una copia del iterador
	* @returns {Struct.__MallIterator} Description
	*/
	static copy = function()
	{
		var _iterator = new __MallIterator();
		
		with (_iterator)
		{
			active = other.active;
			type   = other.type;	// true: to min, false: to max
		
			// Cuenta
			count = other.count;
			countLimits = other.countLimits;
	
			// Resets
			reset = other.reset;			 // Si tiene un reset o no
			resetCount  = other.resetCount;  // Veces que se ha reseteado
			resetLimits = other.resetLimits; // Limite de resets

			resetNumber = other.resetNumber;
			resetMax	= other.resetMax;

			return self;
		}
	}
	
	#endregion
}