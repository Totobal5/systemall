/// @desc Manager total.
function Wate()
{
    static manager = undefined;
    static result  = undefined;
    
} Wate();

/// @desc Manager de combates.
/// @param {String} key
function WateManager(_key) constructor
{
    key = _key;
    // Grupos, every: Todas las entidades
    groups =    {every: [] };
    quantity =  {};
    
    // Turno en que se encuentra
    turn =          1;
    turnGlobal =    1;
    // Funcion a ejecutar cuando inicia el turno.
    turnCallback =  [];
    // Funcion a ejecutar cuando finaliza el turno.
    turnECallback = [];
    // Orden de entidades por constructor.
    turnOrder =     [];
    // Orden de entidades por llave.
    turnOrderKey =  [];
    // Orden de entidades forzado.
    turnForced =    [];
    turnForcedKey = [];
    turnStatic =    true;
    
    // Entidad actual
    entityCurrent =         undefined;
    entityCurrentIndex =    -1;
    
    // Entidad a forzar
    entityForce =       false;
    entityForceIndex =  -1;
    
    // Que puede entregar al finalizar el combate
    lootTable   = [];
    // Que entregará al finalizar el combate
    lootFinal   = [];
    
    /// @desc Que realizar cuando termina el combate
    fnComplete  = function() {};
    /// @desc Evento para cambiar de cuarto
    fnRoomEnter = function() {}
    /// @desc Evento para salir de un cuarto
    fnRoomExit  = function() {}
    
    #region MANIPULATE
    /// @desc Agrega entidades a este grupo
    /// @param {string}             key     Llave del grupo
    /// @param {Struct.PartyEntity} entity  entidad a agregar
    /// @return {Bool}
    static add  =   function(_key, _entity, _addNumber=false)
    {
        static NumberKeys  = [" A", " B", " C", " D", " E", " F"];
        static ForQuantity = function(key) {quantity[$ key+"index"] = 0; }
        var n;
        if (!struct_exists(groups, _key) ) groups[$ _key] = [];
        var _arr = groupGet(_key);
        // Añadir
        array_push(_arr, _entity);
        var n=array_length(_arr); // Obtener longitud
        // Agregar igualmente en every
        if (!array_contains(groups.every, _entity) ) array_push(groups.every, _entity);
        // Obtener indice
        _entity.battleIndex = n;
        _entity.battleGroup = _key;
        
        // Colocar "numeros" a los que son iguales
        if (_addNumber) {
            if (!struct_exists(quantity, _entity.key) ) {
                quantity[$ _entity.key] = 0;
                quantity[$ _entity.key+"index"] = 0;
            } 
            else {
                quantity[$ _entity.key]++;
            }
            
            if (quantity[$ _entity.key] > 0) {
                var i=0; repeat(array_length(groups.every) ) {
                    var _aren =  groups.every[i];
                    var _index = quantity[$ _aren.key+"index"];
                    if (quantity[$ _aren.key] > 0) { 
                        _aren.numberKey = NumberKeys[_index];
                        // No salir del limite
                        if (_index < quantity[$ _aren.key] ) {
                            quantity[$ _aren.key+"index"]++;
                        }
                    }
                    
                    i++;
                }
            }
            array_foreach(struct_get_names(quantity), ForQuantity);
        }
        
        return self;
    }
    
    /// @desc Elimina una entidad de un grupo, se puede indicar si se desea elimnar de "every".
    /// @param {string} key
    /// @param {real}   index
    /// @param {bool}   [includeEvery]
    static remove = function(_key, _index, _include=false)
    {
        var _group =  groupGet(_key);
        var _entity = _group[_index];
        array_delete(_group, _index, 1);
        // Eliminar del grupo de todos.
        if (_include) {
            var _every =  groups.every;
            var _eindex = array_find_index(_every, method({_entity}, function(v) {return _entity == v; }) );
            array_delete(_every, _eindex, 1);
        }
        
        return (_entity);
    }
    
    #endregion
    
    #region GROUPS
    /// @desc Crear grupo
    /// @param {string} key Llave del grupo
    static groupCreate = function(_key)
    {
        if (!struct_exists(groups, _key) ) {groups[$ _key] = []; }
        return self;
    }
    
    /// @param {string} key Llave del grupo o hash.
    static groupGet =  function(_key)
    {
        static HashEvery = variable_get_hash("every");
        _key ??= HashEvery;
        if (is_numeric(_key) ) return (struct_get_from_hash(groups, _key) );
        return (groups[$ _key] );
    }
    
    /// @desc Reorganiza un grupo utilizando una función
    /// @param {string}   key        llave del grupo.
    /// @param {function} function   funcion para organizar elementos.
    /// @param {bool}     [original] crear un grupo nuevo con el orden original.
    static groupSort = function(_key, _fun, _make=false) 
    {
        static MakeNew = function(v) {return (v); }; 
        var _group = groupGet(_key);
        // Crear un grupo nuevo sin un orden
        if (_make) {
            var _nkey = _key+".not";
            if (!struct_exists(groups, _nkey) ) {groups[$ _nkey] = array_map(_group, MakeNew); }
        }
        array_sort(_group, _fun);
        return self;
    }
    
    /// @desc Devuelve una copia de un grupo.
    static groupCopy = function(_key="every")
    {
        static MakeCopy = function(v) {return v; };
        var _group = groupGet(_key);
        return (array_map(_group, MakeCopy) );
    }
    
    #endregion
    
    #region TURNS
    /// @desc Crea el orden de entidades utilizando un filtro
    static turnOrganize = function(_key="every", _filter)
    {
        var _entities =     groupGet(_key);
        var _entitiesSize = array_length(_entities);
        
        // Crear turnos
        turnOrder =    [];
        turnOrderKey = [];
        _filter(_entities);
    }
    
    /// @desc Avanza un turno.
    static turnAdvance  = function(_quantity=1)
    {
        turn = clip(turn+_quantity, 1, array_length(turnOrder) );
        turnGlobal++;
        return self;
    }
    
    /// @desc Evento de inicio de turno
    /// @param {real}     turn     
    /// @param {function} function function(turn, groups)
    static turnAddEvent = function(_turn, _fn)
    {
        // Añade una función al array
        array_insert(turnCallback, _turn, _fn);
        return self;
    }
    
    /// @desc Ejecuta un evento en el turno global actual.
    static turnExecuteEvent = function()
    {
        if (turnGlobal < array_length(turnCallback)) {
            var _fn = turnCallback[turnGlobal];
            if (_fn != 0 && is_callable(_fn) ) {return _fn(turnGlobal, groups); }
        }
        return undefined;
    }
    
    static turnRemoveEvent = function(_index)
    {
        _index ??= turnGlobal;
        array_set(turnCallback, _index, 0);
    }
    
    /// @param {real}               turn
    /// @param {Struct.PartyEntity} entity
    static turnForcedAdd = function(_turn, _entity)
    {
        array_insert(turnForced, _turn, _entity);
        return self;
    }
    
    /// @desc Obtiene la entidad forzada que corresponde con el turno actual.
    /// @return {Struct.PartyEntity}
    static turnForcedGet  = function()
    {
        if (turnGlobal < array_length(turnForced) ) {
            var _entity = turnForced[turnGlobal];
            if (_entity != 0) return _entity;
        }
        
        return undefined;
    }
    
    #endregion
    
    #region LOOTS
    /// @param {string} key          Pocket item key
    /// @param {any}    quantity     Cantidad
    /// @param {real}   probability  Probabilidad
    static Loot = function(_key, _quantity, _probability) constructor 
    {
        key = _key;
        quanity     =   _value;
        probability =   _probability;
    }
    
    /// @desc Agrega loot para entregar al finalizar el combate
    /// @param {string} key          Pocket item key
    /// @param {any}    quantity     Cantidad de este objeto
    /// @param {real}   probability  Probabilidad de entregar este elemento
    static lootAdd = function(_itemKey, _quantity, _probability)
    {
        var _loot = new Loot(_itemKey, _quantity, _probability);
        array_push(lootTable, _loot);
        return self;
    }
    
    /// @desc Elimina un elemento del loot que se entregará
    /// @param {real} [index]=0
    static removeLoot = function(_index=0)
    {
        array_delete(lootTable, _index, 1);
        return self;
    }
    
    
    #endregion
    
    /// @desc Obtiene la nueva entidad actual utilizando "turnOrder"
    static updateActual = function()
    {
        if (!entityForce) {
            var _index    = turn - 1;
            entityCurrent = turnOrder[_index];
        }
        // Si hay una entidad forzada
        else {
            entityCurrent = turnOrder[entityForceIndex];
        }
        
        return self;
    }
    
    /// @desc Devuelve la entidad actual
    static getCurrent = function()
    {
        return (entityCurrent);
    }
    
    static setEventCompleted = function(_fn)
    {
        fnComplete = _fn;
        return self;
    }
    
    static executeCompleted = function()
    {
        if (is_callable(fnComplete) ) return fnCompleted();
        return undefined;
    }
    
    static print = function()
    {
        var _every = groups.every;
        var i=0; repeat(array_length(groups.every) )
        {
            var _entity = _every[i];
            show_debug_message("");
            show_debug_message($"M_Wate (every): {_entity.key} | {_entity.level}, stats: ");
            // Print estadisticas.
            _entity.printStats();
            
            i++;
        }
        // Print el orden de turnos.
        show_debug_message($"M_Wate: order {turnOrderKey}");
    }
    
    Wate.manager = self;
}