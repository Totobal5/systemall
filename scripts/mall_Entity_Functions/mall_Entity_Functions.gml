/// @desc Creates an entity template from data and stores it in the runtime database.
/// @param {String} key Unique entity template key.
/// @param {Struct} data Raw entity template data.
/// @returns {undefined}
function mall_create_entity_template(_key, _data)
{
	/// @ignore
	/// @returns {undefined}
	static __merge = function(_dest, _source) 
	{
		var _keys = variable_struct_get_names(_source);
		var _len = array_length(_keys);
		
		for (var i = 0; i < _len; i++)
		{
			var _key = _keys[i];
			var _val = _source[$ _key];
			
			if (is_struct(_val) && variable_struct_exists(_dest, _key) && is_struct(_dest[$ _key]))
			{
				__merge(_dest[$ _key], _val);
			}
			else
			{
				_dest[$ _key] = variable_clone(_val);
			}
		}
	}
	
	if (struct_exists(__Systemall.__entities, _key) )
	{
		__mall_alert($"Entity template '{_key}' already exists. Duplicate was skipped.");
		return;
	}
	
	// Merge with parent template when one is declared.
	if (struct_exists(_data, "parent") )
	{
		var _parent_key = _data[$ "parent"];
		if (mall_exists_entity_template(_parent_key) )
		{
			// Clone parent template payload.
			var _parent_data = variable_clone(__Systemall.__entities[$ _parent_key]);
			
			// Apply child overrides.
			__merge(_parent_data, _data);
			
			// Remove inheritance key from final template.
			struct_remove(_parent_data, "parent");
			
			_data = _parent_data;
		}
	}
	
	// Store template payload.
	__Systemall.__entities[$ _key] = _data;
	array_push(__Systemall.__entities_keys, _key);
}

/// @desc Returns whether an entity template exists.
/// @param {String} _key Entity template key.
/// @return {Bool}
function mall_exists_entity_template(_key) 
{
	return (struct_exists(__Systemall.__entities, _key) ); 
}

/// @desc Creates an entity instance from a template key.
/// @param {String} _template_key Template key (for example "JON" or "SLIME").
/// @param {Real} [_level=1] Initial level for the new instance.
/// @param {Struct} [_args={}] Optional runtime argument payload.
/// @returns {Struct.MallEntity|undefined}
function mall_entity_create_instance(_template_key, _level=1, _args = {})
{
	if (!mall_exists_entity_template(_template_key) )
	{
		__mall_error($"Attempted to create an instance from a missing entity template: '{_template_key}'");
		return undefined;
	}
	
	// Create a runtime-unique id for the instance.
	var _instance_id = $"{_template_key}_{get_timer()}"; 
	
	var _entity = new MallEntity(_template_key, _instance_id);
	_entity.args = _args;
	_entity.FromTemplate();
	_entity.level = _level;
	_entity.RecalculateStats();
	
	return _entity;
}

/// @ignore
/// @desc Registers an entity instance in the global runtime registry.
/// @param {Struct.MallEntity} _entity Entity instance to register.
/// @returns {undefined}
function __mall_register_instance(_entity)
{
	if (is_struct(_entity) && struct_exists(_entity, "id") )
	{
		__Systemall.__instances[$ _entity.id] = _entity;
	}
}

/// @ignore
/// @desc Unregisters an entity instance from the global runtime registry.
/// @param {Struct.MallEntity} _entity Entity instance to unregister.
/// @returns {undefined}
function __mall_unregister_instance(_entity)
{
	if (is_struct(_entity) && struct_exists(_entity, "id") )
	{
		struct_remove(__Systemall.__instances, _entity.id);
	}
}

/// @desc Gets an entity instance by its unique runtime id.
/// @param {String} _id Runtime instance id.
/// @returns {Struct.MallEntity|undefined} The entity instance, or undefined when missing.
function mall_get_instance(_id)
{
	return (__Systemall.__instances[$ _id] );
}

/// @desc Safely removes an entity from its group and runtime registry.
/// @param {Struct.MallEntity} _entity Entity instance to destroy.
/// @returns {Bool}
function mall_entity_destroy(_entity)
{
	if (!is_struct(_entity) || !struct_exists(_entity, "id"))
	{
		__mall_error("mall_entity_destroy expected a valid MallEntity struct.");
		return false;
	}

	if (struct_exists(_entity, "group_key") && _entity.group_key != "")
	{
		var _group = mall_get_group(_entity.group_key);
		if (is_struct(_group))
		{
			_group.RemoveByInstance(_entity);
		}
	}

	__mall_unregister_instance(_entity);
	return true;
}

/// @desc Creates a group template from data and stores it in the runtime database.
/// @param {String} _key Unique group template key.
/// @param {Struct} _data Raw group template data.
/// @returns {undefined}
function mall_create_group_from_data(_key, _data)
{
	if (!__mall_validate_registry_args("mall_create_group_from_data", _key, _data, mall_exists_group, "Group")) return;
	
	var _group = (new MallEntityGroup(_key) ).FromData(_data);
	
	__Systemall.__groups[$ _key] = _group;
	array_push(__Systemall.__groups_keys, _key);
}

/// @desc Returns a group template by key.
/// @param {String} _key Group template key.
/// @returns {Struct.MallEntityGroup|undefined}
function mall_get_group(_key)
{
	if (mall_exists_group(_key) ) 
	{
		return __Systemall.__groups[$ _key];
	}
	
	return undefined;
}

