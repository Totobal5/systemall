/// @desc Manager total.
function Wate()
{
	/// @is {Struct.WateManager}
    static manager = undefined;
	/// @is {Struct.MallResult}
    static result = undefined;
    
} Wate();

/// @desc Manager de combates.
/// @param {String} key
function WateManager(_key) constructor
{
    key = _key;
    // Grupos, every: Todas las entidades.
    groups = {every: [] };
    quantity = {};
    
    // Turno en que se encuentra.
    turn = 1;
    turnGlobal = 1;
    // Funcion a ejecutar cuando inicia el turno.
    turnSCallback = [];
    // Funcion a ejecutar cuando finaliza el turno.
    turnECallback = [];
    // Orden de entidades por constructor.
    turnOrder = [];
    // Orden de entidades por llave.
    turnOrderKey = [];
    // Orden de entidades forzado.
    turnForced = [];
    turnForcedKey = [];
    turnStatic = true;
    
    // Entidad actual.
    entityCurrent = undefined;
    entityCurrentIndex = -1;
    
    // Entidad a forzar.
    entityForce = false;
    entityForceIndex = -1;
    
    // Que puede entregar al finalizar el combate.
    lootTable = [];
    // Que entregará al finalizar el combate.
    lootFinal = [];
    
    /// @desc Que realizar cuando termina el combate.
    eComplete = function()
	{
	};
	
    /// @desc Evento para cambiar de cuarto.
    eRoomEnter = function()
	{
	};
	
    /// @desc Evento para salir de un cuarto.
    eRoomExit = function()
	{
	};
    
    #region MANIPULATE
    /// @desc Agrega entidades a este grupo
    /// @param	{String}				group_key	Llave del grupo
    /// @param	{Struct.PartyEntity}	PartyEntity	Entidad a agregar
    /// @return {Bool}
    static Add = function(_key, _entity, _addNumber=false)
    {
		// Letras para diferenciar entidades identicas.
        static NumberKeys = [" A", " B", " C", " D", " E", " F", "G", "H", "I", "J", "K"];
		/// @param	{String} key
        static ForQuantity = function(key) 
		{
			quantity[$ key+"index"] = 0;
		}
		
        var n;
        if (!struct_exists(groups, _key) ) groups[$ _key] = [];
        var _arr = GroupGet(_key);
        // Añadir.
        array_push(_arr, _entity);
		// Obtener longitud.
        var _size = array_length(_arr);
		
        // Agregar igualmente en every.
        if (!array_contains(groups.every, _entity) ) array_push(groups.every, _entity);
		// Obtener indice.
        _entity.battleIndex = _size;
        _entity.battleGroup = _key;
        
        // Colocar "numeros" a los que son iguales
        if (_addNumber)
		{
            if (!struct_exists(quantity, _entity.key) )
			{
                quantity[$ _entity.key] = 0;
                quantity[$ _entity.key+"index"] = 0;
            }
            else
			{
                quantity[$ _entity.key]++;
            }
            
            if (quantity[$ _entity.key] > 0)
			{
                var i=0; repeat(array_length(groups.every) )
				{
                    var _aren = groups.every[i];
                    var _index = quantity[$ _aren.key+"index"];
                    if (quantity[$ _aren.key] > 0)
					{ 
                        _aren.numberKey = NumberKeys[_index];
                        // No salir del limite
                        if (_index < quantity[$ _aren.key] )
						{
                            quantity[$ _aren.key+"index"]++;
                        }
                    }
                    
                    i++;
                }
            }
			
			// Limpiar quantity.
            array_foreach(struct_get_names(quantity), ForQuantity);
        }
        
        return self;
    }
    
    /// @desc Elimina una entidad de un grupo, se puede indicar si se desea elimnar de "every".
    /// @param {string} key
    /// @param {real}   index
    /// @param {bool}   [includeEvery]
    static Remove = function(_key, _index, _include=false)
    {
        var _group =  GroupGet(_key);
        var _entity = _group[_index];
        array_delete(_group, _index, 1);
        // Eliminar del grupo de todos.
        if (_include)
		{
            var _every = groups.every;
            // Buscar entidad.
			var _eindex = array_find_index(_every, method({_entity}, function(v) 
			{
				return (_entity == v);
			}) );
			
			// Eliminar.
            array_delete(_every, _eindex, 1);
        }
        
        return (_entity);
    }
    
    #endregion
    
    #region GROUPS
    /// @desc Crear grupo
    /// @param	{String} group_key	Llave del grupo
    static GroupCreate = function(_key)
    {
        if (!struct_exists(groups, _key) ) {groups[$ _key] = []; }
        return self;
    }
    
    /// @param	{String} [group_key]	Llave del grupo o hash.
    static GroupGet = function(_key)
    {
        static HashEvery = variable_get_hash("every");
        // Si no se define entonces se utiliza el hash de every.
		_key ??= HashEvery;
		// Para Hash.
        if (is_numeric(_key) ) return (struct_get_from_hash(groups, _key) );
		
        return (groups[$ _key] );
    }
    
    /// @desc Reorganiza un grupo utilizando una función
    /// @param	{String}	group_key	Llave del grupo.
    /// @param	{Function}	function	Funcion para organizar elementos.
    /// @param	{Bool}		[original]	Crear un grupo nuevo con el orden original.
    static GroupSort = function(_key, _fun, _make=false) 
    {
        static MakeNew = function(v) {return (v); }; 
        var _group = GroupGet(_key);
        // Crear un grupo nuevo sin un orden.
        if (_make)
		{
            var _nkey = _key+".not";
            if (!struct_exists(groups, _nkey) ) {groups[$ _nkey] = array_map(_group, MakeNew); }
        }
		// Organizar.
        array_sort(_group, _fun);
		
        return self;
    }
    
    /// @desc Devuelve una copia de un grupo.
	/// @param	{String}	group_key	Llave del grupo.
    static GroupCopy = function(_key="every")
    {
        static MakeCopy = function(v) {return v; };
        var _group = GroupGet(_key);
		
        return (array_map(_group, MakeCopy) );
    }
    
    #endregion
    
    #region TURNS
    /// @desc Crea el orden de entidades utilizando un filtro.
	/// @param	{String}	group_key	Llave del grupo.
	/// @param	{Function}	filter		Funcion para organizar elementos.
    static TurnOrganize = function(_key="every", _filter)
    {
        var _entities = GroupGet(_key);
        var _entitiesSize = array_length(_entities);
        
        // Crear turnos.
        turnOrder = [];
        turnOrderKey = [];
		
        return (_filter(_entities) );
    }
    
    /// @desc Avanza un turno.
	/// @param	{Real}	[aumento]	Default 1.
    static TurnAdvance = function(_quantity=1)
    {
		turn += _quantity;
		// Al llegar al maximo devolver al minimo.
		if (turn > array_length(turnOrder) ) turn = 1;
        // Aumentar todos los turnos pasados.
		turnGlobal++;
		
        return self;
    }
    
    /// @desc Evento de inicio de turno
    /// @param	{Real}		turn     
    /// @param	{Function}	function function(turnGlobal, groups)
    static TurnAddEvent = function(_turn, _fn)
    {
        // Añade una función al array.
        array_insert(turnCallback, _turn, _fn);
		
        return self;
    }
    
    /// @desc Ejecuta un evento en el turno global actual.
    static TurnExecuteEvent = function()
    {
        if (turnGlobal < array_length(turnCallback) )
		{
            var _fn = turnCallback[turnGlobal];
            if (_fn != 0 && is_callable(_fn) ) 
			{
				return (_fn(turnGlobal, groups) ); 
			}
        }
		
        return undefined;
    }
    
	/// @param	{Real} index
    static TurnRemoveEvent = function(_index)
    {
        array_set(turnCallback, _index ?? turnGlobal, 0);
		return self;
    }
    
    /// @param	{Real}					turn
    /// @param	{Struct.PartyEntity}	PartyEntity
    static TurnForcedAdd = function(_turn, _entity)
    {
        array_insert(turnForced, _turn, _entity);
		
		return self;
    }
    
    /// @desc Obtiene la entidad forzada que corresponde con el turno actual.
    /// @return {Struct.PartyEntity}
    static TurnForcedGet  = function()
    {
        if (turnGlobal < array_length(turnForced) )
		{
            var _entity = turnForced[turnGlobal];
            if (_entity != 0) return _entity;
        }
        
        return undefined;
    }
    
    #endregion
    
    #region LOOTS
	/// @ignore
    /// @param	{String}	pocket_key	Pocket item key.
    /// @param	{Any}		quantity	Cantidad.
    /// @param	{Real}		probability	Probabilidad.
    static AtomLoot = function(_key, _quantity, _probability) constructor 
    {
        key = _key;
        quanity = _quantity;
        probability = _probability;
    }
    
    /// @desc Agrega loot para entregar al finalizar el combate
    /// @param	{String}	key			Pocket item key.
    /// @param	{Any}		quantity	Cantidad de este objeto.
    /// @param	{Real}		probability	Probabilidad de entregar este elemento.
    static LootAdd = function(_itemKey, _quantity, _probability)
    {
        var _loot = new AtomLoot(_itemKey, _quantity, _probability);
        array_push(lootTable, _loot);
        return self;
    }
    
    /// @desc Elimina un elemento del loot que se entregará
    /// @param	{Real} [index]=0
    static LootRemove = function(_index=0)
    {
        array_delete(lootTable, _index, 1);
        return self;
    }
    
    #endregion
    
    /// @desc Obtiene la nueva entidad actual utilizando "turnOrder"
    static UpdateCurrent = function()
    {
		// Si no hay una entidad forzada.
        if (!entityForce)
		{
            entityCurrent = turnOrder[turn - 1];
        }
        // Si hay una entidad forzada.
        else
		{
            entityCurrent = turnOrder[entityForceIndex];
        }
        
        return self;
    }
    
    /// @desc Devuelve la entidad actual
	/// @return {Struct.PartyEntity}
    static GetCurrent = function()
    {
        return (entityCurrent);
    }
    
	/// @param	{Function}	complete_event	function() {}
    static SetEventComplete = function(_fn)
    {
        eComplete = _fn;
        return self;
    }
    
	/// @desc Ejecuta el evento al completar una batalla.
    static ExecuteCompleted = function()
    {
        if (is_callable(fnComplete) ) return eComplete();
        return undefined;
    }
    
	/// @ignore
    static __manager_print = function()
    {
        var _every = groups.every;
        var i=0; repeat(array_length(groups.every) )
        {
            var _entity = _every[i];
            show_debug_message("");
            show_debug_message($"M_Wate (every): {_entity.key} | {_entity.level}, stats: ");
            // Print estadisticas.
            _entity.__mall_entity_trace_stats();
			// Print controls.
            _entity.__mall_entity_trace_controls();
            
			i++;
        }
		
        // Print el orden de turnos.
        show_debug_message($"M_Wate: order {turnOrderKey}");
    }
    
	// Establecerse así mismo como el manager más actual.
	static_get(Wate).manager = self;
}