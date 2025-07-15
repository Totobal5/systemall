// Feather disable once GM1045

/// @param {String} groupKey
function PartyGroup(_key) constructor
{
    // Variables de este grupo
    key = _key;
	vars = {};
	
    size = 0;
    limit = -1;
    entities = [];
    
    #region METHODS
    /// @ignore
    static Update = function()
    {
        var _size = array_length(entities);
        var i=0; repeat(_size)
        {
            var _entity = entities[i];
            _entity.index = i;
            i++;
        }
        
        return (_size);
    }
    
    /// @desc Agrega una entidad al grupo indicando el indice en donde insertarlo
    /// @param	{Struct.PartyEntity} PartyEntity
    /// @param	{Real} [index]=0
    /// @return {Bool}
    static Set = function(entity, index=0)
    {
        size = array_length(entities);
        if (limit == -1 || size < limit)
		{
            entity.group = key;
            array_insert (entities, index, entity);
            Update();
            
            return true;
        }
        
        return false;
    }
    
    /// @desc Agrega una entidad a este grupo colocandola al final
    /// @param	{Struct.PartyEntity} PartyEntity
    /// @return {Bool}
    static Add = function(_entity)
    {
        size = array_length(entities);
        if (limit == -1 || size < limit) 
        {
            array_push(entities, _entity);
            _entity.group = key;
            _entity.index = size - 1;
            
            // Actualizar posicion de todos las entidades
            Update();
            
            return true;
        }
        
        return false;
    }
    
    // @desc Devuelve la entidad que se encuentra en el indice
    // @param	{Real} [index]=0
    static Get = function(_index=0)
    {
        return (entities[_index] );
    }
    
    /// @desc Elimina y devuelve una entidad del grupo
    /// @param	{Real} [index]=0
	/// @return {Struct.PartyEntity}
    static Remove = function(_index=0)
    {
        // Guardar entidad en el lugar
        var _entity = entities[_index];
        
        array_delete( entities, _index, 1);
        // Actualizar tamaño
        size = Update();
        
        // Resetear valores de la entidad eliminada.
        _entity.group = "";
        _entity.index = -1;
        
        return (_entity);
    }
    
    /// @desc Busca una entidad y devuelve su indice. -1 si no existe.
    /// @param	{Struct.PartyEntity} PartyEntity
    static Find = function(_entity)
    {
        static FFind = function(_entity)
        {
            return (entity.key == _entity.key); 
        }
        var _m = method({entity: _entity}, FFind);
        return (array_find_index(entities, _m) );
    }
    
    /// @desc Limpia el gropo de entidades.
    static Clean = function()
    {
        // Limpiar array.
        entities = [];
        // Actualizar tamaño.
        size = array_length(entities);
        
        return self;
    }
    
    /// @desc Regresa el array de entidades.
    /// @return {Array<Struct.PartyEntity>}
    static GetEntities = function() 
    {
        return entities;
    }
    
    /// @desc Regresa un save struct
	/// @param	{Bool} [struct] devolver un struct o un JSON.
	/// @return {Struct, String}
    static Export = function(_struct=false)
    {
		/// @param	{Struct.PartyEntity} PartyEntity
        static FExport = function(_entity) 
        {
            array_push(order, _entity.Export() ); 
        }
		
        var _this = self;
        with ({}) 
        {
			default:
	            version = __MALL_VERSION;
				
	            key = _this.key;
	            limit = _this.limit;
	            order = _this.order;
	            // Exportar cada entidad.
	            array_foreach(_this.entities, method(self, FExport) );
				
				return (_struct) ? self : json_stringify(self, true);
			break;
        }
    }
    
    /// @param	{Struct, String} json
    static Import = function(_json) 
    {
        static FImport = function(_json) 
        {
            // Crear entidad nueva.
            var _party = party_create_entity(_json.key, 1);
            // Importar valores.
            _party.Import(_json);
            // Añadir al party que lo carga.
            Set(_party, _party.index);
        }
        
		// Si se pasa un string (JSON).
        if (is_string(_json) ) _json = json_parse(_json);
        // Cargar llave y limite.
        key = _json.key;
        limit = _json.limit;
		
        // Cargar datos.
        array_foreach(_json.order, method(self, FImport) );
    }
    
    #endregion
}

/// @desc Crea una party en donde se agregan entidades de party
/// @param {Struct.PartyGroup} PartyGroup
function party_create_group(_group)
{
    // Cache
    if (!struct_exists(Systemall.groups, _group.key) )
	{
        Systemall.groups[$ _group.key] = _group;
        
        #region TRACE
        if (__MALL_PARTY_TRACE) {
        show_debug_message($"M_Party: grupo {_group.key} creado");
        }
        #endregion
    }
}