/// @desc Returns whether a group template exists.
/// @param {String} _key Group template key.
/// @returns {Bool}
function mall_exists_group(_key)
{
	return variable_struct_exists(__Systemall.__groups, _key);
}

/// @desc Swaps all entities between two groups.
/// @param {String} _group_key_a First group key.
/// @param {String} _group_key_b Second group key.
/// @returns {undefined}
function mall_swap_groups(_group_key_a, _group_key_b)
{
	var _group_a = mall_get_group(_group_key_a);
	var _group_b = mall_get_group(_group_key_b);
	
	if (is_undefined(_group_a) || is_undefined(_group_b)) return;
	
	var _entities_a = _group_a.entities;
	var _entities_b = _group_b.entities;
	
	// Swap entity arrays.
	_group_a.entities = _entities_b;
	_group_b.entities = _entities_a;
	
	// Refresh each entity group key.
	for (var i = 0; i < array_length(_group_a.entities); i++) { _group_a.entities[i].group_key = _group_a.key; }
	for (var i = 0; i < array_length(_group_b.entities); i++) { _group_b.entities[i].group_key = _group_b.key; }
}

/// @desc Clears all entities from a group.
/// @param {String} _key Group key.
/// @returns {Struct.MallEntityGroup|undefined}
function mall_group_clean(_key) 
{
	var _group_instance = mall_get_group(_key);
	return (!is_undefined(_group_instance) ) ? _group_instance.Clean() : undefined;
}

/// @desc Returns all entities in a group.
/// @param {String} _key Group key.
/// @returns {Array<Struct.MallEntity>|undefined}
function mall_group_get_entities(_key)
{
	var _group_instance = mall_get_group(_key);
	return (!is_undefined(_group_instance) ) ? _group_instance.GetEntities() : undefined;
}

/// @desc Returns the entity at a specific group index.
/// @param {String} _key Group key.
/// @param {Real} [_index=0] Target entity index.
/// @returns {Struct.MallEntity|undefined}
function mall_group_get(_key, _index=0)
{
	var _group_instance = mall_get_group(_key);
	return (!is_undefined(_group_instance) ) ? _group_instance.Get(_index) : undefined;
}

/// @desc Adds one entity to the end of a group.
/// @param {String} _key Group key.
/// @param {Struct.MallEntity} _entity Entity to add.
/// @returns {Bool}
function mall_group_add(_key, _entity)
{
	var _group_instance = mall_get_group(_key);
	// Delegate insertion to group rules.
	if (!is_undefined(_group_instance) ) 
	{
		return (_group_instance.Add(_entity) ); 
	}
	
	return false;
}

/// @desc Sets one entity into a group at a target index.
/// @param {String} _key Group key.
/// @param {Struct.MallEntity} _entity Entity to set.
/// @param {Real} [_index=0] Target index.
/// @returns {Bool}
function mall_group_set(_key, _entity, _index=0)
{
	var _group_instance = mall_get_group(_key);
	return (!is_undefined(_group_instance) ) ? _group_instance.Set(_entity, _index) : false;
}

/// @desc Finds the first entity in a group matching a predicate.
/// @param {String} _key Group key.
/// @param {Function} _fn Predicate callback function(value, i).
/// @returns {Struct.MallEntity|undefined}
function mall_group_filter(_key, _fn)
{
	var _group_instance = mall_get_group(_key);
	if (is_undefined(_group_instance) ) return undefined;
	
	var _entities = _group_instance.entities;
	
	var _index = array_find_index(_entities, _fn);
	// Return undefined when no match is found.
	return (_index != -1) ? _entities[_index] : undefined;
}

/// @desc Finds the index of the first entity in a group matching a predicate.
/// @param {String} _key Group key.
/// @param {Function} _fn Predicate callback function(value, i).
/// @returns {Real}
function mall_group_filter_index(_key, _fn)
{
	var _party = mall_get_group(_key);
	if (is_undefined(_party) ) return -1;
	
	var _entities = _party.entities;
	return (array_find_index(_entities, _fn) );
}

/// @desc Returns the number of entities in a group.
/// @param {String} _key Group key.
/// @returns {Real}
function mall_group_size(_key)
{
	var _party = mall_get_group(_key);
	if (is_undefined(_party) ) return 0;
	
	var _entities = _party.entities;
	return (array_length(_entities) );
}

/// @desc Exports a group payload.
/// @param {String} _key Group key.
/// @param {Bool} [_struct=false] When true returns struct payload; otherwise returns JSON/string payload.
/// @returns {Struct|String|undefined}
function mall_group_export(_key, _struct=false)
{
	var _party = mall_get_group(_key);
	return (!is_undefined(_party) ) ? _party.Export(_struct) : undefined;
}

/// @desc Imports group data from struct or JSON payload.
/// @param {String} _key Group key.
/// @param {Struct|String} _json Import payload.
/// @returns {undefined}
function mall_group_import(_key, _json)
{
	var _party = mall_get_group(_key);
	if (!is_undefined(_party) ) _party.Import(_json);
}

/// @desc Finds the first entity in a group matching a predicate and returns both the entity and index.
/// @param {String} _key Group key.
/// @param {Function} _fn Predicate callback function(value, i).
/// @returns {{entity: Struct.MallEntity, index: Real}|undefined}
function mall_group_foreach(_key, _fn)
{
	var _group = mall_get_group(_key);
	if (!is_undefined(_group) ) 
	{
		var _index = array_find_index(_group.entities, _fn);
		return (_index != -1) ?
			{entity: _group.entities[_index], index: _index} :
			undefined;
	}
	
	return undefined;
}