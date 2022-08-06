/// @param  {String}				entity_name
/// @param  {Struct.PartyStats}		stats
/// @param  {Struct.PartyControl}	control
/// @param  {Struct.PartyParts}		parts
/// @param group_key
function PartyEntity(_name = "Test", _stats, _control, _parts, _group) : MallComponent(_name) constructor 
{
    __group = _group;	// Key del party group
	__groupIndex = -1;	// Indice del party group
	
    __party = -1;
  
    // Estructuras        
    __stats   = _stats;		// Estadisticas        
    __control = _control;   // Control de estados / buffos      
    __equipment = _parts;   // Equipo y partes
    
	__turnCombat  = 0;	// En que turno se mueve
	__turnControl = 0;	// Numero de turnos que han habido 
	
	__pass = false;		// Si se salta un turno
	__passCount = 0;	// Cuantos turnos a saltado
	__passReset = 0;	// Reiniciar __pass a esta cantidad de turnos -1 es infinito
	
    __commands  = {};       // Que comandos puede realizar
	__effective = {};		// Si un ataque utiliza un elemento revisar de que manera afecta a esta entidad

	__mods = {};
	// {modificador: []}

    #region Metodos
    
    // Al pasar un turno actualiza los valores
    static PassTurn = function() {
        __control.UpdateAll();
    }
    
    /// @returns {PartyParts}
    static getParts = function() {
        return __parts; 
    }
    
    /// @returns {PartyControl}
    static getControl = function() {
        return __control;
    }
    
    /// @returns {PartyStats}
    static getStats = function() {
        return __stats;
    }
    
	/// @ignore
	/// @param {String}	group_key
	/// @param {String}	index
	static setGroup = function(_key, _index)
	{
		__group = _key;
		__groupIndex = _index;
		
		__stats	 .setKey(_key, _index);	// Establece la llave del grupo y el indice para crear la referencia.
		__control.setKey(_key, _index);	
		__parts  .setKey(_key, _index);
		return self;
	}
  
	/// @param	{String}	element_key
	/// @param	{Function}	calculate_method
	static setEffective = function(_key, _method)
	{
		__effective[$ _key] = _method;
		return self;
	}
	
	/// @return {Function}
	static getEffective = function(_key)
	{
		return (__effective[$ _key] );
	}

	static getEffectiveCount = function()
	{
		return (variable_struct_names_count(__effective) );	
	}
	

    #endregion
}