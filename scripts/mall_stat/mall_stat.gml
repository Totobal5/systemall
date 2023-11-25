/// @desc Donde se guardan las propiedades de una estadistica
/// @param {String} key
function MallStat(_key) : MallMod(_key) constructor 
{
    // Valor inicial del estado
    init = false;
    // Tipo de numero que utiliza
    type = MALL_NUMTYPE.REAL;
    // Si acepta el mismo efecto varias veces
    same =      false;
    // Cuantos se pueden agregar en party. -1 para infinitos (NO PUEDE SER 0)	
    controls =  -1;
    
    // True: enviar actual al maximo al equipar false: dejar como esta
    saveable = false;
    
    /// @desc Este evento se utiliza cuando se equipa un objeto
    static eEquip = function(_entity, _stat) 
    {
        actual = control; 
    }
    
    // Valor inicial
    start =         0;
    // Nivel inicial
    startLevel =    1;
    // Limite del valor minimo
    limitMin = 0;
    // Limite del valor maximo
    limitMax = 0;
    
    // Nivel minimo y maximo
    levelLimitMin = __MALL_STAT_LEVEL_MIN;
    levelLimitMax = __MALL_STAT_LEVEL_MAX;
    // Si sube de nivel aparte de otras estadisticas con su propia experencia etc
    levelSingle = false;
    
    // Iterador
    iterator = new MallIterator();
    
    /// @desc   Forma de subir de nivel
    /// @param  {Struct.PartyStats} statEntity
    /// @param  {Struct.PartyStats$$createAtom} statAtom
    /// @param  {Any*} [vars]
    /// @return {Real}
    static levelUp = function(stats, atom) 
    {
        return 0;
    };
    
    /// @desc   Indicar si puede o no subir de nivel si sube individual
    /// @param  {Struct.PartyStats} [statEntity]
    /// @param  {Any*} [vars]
    /// @return {Bool}
    static checkLevel  = function(stats) 
    {
        return false; 
    };
    
    /// @param {Struct.PartyStats} entity
    static entityUpdate = function(entity) 
    {
    };
}

/// @param {String}          key
/// @param {Struct.MallStat} Stat
function mall_create_stat(_key, _component) 
{
    if (!struct_exists(Systemall.stats, _key) ) 
    {
        Systemall.stats[$ _key] = _component;
        array_push(Systemall.statsKeys, _key);
    }
}

/// @param {String} statKey
/// @desc Devuelve la estructura de la estadistica
/// @return {Struct.MallStat}
function mall_get_stat(_statKey) 
{
    return (Systemall.stats[$ _statKey] );
}

/// @param {String} statKey
function mall_exists_stat(_statKey)
{
    static stats = MallDatabase.stats;
    return (struct_exists(Systemall.stats, _statKey) );
}

/// @desc Devuelve un array con las llaves de todos las estadisticas creadas
/// @return {Array<String>}
function mall_get_stat_keys(_copy=false) 
{
    if (_copy) 
    {
        var _array = array_create(0);
        array_copy(_array, 0, Systemall.statsKeys, 0, array_length(Systemall.statsKeys) );
        return _array;
    } else {
        return (Systemall.statsKeys);
    }
}