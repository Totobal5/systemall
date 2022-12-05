/// @param {String} groupKey
function PartyGroup(_key) constructor
{
	key = _key;
	limit   = -1;
	entitys = [];

	#region METHODS

	#region Set new functions
	/// @param {Function} event_add
	static setNewAdd = function(_METHOD) 
	{
		add = method(,_METHOD);
		return self;
	}
	
	
	/// @param {Function} event_delete
	static setNewRemove = function(_METHOD) 
	{
		remove = method(,_METHOD);
		return self;
	}
	
	
	/// @param {Function} foreach_method
	static setNewFind = function(_METHOD) 
	{
		eventForeach = method(,_METHOD);
		return self;
	}
	
	#endregion
	
	static getEntitys = function() 
	{
		return entitys;
	}
	
	/// @desc Agrega una entidad al grupo indicando el indice en donde insertarlo
	/// @param {Struct.PartyEntity} partyEntity
	/// @param {Real} [index]=0
	/// @return {Bool}
	static set = function(entity, index=0)
	{
		var n = array_length(entitys);
		if (limit == -1 || n < limit)
		{
			entity.group = key;
			array_insert (entitys, index, entity);
			array_foreach(entitys, function(v,i) {v.index = i;} );
			return true;
		}
		
		return false;
	}


	/// @desc Devuelve la entidad que se encuentra en el indice
	/// @param {Real} [index]=0
	static get = function(_index=0)
	{
		return (entitys[_index] );
	}


	/// @desc Agrega entidades a este grupo
	/// @param {Struct.PartyEntity} partyEntity
	/// @return {Bool}
	static add = function(_entity)
	{
		var n = array_length(entitys);
		if (limit == -1 || n < limit)
		{
			array_push(entitys, _entity);
			_entity.group = key;
			_entity.index = n;

			return true;
		}

		return false;
	}
	
	
	/// @desc Elimina y devuelve una entidad del grupo
	/// @param {Real} [index]=0
	static remove  = function(_index=0)
	{
		var _entity = entitys[_index]; // guardar
		array_delete(entitys, _index, 1);
		array_foreach(entitys, function(v,i) {v.index = i;} );
		_entity.group = "";
		_entity.index = -1;
		
		return _entity;
	}
	

	/// @desc Busca una entidad y devuelve su indice. -1 si no existe
	/// @param {Struct.PartyEntity} partyEntity
	static find = function(_entity)
	{
		var _num = array_find_index(entitys, method({s: _entity}, function(v, i) {
			return (s.key == v.key);
		}) );
		return _num;
	}
	
	
	static clean = function()
	{
		entitys = [];
		return self;
	}
	
	
	/// @desc Regresa un sl_struct
	static save = function()
	{
		var _this = self;
		var _s = {order:[], limit: _this.limit, key: _this.key};
		array_foreach(entitys, method(_s, function(v) {
			array_push(order, v.save() );
		}) );
		
		return _s;
	}
	
	
	/// @param {Struct} sl_struct
	static load = function(_load) 
	{
		var _key = key;
		
		// Cargar llave y limite
		key   = _load.key;
		limit = _load.limit; 
		
		with (_load) {
			array_foreach(order, function(v,i) {
				var _party = party_create(v.key, key, 1);
				_party.load(v);
			});
		}
	}
	
	#endregion
}