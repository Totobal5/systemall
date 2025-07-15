// Feather disable all
/// @param {String} key
/// @param {String} [itemType]
/// @param {Real} [buy]
/// @param {Real} [sell]
/// @return {Struct.PocketItem}
function PocketItem(_key, _type, _buy=0, _sell=0) : DarkCommand(_key) constructor 
{
    // Tipico
    onSelf    = true;
    onAllies  = true;
    onEnemies = false;
    
    // Tipo de objeto
    type = _type;
    
    create();
    
    // Valores de compra
    buy  =  _buy; // Valor al que se compra
    sell = _sell; // Valor al que se vende
    canSell = true; // Si puede vender
    canBuy  = true;	// Si puede compra
    
    /// @ignore Donde se guardan sus estadisticas [value, type]
    stats =     {};
    statsKeys = [];
    
    // -- Funciones
    #region METHODS
    
    static canDesequip = function(entity) 
    {
        return true;
    };
    
    /// @desc Establece un evento a ejecutar cuando se compra
    static buyAction  = function() {};
    /// @desc Establece un evento a ejecutar cuando se vende
    static sellAction = function() {};
    
    /// @desc Establece un evento a ejecutar cuando se encuentra en el mundo
    static worldStep  = function() {};
    /// @desc Establece un evento a ejecutar cuando se entra al mundo
    static worldEnter = function() {};
    /// @desc Establece un evento a ejecutar cuando se sale del mundo
    static worldExit  = function() {};
    
    static inAttackS = function() {};
    static inAttackE = function() {};
    
    static inDefenceS = function() {};
    static inDefenceE = function() {};
    
    static send = function(_store="") 
    {
    	var this = self;
    	return {
    		buy : this.buy, 
    		sell: this.sell
    	}; 
    }
    
    // -- Internal
    
    /// @desc Pone valores a las estadisticas
    /// @param  {String}            statKey
    /// @param  {Real}              value
    /// @param  {Enum.MALL_NUMTYPE} [type]
    /// @return {Struct.PocketItem}
    static setStat = function(_statKey, _value, _numType=MALL_NUMTYPE.REAL) 
    {
        static DataStats = Systemall.stats;
        var i=0; repeat(argument_count div 3) {
            var _key = argument[i];
            #region SAFETY
            if (__MALL_SAFETY) {
            if (!struct_exists(DataStats, _key) ) {
            show_debug_message($"MallRPG Pocket {key}: Stat {_key} no existe");	
            }}
            
            #endregion
            
            // Establecer valor en las estadisticas
            var _v = argument[i + 1];                      // Valor
            var _t = argument[i + 2] ?? MALL_NUMTYPE.REAL; // Tipo
            stats[$ _key] = [_v, _t];
            array_push(statsKeys, _key);
            i = i + 3;
        }
        
        return self;
    };
    
    /// @param  {String} statKey
    /// @return {Array<real>}
    static getStat  = function(_statKey)
    {
        return (stats[$ _statKey] );
    };
    
    /// @desc Permite devolver las estadisticas de este objeto normal
    static getStats = function() 
    {
        return stats;
    };
    
    static getStatsKeys = function()
    {
        return (statsKeys);
    };
    
    /// @param  {Real}  buyValue
    /// @param  {Real}  sellValue
    /// @param  {Bool}  [canBuy]=true
    /// @param  {Bool}  [canSell]=true
    /// @return {Struct.PocketItem}
    static setTrade = function(_buy, _sell, _canBuy=true, _canSell=true) 
    {
        buy  =  _buy;
        sell = _sell;
        
        canBuy  =  _canBuy;
        canSell = _canSell;
        
        return self;
    };
    
    /// @ignore
    static create = function()
    {
        // Obtener todos los itemtypes
        static Types = Systemall.types;
        if (!struct_exists(Types, type) ) Types[$ type] = {};
        Types[$ type][$ key] = is;
    }
    
    /// @ignore
    static getItem = function(_key)
    {
    
    }
    
    #endregion
}

/// @desc Agrega un objeto al sistema
/// @param {Struct.PocketItem} item
function pocket_item_create(_item)
{
    if (!struct_exists(Systemall.items, _item.key) ) 
    {
        Systemall.items[$ _item.key] = _item;
    }
}

/// @desc Regresa el objeto de la base de datos
/// @param  {String} key
/// @return {Struct.PocketItem}
function pocket_item_get(_key)
{
    return (Systemall.items[$ _key] );
}

/// @param {String} key
function pocket_item_exists(_key)
{
    return (struct_exists(Systemall.items, _key) );
}