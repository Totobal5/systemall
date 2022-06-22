/// @param {String}	state_key
/// @desc Donde se guardan las propiedades de los estados
function MallState(_key) : MallComponent(_key) constructor 
{
	#region PRIVATE
	__initial = false;	// Valor inicial siempre boleano
	__limits = -1;		// Cuantos se pueden agregar en party. -1 para infinitos (NO PUEDE SER 0)

		#region Callbacks
	// function() {return "string"; }
    __startCallback  = __nousestate__;  // Funcion a usar cuando se inicia el estado
    __updateCallback = __nousestate__;  // Funcion a usar cuando se actualiza el estado
    __endCallback    = __nousestate__;  // Funcion a usar cuando se finaliza el estado
    
    // Mensajes
    __messages = [];
	
	#endregion
	
	#endregion

    #region METHODS
	
	/// @param	{Boolean}	boolean
	/// @param	{Real}		[limit]	
	/// @desc Establece el valor inicial y el limite de este mismo estado (-1 es infinitos)
	static basic = function(_boolean, _limit=-1)
	{
		__initial = _boolean;
		__limits  = _limit;
		return self;
	}
	
    /// @param {String}	message
	/// @param {String}	[message..]
	/// @desc Permite almacenar llaves para los mensajes
    static addMessages = function() 
	{
        var i=0; repeat(argument_count) array_push(__msgKeys, argument[i++] );
        return self;    
    }
    
	/// @param	{Function}	start_callback
	/// @param	{Function}	update_callback
	/// @param	{Function}	end_callback
	static setCallback = function(_start, _update, _end)
	{
		__startCallback  = _start  ?? __startCallback;	
		__updateCallback = _update ?? __updateCallback;
		__endCallback = _end ?? __endCallback;
		return self;
	}
	
	/// @param	{Function}	start_callback
	static setCallbackStart  = function(_start)
	{
		__startCallback  = _start  ?? __startCallback;	
		return self;
	}
	
	/// @param	{Function}	update_callback
	static setCallbackUpdate = function(_update)
	{
		__updateCallback = _update ?? __updateCallback;
		return self;
	}

	/// @param	{Function}	end_callback
	static setCallbackEnd = function(_end)
	{
		__endCallback = _end ?? __endCallback;
		return self;
	}
	
	/// @ignore
	/// @return {String}
	static __nousestate__ = function()
	{
		return "";
	}	

    #endregion
}


