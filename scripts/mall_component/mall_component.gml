/// @param {String} _key
/// @desc Crea componente de Mall (sistema RPG)
/// @return {Struct.MallComponent}
function MallComponent(_key="") constructor {
    #region PRIVATE	
	/// @ignore
	__is = "MallComponent";
	
	/// @ignore
    __key  = _key;	// Llave propia
	
	/// @ignore
    __from =   "";	// Llave de a quien pertenece	
	
    // -- Display
	__display = true;	// Mostrar este valor
	__displayMethod = MALL_DUMMY_METHOD;	// Función para mostrar valor
	
    __displayKey  = "";	// Llave para traduccion 
    __displayName = "";	// Que nombre mostrar en el display
    
    __displayText    = [];	// textos variados que el usuario le da su uso.
    __displayTextKey = [];	// llaves de estos textos variados    
		
	#endregion

    #region METHODS
	/// @param {String} key			LLave propia
	/// @param {String} [keyFrom]	De quien proviene
	/// @param {Struct.MallComponent}
	static setKey = function(_key, _keyFrom="") {
		__key  = _key;
		__from = _keyFrom;
	}
	
	/// @param {Bool}	display			Ignorar en el UI
	/// @param {String} display_key		Llave a usar (Lexicon)
	/// @param {String} [TextKey...]	Distintas llaves a utilizar (Lexicon)
	/// @desc Establece las llaves de traduccion que utiliza Lexicon
    static setDisplay = function(_display=true, _display_key) {
        // Si es undefined se establece que la llave de display es la misma que la llave del componente
		__display = _display;
		
		if (__display) {
			__displayKey  = _display_key ?? __key;
			__displayName = lexicon_text(__displayKey);
		
			var i = 2; repeat (argument_count) {
				array_push(__displayTextKey, argument[i++] ); 
			}
		}
		
		return self;
	}
	
	#endregion
}