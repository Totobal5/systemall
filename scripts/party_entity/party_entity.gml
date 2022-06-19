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
    __parts   = _parts  ;   // Equipo y partes
            
    __commands = {};        // Que comandos puede realizar
    
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
    
	static setGroup = function(_key, _index)
	{
		__group = _key;
		__groupIndex = _index;
		
		__stats	 .setKey(_key, _index);	// Establece la llave del grupo y el indice para crear la referencia.
		__control.setKey(_key, _index);	
		
		return self;
	}
  
  
    #endregion
}