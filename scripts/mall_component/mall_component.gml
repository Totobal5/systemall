/// @param {String} component_key
/// @desc Crea componente de Mall (sistema RPG)
/// @return {Struct.MallComponent}
function MallComponent(_KEY="") constructor 
{
    #region PRIVATE	
	/// @ignore
	__is = instanceof(self);
	
	/// @ignore
    __key  = _KEY;	// Llave propia
	
	/// @ignore
    __from =   "";	// Llave de a quien pertenece	
	
    #region display (se implica que siempre se usa)
	/// @ignore
	__displayKey = _KEY;	// Llave para usar en lexicon
	/// @param {String}	[flag]
	/// @return {String}
	/// @ignore
	__displayMethod = function(_FLAG="") {return __key;};	// Función para mostrar valor
	
	#endregion

	#endregion

    #region METHODS
	/// @param {String} key			Llave propia
	/// @param {String} [from_key]	De quien proviene
	/// @return {Struct.MallComponent}
	static setKey = function(_KEY, _KEY_FROM="") 
	{
		__key  = _KEY;
		__from = _KEY_FROM;
		
		return self;
	}
	
	/// @param	{String}	display_key
	/// @param	{Function}	display_method	function() {return string; }
	static setDisplay = function(_DISPLAY_KEY, _DISPLAY_METHOD)
	{
		if (!is_method(_DISPLAY_METHOD) ) __mall_error("display_method tiene que ser method dah");
		
		__displayKey = _DISPLAY_KEY;
		
		/// @param {String}	[flag]
		/// @return {String}
		__displayMethod = _DISPLAY_METHOD;	// No pasar por method para no cargar tanto
	
		return self;
	}
	
	/// @desc Regresa el texto de display
	/// @param {String}	[flag]
	/// @return {String}
	static getDisplay = function(_FLAG)
	{
		return __displayMethod(_FLAG);
	}
	
	/// @desc Devuelve la llave del componente
	/// @return {String}
	static getKey = function()
	{
		return (__key);
	}

	#endregion
}