/// @desc Devuelve un grupo de party
/// @param {string} group_key
/// @return {Struct.PartyGroup}
function party_get_group(_key)
{
    return (Systemall.groups[$ _key] );
}

/// @param {String} group_key
function party_exists_group(_key)
{
    return (variable_struct_exists(Systemall.groups, _key) );
}

/// @desc Intercambia las entidades de un grupo(A) a otro grupo(B)
/// @param {string} groupA
/// @param {string} groupB
function party_swap_group(_keyA, _keyB)
{
    static Update = function(v) 
    {
        v.group = key; 
    }
    
    // Obtener grupos
    var _gA = party_get_group(_keyA);
    var _gB = party_get_group(_keyB);
    
    // Obtener lista de entidades de cada grupo
    var _entitiesA = _gA.getEntities();
    var _entitiesB = _gB.getEntities();
    
    // Intercambiar
    _gA.entities = _entitiesB;
    _gB.entities = _entitiesA;
    
    // Actualizar llave
    with (_gA) array_foreach(entities, Update);
    with (_gB) array_foreach(entities, Update);
}

// ----------

/// @desc Limpia la lista de entidades de este grupo
/// @param {String} group_key
function party_group_clean(_key) 
{
    var _party = party_get_group(_key);
    return (_party.clean() );
}

/// @desc Devuelve todas las entidades de un grupo
/// @param {String} group_key
function party_group_get_entities(_key)
{
    var _party = party_get_group(_key);
    return (party_get_group(_key).getEntities() );
}

/// @desc Regresa la entidad que se encuentra en el indice de este grupo
/// @param	{String} group_key
/// @param	{Real} [index]=0
/// @return {Struct.PartyEntity}
function party_group_get(_key, _index=0)
{
    var _group = party_get_group(_key);
    return (!is_undefined(_group) ) ? _group.Get(_index) : undefined;
}

/// @desc Añade una entidad al final de un grupo
/// @param {String} group_key					Llave del grupo party
/// @param {Struct.PartyEntity} PartyEntity		Entidad de party
function party_group_add(_key, _entity)
{
    var _group = party_get_group(_key);
    // Agregar al grupo dependiendo de como este grupo agrega elementos
    if (!is_undefined(_group) ) 
    {
        return (_group.Add(_entity) ); 
    }
    
    return false;
}

/// @desc Añade una entidad al grupo indicando el indice en donde colocarlo
/// @param	{String} group_key					Llave del grupo
/// @param	{Struct.PartyEntity} PartyEntity	Entidad a agregar
/// @param	{Real} [index=0]					Indice para insertar
/// @returns {Struct.PartyGroup}
function party_group_set(_key, _entity, _index=0)
{
    var _group = party_get_group(_key);
    return (!is_undefined(_group) ) ? _group.Set(_entity, _index) : false;
}

/// @desc Busca una entidad de party en un grupo utilizando un filtro (lento)
/// @param  {String}    group_key   
/// @param  {Function}  filter      function(value, i) {}
/// @return {Struct.PartyEntity}
function party_group_filter(_key, _fn)
{
    var _group    = party_get_group(_key);
    var _entities = _group.entities;
    
    var _index = array_find_index(_entities, _fn);
    // Si es -1 devolver indefinido
    return (_index != -1) ? _entities[_index] : undefined;
}

/// @desc Busca una entidad de party en un grupo utilizando un filtro (lento) y devuelve el indice.
/// @param  {String}    group_key
/// @param  {Function}  filter
function party_group_filter_index(_key, _fn)
{
    var _group = party_get_group(_key);
    var _entities = _group.entities;
    return (array_find_index(_entities, _fn) );
}

/// @desc Regresa la cantidad de entidades en el grupo.
/// @param {String} group_key
/// @return {Real}
function party_group_size(_key)
{
    var _group = party_group_get_entities(_key);
    return (array_length(_group) );
}

/// @param {String} group_key
/// @param {Bool}   [struct] Si regresa un struct o json
function party_group_export(_key, _struct=false)
{
    var _party = party_get_group(_key);
    return (_party.Export(_struct) );
}

/// @param {String}         group_key
/// @param {Struct,String}  json 
function party_group_import(_key, _json)
{
    var _party = party_get_group(_key);
    return (_party.Import(_json) );
}

/// @desc Ejecuta una funcion por cada entidad en el grupo, si la funcion pasada entrega true entonces devuelve
/// un struct {entity, index}
/// @param  {String}    group_key   
/// @param  {Function}  foreach     function(value, i) {}
function party_group_foreach(_key, _fn)
{
    var _group = party_get_group(_key);
    if (!is_undefined(_group) ) 
    {
        var i = array_find_index(_group.entities, _fn);
        return (i != -1) ?
            {entity: undefined,         index: -1}  :
            {entity: _group.entitys[i], index : i}  ;
    }
}