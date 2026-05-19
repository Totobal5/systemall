/// @desc Defines a collection of entities, such as the player party or an enemy group.
/// @param {String} key Group key.
function MallEntityGroup(_key) : Mall(_key) constructor
{
	/// @desc Maximum number of entities allowed in this group. Use -1 for no limit.
	/// @type {Real}
	limit = -1;
	
	/// @desc Active entity instances contained in this group.
	/// @type {Array<Struct.MallEntity>}
	entities = [];
	
	/// @desc Defeated entity instances moved out of the active list.
	/// @type {Array<Struct.MallEntity>}
	defeated_entities = [];
	
	/// @desc Whether this group state should be persisted.
	/// @type {Bool}
	is_persistent = false;
	
	#region METHODS
	
	/// @desc Adds an entity to the end of the group if there is available space.
	/// @param {Struct.MallEntity} entity Entity to add.
	/// @returns {Bool}
	static Add = function(_entity)
	{
		if (!is_struct(_entity))
		{
			__mall_error($"MallEntityGroup.Add: received an invalid entity (not a struct) in group '{key}'.");
			return false;
		}
		var _size = array_length(entities);
		if (limit == -1 || _size < limit) 
		{
			array_push(entities, _entity);
			_entity.group_key = key;
			return true;
		}
		return false;
	}
	
	/// @desc Inserts an entity at a specific index in the group.
	/// @param {Struct.MallEntity} entity Entity to insert.
	/// @param {Real} [index]=0 Index where the entity should be inserted.
	/// @returns {Bool}
	static Set = function(_entity, _index=0)
	{
		if (!is_struct(_entity))
		{
			__mall_error($"MallEntityGroup.Set: received an invalid entity (not a struct) in group '{key}'.");
			return false;
		}
		var _size = array_length(entities);
		if (limit == -1 || _size < limit)
		{
			_entity.group_key = key;
			array_insert(entities, _index, _entity);
			return true;
		}
		return false;
	}
	
	/// @desc Removes and returns an entity from the group by index.
	/// @param {Real} [index]=0
	/// @returns {Struct.MallEntity|undefined}
	static Remove = function(_index=0)
	{
		if (_index < 0 || _index >= array_length(entities)) return undefined;
		
		var _entity = entities[_index];
		array_delete(entities, _index, 1);
		
		_entity.group_key = "";
		return _entity;
	}
	
	/// @desc Finds an entity by instance and removes it from the group.
	/// @param {Struct.MallEntity} entity Entity to remove.
	/// @returns {Struct.MallEntity|undefined}
	static RemoveByInstance = function(_entity)
	{
		var _index = array_get_index(entities, _entity);
		if (_index > -1)
		{
			return self.Remove(_index);
		}
		return undefined;
	}
	
	/// @desc Clears all active and defeated entities from the group.
	/// @returns {Struct.MallEntityGroup}
	static Clean = function()
	{
		for (var i = 0; i < array_length(entities); i++) {
			entities[i].group_key = "";
		}
		entities = [];
		defeated_entities = [];
		return self;
	}
	
	/// @desc Moves an entity from the active list into the defeated list.
	/// @param {Struct.MallEntity} entity Entity instance to move.
	/// @returns {Bool} True when the entity was found and moved.
	static MarkAsDefeated = function(_entity)
	{
		var _index = array_get_index(entities, _entity);
		if (_index > -1)
		{
			array_delete(entities, _index, 1);
			array_push(defeated_entities, _entity);
			return true;
		}
		return false;
	}
	
	#endregion
	
	#region ACCESSORS
	
	/// @desc Returns the entity stored at the given index.
	/// @param {Real} [index]=0
	/// @returns {Struct.MallEntity|undefined}
	static Get = function(_index=0)
	{
		if (_index < 0 || _index >= array_length(entities)) return undefined;
		return entities[_index];
	}
	
	/// @desc Returns the full array of active entities.
	/// @returns {Array<Struct.MallEntity>}
	static GetEntities = function() 
	{
		return entities;
	}
	
	/// @desc Returns the number of active entities in the group.
	/// @returns {Real}
	static Size = function()
	{
		return array_length(entities);
	}

	/// @desc Returns the defeated entities stored for this group.
	/// @returns {Array<Struct.MallEntity>}
	static GetDefeated = function()
	{
		return defeated_entities;
	}

	#endregion
	
	#region CONFIGURATION AND SAVE
	
	/// @desc Configures the group from a data struct.
	/// @param {Struct} data Struct containing the group data.
	/// @returns {Struct.MallEntityGroup}
	static FromData = function(_data)
	{
		limit = _data[$ "limit"] ?? -1;
		return self;
	}
	
	/// @desc Exports the group state to a struct for saving.
	/// @returns {Struct}
	static Export = function()
	{
		var _export_data = method(self, Mall.Export)();
		_export_data.entity_ids = [];
		
		// Save only runtime ids for entity references.
		for (var i = 0; i < array_length(entities); i++)
		{
			array_push(_export_data.entity_ids, entities[i].id);
		}
		
		return _export_data;
	}
	
	/// @desc Imports and restores the group state from a saved struct.
	/// @param {Struct} import_data Saved group data.
	/// @returns {undefined}
	static Import = function(_import_data)
	{
		method(self, Mall.Import)(_import_data);
		
		Clean();
		
		// Restore entities by resolving their runtime ids through the instance registry.
		var _entity_ids = _import_data[$ "entity_ids"] ?? [];
		for (var i = 0; i < array_length(_entity_ids); i++)
		{
			var _id = _entity_ids[i];
			var _entity_instance = mall_get_instance(_id);
			
			if (!is_undefined(_entity_instance) )
			{
				self.Add(_entity_instance);
			}
		}
	}
	
	#endregion
}