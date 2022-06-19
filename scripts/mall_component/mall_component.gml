/// @param {String} component_key
/// @desc Crea componente de Mall (sistema RPG)
/// @return {Struct.MallComponent}
function MallComponent(_key="") constructor 
{
    #region PRIVATE	
	/// @ignore
	__is = instanceof(self);
	
	/// @ignore
    __key  = _key;	// Llave propia
	
	/// @ignore
    __from =   "";	// Llave de a quien pertenece	
	
    // -- Display
	__display = true;				// Mostrar este valor
	__displayKey = __key;			// Llave para usar en lexicon
	__displayMethod = _nofundisp_;	// Función para mostrar valor

	#endregion

    #region METHODS
	/// @param {String} key			Llave propia
	/// @param {String} [from_key]	De quien proviene
	/// @return {Struct.MallComponent}
	static setKey = function(_key, _key_from="") 
	{
		__key  = _key;
		__from = _key_from;
		
		return self;
	}

	/// @param	{Bool}		use_display
	/// @param	{String}	display_key
	/// @param	{Function}	display_method	function() {return string; }
	static setDisplay = function(_display=true, _display_key, _display_method)
	{
		__display = _display;
		if (is_method(_display_method) ) 
		{
			__displayKey	= _display_key;
			__displayMethod = method(undefined, _display_method);
		}
		return self;
	}
	
	/// @desc Regresa el texto de display
	/// @return {String}
	static getDisplay = function()
	{
		return (__display) ? __displayMethod() : __key;	
	}
	
	/// @ignore
	static _nofundisp_ = function() {return ""; }
	
	#endregion
}