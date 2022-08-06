/// @param {String}	state_key
/// @desc Donde se guardan las propiedades de los estados
function MallState(_KEY) : MallComponent(_KEY) constructor 
{
	#region PRIVATE
	__initial = false;	// Valor inicial siempre boleano
	__limits = -1;		// Cuantos se pueden agregar en party. -1 para infinitos (NO PUEDE SER 0)
	__same = false;		// Si acepta el mismo efecto varias veces
	
	__probability = 0;	// Probabilidad default

	__checkAtack  = function() {};
	__checkDefend = function() {};

		#region Callbacks
	/// @param {String}	[flag]
	/// @return {String}
    __startCallback  = function(_FLAG="") {return __key; };  // Funcion a usar cuando se inicia el estado
	
	__updateCallback = {
		/// @param {String}	[flag]
		/// @return {String}
		onStart:	function(_FLAG="") {return __key; },	// Al iniciar turno
		
		/// @param {String}	[flag]
		/// @return {String}		
		onFinish:	function(_FLAG="") {return __key; },	// Al terminar turno
		
		/// @param {String}	[flag]
		/// @return {String}
		onCombat:	function(_FLAG="") {return __key; },	// Al intentar actuar (todo lo que se indique que es combate)
		
		/// @param {String}	[flag]
		/// @return {String}
		onObject:	function(_FLAG="") {return __key; }	// Al intentar actuar (todo lo que se indique que no es combate)
	}

	/// @param {String}	[flag]
	/// @return {String}
    __finishCallback = function(_FLAG="") {return __key; }; // Funcion a usar cuando se finaliza el estado
    
    // Mensajes
	__message = {
		noSet: ""
	};
	
	#endregion
	
	#endregion

    #region METHODS
	
	/// @param	{Bool}	initial_bool
	/// @param	{Real}	[limit]	
	/// @desc Establece el valor inicial y el limite de este mismo estado (-1 es infinitos)
	static basic = function(_BOOL, _LIMIT=-1)
	{
		__initial =  _BOOL;
		__limits  = _LIMIT;
		return self;
	}
	
    /// @param {String}	message_key
	/// @param {String}	message
	/// @desc Permite almacenar llaves para los mensajes
    static addMessage = function(_KEY, _MSG) 
	{
		__message[$ _KEY] = _MSG;
        return self;    
    }

	/// @param	{Function}	start_callback
	static setStart  = function(_START)
	{
		__startCallback  = _start  ?? __startCallback;	
		return self;
	}
	
	/// @param	{String}	update_key onStart, onEnd, onCombat, onObject
	/// @param  {Function}	method 
	static setUpdate = function(_UPDATE_KEY, _METHOD)
	{
		__updateCallback[$ _UPDATE_KEY] = _METHOD;
		return self;
	}

	/// @param	{Function}	end_callback
	static setEnd = function(_END)
	{
		__endCallback = _end ?? __endCallback;
		return self;
	}
	
    #endregion
}


