/// @desc Represents an item entry inside a bag with quantity and unique variables.
/// @param {String} item_key Item template key.
/// @param {Real} count Quantity for this item entry.
/// @param {Struct} [vars] Optional unique data struct (for example { enchantment: "fire" }).
function MallItemInstance(_item_key, _count, _vars = {}) constructor
{
    /// @desc Item template key.
    /// @type {String}
    key = _item_key;
    
    /// @desc Amount in this entry.
    /// @type {Real}
    count = _count;
    
    /// @desc Entry-specific variables.
    /// @type {Struct}
    vars = _vars;
    
    #region API
    
    /// @desc Exports this instance to a plain struct for saving.
    /// @returns {{key: String, count: Real, vars: Struct}}
    static Export = function()
    {
		var _this = self;
        return {
            key: _this.key,
            count: _this.count,
            vars: variable_clone(_this.vars)
        };
    }
    
    /// @desc Imports data from a saved struct.
    /// @param {{key: String, count: Real, vars: Struct}} data The data struct to import.
    /// @returns {undefined}
    static Import = function(_data)
    {
        key = _data.key;
        count = _data.count;
        vars = variable_clone(_data.vars);
    }
    
    #endregion
}