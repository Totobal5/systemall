/// @desc   Donde se guarda la configuracion para los modificadores del proyecto
///         Se configuran: 
/// @param {String} modKey
/// @return {Struct.MallMod}
function MallMod(_modKey) : Mall(_modKey) constructor 
{
    static eInStart = __dummy;
    static eInEnd   = __dummy;
    
    static eTurnUpdate = __dummy;
    static eTurnStart  = __dummy;
    static eTurnEnd    = __dummy;
    
    /// @desc Este evento se utiliza cuando se equipa un objeto
    static eEquip    = __dummy;
    static eDesequip = __dummy;
}


