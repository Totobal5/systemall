global._MALL_LOCAL = (new __mall_class_localization() );

#macro MALL_LOCAL global._MALL_LOCAL

function __mall_class_localization() constructor {
    #region Interno
    __is = "MALL_LOCAL";
    
    #endregion
    
    name = "";
    des = "";
    ret = "";
    
    ext = [""];
    
    scr = undefined;
    
    #region Metodos
    /// @param name
    /// @param description
    /// @param return
    /// @param {script} source
    static SetBasic  = function(_name, _des, _ret, _scr) {
        name = _name;
        des = _des;
        ret = _ret;
        
        scr = _scr;
        
        return self;
    }
    
    /// @param extra_array
    static AddExtras = function(_extarray) {
        foreach(_extarray, function(in, i) {ext[i] = _extarray; });

        return self;
    }
    
    /// @param index
    static GetExtra  = function(_ind) {
        return ext[_ind];
    } 
    
    /// @returns {script}
    static GetTranslate = function() {
        return scr;
    }     
    
    #endregion
}

/// @param name
/// @param description
/// @param return
/// @param {script} source
/// @param extras*
function mall_set_localization(_name, _des, _ret, _scr, _ext = [""]) {
    if (is_undefined(_scr) ) _scr = function(str) {return str; }
    
    return (MALL_LOCAL.SetBasic(_name, _des, _ret, _scr).AddExtras(_ext) );
}