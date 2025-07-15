/// @desc Donde se guardan las propiedades de una estadistica
/// @param {String} key
function MallStat(_key) : MallMod(_key) constructor 
{
    /// @ignore Valor inicial del estado.
    init = false;
    /// @ignore Tipo de numero que utiliza.
    type = MALL_NUMTYPE.REAL;
    /// @ignore Si acepta el mismo efecto varias veces.
    same = false;
    // Cuantos se pueden agregar en party. -1 para infinitos (NO PUEDE SER 0).
    controls = -1;
    
    /// @ignore True: enviar actual al maximo al equipar false: dejar como esta.
    canSave = false;

    /// @ignore Valor inicial
    start = 0;
    /// @ignore Nivel inicial
    startLevel = 1;
    /// @ignore Limite del valor minimo
    limitMin = 0;
    /// @ignore Limite del valor maximo
    limitMax = 0;
    
    /// @ignore Nivel minimo.
    levelLimitMin = __MALL_STAT_LEVEL_MIN;
	/// @ignore Nivel maximo.
    levelLimitMax = __MALL_STAT_LEVEL_MAX;
    /// @ignore Si sube de nivel aparte de otras estadisticas con su propia experencia etc.
    levelSingle = false;
    
    /// @ignore Iterador.
    iterator = new MallIterator();
    
    static eInStart = function(_entity) {}
    
    /// @desc   Forma de subir de nivel. Se ejecuta desde un Atom.
    /// @param  {Struct.PartyEntity} PartyEntity
    /// @return {Real}
    static eLevelUp = function(_entity) 
    {
        return 0;
    };
    
    /// @desc   Indicar si puede o no subir de nivel si sube individual.
    /// @param  {Struct.PartyEntity} PartyEntity
    /// @return {Bool}
    static eLevelCheck = function(_entity)
    {
        return false; 
    };
    
    /// @param {Struct.PartyEntity} PartyEntity
    static eUpdate  = function(entity) 
    {
    };
    
    /// @desc Este evento se utiliza cuando se equipa un objeto. Se ejecuta desde un Atom.
	/// @param {Struct.PartyEntity} PartyEntity
    static eEquip = function(_entity)
    {
        actual = control; 
    }
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
    }
	else 
	{
        return (Systemall.statsKeys);
    }
}