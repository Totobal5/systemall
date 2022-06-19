/// @param	{String} group_key
/// @param	{Bool} [start_now]
/// @desc	Un grupo es como debe funcionar los componentes guardados (MallStorage) entre sí. Esto sirve para diferenciar clases, especies o razas en distintos rpg (Humanos distintos a Orcos por ejemplo)
/// @return {Struct.MallGroup}
function MallGroup(_key, _init=false) : MallComponent(_key) constructor {
    #region PRIVATE
	/// @ignore
	__is = instanceof(self);
	
    // Se utiliza un struct para guardar los datos y acceder rapidamente
    /// @ignore
	/// @type {Struct<Struct.MallStat>}
	__stats    = {};
    /// @ignore
	__states   = {}; 
	/// @ignore
    __elements = {}; 
	/// @ignore
    __parts    = {}; 
    #endregion
	
    #region METHODS  
	#region CREATES
	/// @desc Rellena los structs de cada componente
    static initialize = function() 
	{
		__initStats();
		__iniStates();
		__initElements();
		
        __initParts();
		
		return self;
    }
	
	/// @desc Inicia las estadisticas
    static __initStats = function() 
	{    
        var _keys = mall_get_stats();   // Obtener llaves
        var _content = {};
        
        // Eliminar llaves
		var i=0; repeat(array_length(_keys) )
		{
			var _key = _keys[i++];	
			_content[$ _key] = new MallStat(_key);
		}
		// Establecer el struct
        __stats = _content;
    }
    
	/// @desc Inicia los estados
    static __iniStates = function() 
	{
        var _keys = mall_get_states();   // Obtener llaves
        var _content = {};
        
		var i=0; repeat(array_length(_keys) )
		{
			var _key = _keys[i++];	
			_content[$ _key] = new MallState(_key);
		}
		// Establecer el struct
        __states = _content;
    }
    
	/// @desc Inicia las partes
    static __initParts  = function() 
	{
        var _keys = mall_get_parts();   // Obtener llaves
        var _content = {};
        
		var i=0; repeat(array_length(_keys) )
		{
			var _key = _keys[i++];
			_content[$ _key] = new MallPart(_key);
		}
		// Establecer el struct
        __parts = _content;
    }
 
	/// @desc Inicia las partes
    static __initElements  = function() 
	{
        var _keys = mall_get_elements();   // Obtener llaves
        var _content = {};
        
		var i=0; repeat(array_length(_keys) )
		{
			var _key = _keys[i++];
			_content[$ _key] = new MallElement(_key);
		}
		// Establecer el struct
        __elements = _content;
    } 
	
	#endregion
	
	/// @param {String} _key
	/// @return {Struct.MallStat}
	static getStat  = function(_key) {
		return __stats [$ _key]; 
	}
	
	/// @param {String} _key
	/// @return {Struct.MallState}
	static getState = function(_key) {
		return __states[$ _key]; 
	}
	
	/// @param {String} _key
	/// @return {Struct.MallPart}
	static getPart  = function(_key) {
		return __parts [$ _key]; 
	}
	
	/// @param {String} _key
	/// @return {Struct.MallElement}
	static getElement = function(_key) {
		return __elements[$ _key];
	}

    #endregion
    
    // Iniciar
    if (_init) initialize();
}