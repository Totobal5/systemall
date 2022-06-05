
/// @param name
/// @param {PartyStats}     stats
/// @param {PartyControl}   control
/// @param {PartyParts}     parts
/// @param group_key
function PartyEntity(_name = "Test", _stats, _control, _parts, _group) : MallComponent(_name) constructor {
    __group = _group;
    __party = -1;
    
    // Renderizado
    __pos = (new Vector2(0, 0) );
    __spr = -1;        
    
    // Estructuras        
    __stats   = _stats;     /// @is {PartyStats}    // Estadisticas        
    __control = _control;   /// @is {PartyControl}  // Control de estados / buffos      
    __parts   = _parts  ;                           // Equipo y partes
            
    __commands = {};        // Que comandos puede realizar
    
    
    #region Metodos
    
    // Al pasar un turno actualiza los valores
    static PassTurn = function() {
        __control.UpdateAll();
    }
    
    /// @returns {PartyParts}
    static GetParts = function() {
        return __parts; 
    }
    
    /// @returns {PartyControl}
    static GetControl = function() {
        return __control;
    }
    
    /// @returns {PartyStats}
    static GetStats = function() {
        return __stats;
    }
    
    
    #endregion
}