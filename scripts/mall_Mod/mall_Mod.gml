/// @desc   Donde se guarda la configuracion para los modificadores del proyecto
///         Se configuran:
/// @param	{String} mod_key
/// @return {Struct.MallMod}
function MallMod(_modKey) : Mall(_modKey) constructor 
{
    static eInStart = function() {};
    static eInEnd = function() {};
    
    static eTurnUpdate = function() {};
    static eTurnStart = function() {};
    static eTurnEnd = function() {};
    
    /// @desc Este evento se utiliza cuando se equipa un objeto.
    static eEquip = function() {};
	/// @desc Este evento se utiliza cuando se desequipa un objeto
    static eDesequip = function() {};
}