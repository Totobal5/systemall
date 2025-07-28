// Feather disable once GM1045

/// @desc Define una colección de entidades, como el equipo del jugador o un grupo de enemigos.
/// @param {String} key
function PartyGroup(_key) : Mall(_key) constructor
{
    // --- Propiedades ---
    limit = -1;      // Límite de entidades en este grupo. -1 para infinito.
    entities = [];   // Array que contiene las instancias de PartyEntity.
	
    #region MÉTODOS DE MANIPULACIÓN
    
    /// @desc Añade una entidad al final del grupo si hay espacio.
    /// @param {Struct.PartyEntity} entity La entidad a añadir.
    /// @return {Bool}
    static Add = function(_entity)
    {
        var _size = array_length(entities);
        if (limit == -1 || _size < limit) 
        {
            array_push(entities, _entity);
            _entity.group_key = key; // Asignar la llave del grupo a la entidad
            return true;
        }
        return false;
    }
    
    /// @desc Inserta una entidad en un índice específico del grupo.
    /// @param {Struct.PartyEntity} entity La entidad a añadir.
    /// @param {Real} [index]=0 El índice donde insertar.
    /// @return {Bool}
    static Set = function(_entity, _index=0)
    {
        var _size = array_length(entities);
        if (limit == -1 || _size < limit)
		{
            _entity.group_key = key;
            array_insert(entities, _index, _entity);
            return true;
        }
        return false;
    }
    
    /// @desc Elimina y devuelve una entidad del grupo por su índice.
    /// @param {Real} [index]=0
	/// @return {Struct.PartyEntity} La entidad eliminada o undefined.
    static Remove = function(_index=0)
    {
        if (_index < 0 || _index >= array_length(entities)) return undefined;
        
        var _entity = entities[_index];
        array_delete(entities, _index, 1);
        
        _entity.group_key = ""; // Limpiar la referencia al grupo
        return _entity;
    }
    
    /// @desc Busca una entidad por su instancia y la elimina del grupo.
    /// @param {Struct.PartyEntity} entity La entidad a eliminar.
    /// @return {Struct.PartyEntity} La entidad eliminada o undefined.
    static RemoveByInstance = function(_entity)
    {
        var _index = array_get_index(entities, _entity);
        if (_index > -1)
        {
            return self.Remove(_index);
        }
        return undefined;
    }
    
    /// @desc Limpia todas las entidades del grupo.
    static Clean = function()
    {
        entities = [];
        return self;
    }
    
    #endregion
    
    #region MÉTODOS DE ACCESO
    
    /// @desc Devuelve la entidad que se encuentra en el índice.
    /// @param {Real} [index]=0
    static Get = function(_index=0)
    {
        if (_index < 0 || _index >= array_length(entities)) return undefined;
        return entities[_index];
    }
    
    /// @desc Devuelve el array completo de entidades.
    /// @return {Array<Struct.PartyEntity>}
    static GetEntities = function() 
    {
        return entities;
    }
    
    /// @desc Devuelve el número de entidades en el grupo.
    /// @return {Real}
    static Size = function()
    {
        return array_length(entities);
    }
    
    #endregion
    
    #region CONFIGURACIÓN Y GUARDADO
    
    /// @desc Configura el grupo a partir de un struct de datos.
    /// @param {Struct} data Struct con los datos (ej: { limit: 4 }).
    static FromData = function(_data)
    {
        limit = _data[$ "limit"] ?? -1;
        return self;
    }
    
    /// @desc Exporta el estado del grupo a un struct para guardarlo.
    /// @return {Struct}
    static Export = function()
    {
        var _this = self;
		var _export_data = method(_this, Mall.Export)(); // Llama al export del padre
        with (_export_data)
		{
			limit = _this.limit;
			entity_keys = [];
			
	        // Guardar solo las llaves de las entidades, no las entidades completas
	        for (var i = 0; i < array_length(_this.entities); i++)
	        {
	            array_push(entity_keys, _this.entities[i].key);
	        }		
		
			return self;
		}
    }
    
    /// @desc Importa y restaura el estado del grupo desde un struct.
    /// @param {Struct} import_data El struct con los datos guardados.
    static Import = function(_import_data)
    {
        method(self, Mall.Import)(_import_data); // Llama al import del padre
        
        limit = _import_data.limit;
		
		// Limpiar el grupo antes de llenarlo
        Clean();
        
        // Añadir las entidades al grupo buscándolas por su llave.
        // Asume que las entidades ya han sido creadas y están disponibles.
        var _entity_keys = _import_data.entity_keys;
        for (var i = 0; i < array_length(_entity_keys); i++)
        {
            var _entity_key = _entity_keys[i];
			// Necesitarás esta función
            var _entity_instance = party_get_entity(_entity_key);
			
            if (!is_undefined(_entity_instance))
            {
                self.Add(_entity_instance);
            }
        }
    }
    
    #endregion
}

// -----------------------------------------------------------------------------
// API PÚBLICA PARA MANEJAR GRUPOS
// -----------------------------------------------------------------------------

/// @desc Crea una plantilla de grupo desde data y la añade a la base de datos.
/// @param {String} key La llave del grupo (ej: "HEROES").
/// @param {Struct} data El struct de datos leído del JSON.
function party_create_group_from_data(_key, _data)
{
    if (party_exists_group(_key)) return;
    
    var _group = (new PartyGroup(_key) ).FromData(_data);
	
    Systemall.__groups[$ _key] = _group;
    array_push(Systemall.__groups_keys, _key);
}

/// @desc Devuelve la plantilla de un grupo de party.
/// @param {String} key
/// @return {Struct.PartyGroup}
function party_get_group(_key)
{
    if (party_exists_group(_key) ) 
	{
        return Systemall.__groups[$ _key];
    }
	
    return undefined;
}

/// @desc Comprueba si una plantilla de grupo existe en la base de datos.
/// @param {String} key
function party_exists_group(_key)
{
    return variable_struct_exists(Systemall.__groups, _key);
}

/// @desc Intercambia todas las entidades entre dos grupos.
/// @param {String} keyA Llave del primer grupo.
/// @param {String} keyB Llave del segundo grupo.
function party_swap_groups(_keyA, _keyB)
{
    var _gA = party_get_group(_keyA);
    var _gB = party_get_group(_keyB);
    
    if (is_undefined(_gA) || is_undefined(_gB)) return;
    
    var _entitiesA = _gA.entities;
    var _entitiesB = _gB.entities;
    
    // Intercambiar los arrays de entidades
    _gA.entities = _entitiesB;
    _gB.entities = _entitiesA;
    
    // Actualizar la propiedad 'group_key' en cada entidad
    for (var i = 0; i < array_length(_gA.entities); i++) { _gA.entities[i].group_key = _gA.key; }
    for (var i = 0; i < array_length(_gB.entities); i++) { _gB.entities[i].group_key = _gB.key; }
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