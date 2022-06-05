/// @param {String} _key
/// @return {Struct.MallItemtype}
function MallItemtype(_key) : MallComponent(_key) constructor {
    __subitem = {};
    
    #region Metodos
    /// @param _sub_item
    /// @param _value
    static set = function(_sub_item, _value) {
        __subitem[$ _sub_item] = _value;
        
        return self;
    }
    
	/// @param {String} _key
	static get = function(_key) {
		return (__subitem[$ _key] );	
	}

	/// @param {String} _key
	/// @return {Bool}
	static exists = function(_key) {
		return (variable_struct_exists(__subitem, _key) );	
	}
	
    #endregion
}