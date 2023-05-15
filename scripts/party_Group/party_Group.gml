/// @param {String} groupKey
function PartyGroup(_key) constructor
{
	vars = {}; // Variables de este grupo
	key  = _key;
	
	size     =  0;
	limit    = -1;
	entities = [];
	
	fnAdd    = undefined;
	fnRemove = undefined;
	fnFind   = undefined;
	
	#region METHODS

	#region Set new functions
	/// @param {function} event_add
	static setNewAdd = function(_fn) 
	{
		fnAdd = method(self, _fn);
		return self;
	}
	
	
	/// @param {function} event_delete
	static setNewRemove = function(_fn) 
	{
		fnRemove = method(self, _fn);
		return self;
	}
	
	
	/// @param {function} foreach_method
	static setNewFind = function(_fn) 
	{
		fnFind = method(self, _fn);
		return self;
	}
	
	#endregion
	
	/// @desc Agrega una entidad al grupo indicando el indice en donde insertarlo
	/// @param {Struct.PartyEntity} partyEntity
	/// @param {Real} [index]=0
	/// @return {Bool}
	static set = function(entity, index=0)
	{
		static fn = function(v, i) {v.index = i; }
		size = array_length(entities);
		if (limit == -1 || size < limit) {
			entity.group = key;
			array_insert (entities, index, entity);
			array_foreach(entities, fn);
			
			return true;
		}
		
		return false;
	}

	/// @desc Agrega una entidad a este grupo colocandola al final
	/// @param {Struct.PartyEntity} partyEntity
	/// @return {Bool}
	static add = function(_entity)
	{
		if (fnAdd == undefined) {
			size = array_length(entities);
			if (limit == -1 || size < limit) {
				array_push(entities, _entity);
				_entity.group = key;
				_entity.index = size-1;
	
				return true;
			}
	
			return false;
		} else {
			fnAdd(_entity);
		}
	}

	/// @desc Devuelve la entidad que se encuentra en el indice
	/// @param {Real} [index]=0
	static get = function(_index=0)
	{
		return (entities[_index] );
	}

	/// @desc Elimina y devuelve una entidad del grupo
	/// @param {Real} [index]=0
	static remove  = function(_index=0)
	{
		static fn = function(v,i) {v.index = i; }
		// Guardar entidad en el lugar
		var _entity = entities[_index];
		
		array_delete( entities, _index, 1);
		array_foreach(entities, fn);
		
		size = array_length(entities);
		
		_entity.group = "";
		_entity.index = -1;
		
		return _entity;
	}

	/// @desc Busca una entidad y devuelve su indice. -1 si no existe
	/// @param {Struct.PartyEntity} partyEntity
	static find = function(_entity)
	{
		static fn = function(v,i) {return (s.key == v.key); }
		return (array_find_index(entities, method({s: _entity}, fn) ) );
	}
	
	/// @desc Limpia el gropo de entidades
	static clean = function()
	{
		entities = [];
		// Actualizar tamaño
		size = array_length(entities);
		
		return self;
	}
	
	/// @desc Regresa el array de entidades
	/// @return {Array<Struct.PartyEntity>}
	static getEntities = function() 
	{
		return entities;
	}
	
	
	/// @desc Establece una variable para este grupo
	/// @param {string} key
	/// @param {any}    value
	static setVar = function(_key, _value) 
	{
		vars[$ _key] = _value;
		return self;
	}

	/// @desc Obtiene el valor de una variable en este grupo
	/// @param {string} key
	static getVar = function(_key)
	{
		return (vars[$ _key] );
	}
	
	
	/// @desc Regresa un save struct
	static save = function()
	{
		static fn=function(v) {array_push(order, v.save() ); }
		var _this = self;
		var _save = {
			key :  _this.key, 
			vars:  _this.vars,
			limit: _this.limit, 
			order: []
		};
		array_foreach(entities, method(_save, fn) );
		
		return _save;
	}
	
	/// @param {struct} sl_struct
	static load = function(_load) 
	{
		static fn = function(load) /*=>*/ {
			var _party = party_create(load.key, key, 1);
			_party.load(load);
		}

		// Cargar llave y limite
		key   = _load.key;
		limit = _load.limit; 
		vars  = _load[$ "vars"] ?? {};
		
		// Cargar datos
		with (_load) array_foreach(order, fn);
	}
	

	#endregion
}