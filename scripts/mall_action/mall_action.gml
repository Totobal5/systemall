/// @param _key
/// @desc Crea una accion y un lugar donde se almacenan sus sub-tipos
function MallAction(_key) : MallComponent(_key) constructor {
    __subaction = {};
    
    #region Metodos
    /// @param _sub_action
    /// @param _value
    static set = function(_sub_action, _value) {
        __subaction[$ _sub_action] = _value;
        
        return self;
    }
    
    #endregion
}
