/// @param {string} wateKey
function WateManager(_key) constructor
{
	key = _key;
	// Grupos
	groups = {
		// Todas las entidades
		every: []
	};
	
	// -- Control
	// Turno en que se encuentra
	turn = 1;
	// Que puede entregar al finalizar el combate
	lootTable = [];
	
	// Que entregará al finalizar el combate
	loot      = [];
	
	preMessage = "";
	actMessage = "";
	messageArray = [];
	messageBlock = false;
	
	/// @desc Que realizar cuando termina el combate
	fnComplete = function() {};
	
	/// @desc Evento para cambiar de cuarto
	fnRoomEnter = function() {}
	
	/// @desc Evento para salir de un cuarto
	fnRoomExit  = function() {}
	
	/// @param {string} key
	/// @param {any}    value
	/// @param {real}   probability
	static createLootable = function(_key, _value, _probability) constructor 
	{
		key = _key;
		
		value = _value;
		prob  = _probability;
	}

	/// @param {string} key
	/// @param {any}    value	
	static createLoot = function(_key, _value) constructor
	{
		key = _key
		val = _value;
	}
	
	
	/// @desc Agrega entidades a este grupo
	/// @param {string}             groupKey
	/// @param {Struct.PartyEntity} partyEntity
	/// @return {Bool}
	static add  = function(_groupKey, _entity)
	{
		var n;
		if (!variable_struct_exists(groups, _groupKey) ) {
			groups[$ _groupKey] = [];
		}
		var _arr = groups[$ _groupKey];
			
		array_push(_arr, _entity);
		// Obtener indice
		_entity.index = array_length(_arr);
		_entity.group = _groupKey;
		_entity.turnManager = turn;

		// Agregar igualmente en every
		array_push(groups.every, _entity);
	}
	
	static sort = function(_groupKey, _fun) 
	{
		var _arr = groups[$ _groupKey];
		array_sort(_arr, _fun);
	}
	
	static create = function(_groupKey) {
		if (!variable_struct_exists(groups, _groupKey) ) {
			groups[$ _groupKey] = array_create(0);
		}		
	}
	
	/// @desc Function Description
	/// @param {string} itemKey      Description
	/// @param {real}   probability  Description
	static addLoot = function(_itemKey, _probability)
	{
		array_push(lootTable, new createLootable(_itemKey, _probability) );
		return self;
	}
	
	/// @param {real} [index]=0
	static removeLoot = function(_index=0)
	{
		array_delete(loot, _index, 1);
		return self;
	}
	
	static sendMessage  = function(_msg) 
	{
		static enqueueID = MallDatabase.messages;
		// Enviar mensaje
		ds_queue_enqueue(enqueueID, _msg);
	}
	
	static getMessage   = function() 
	{
		static enqueueID = MallDatabase.messages;
		if (!messageBlock) {
			var _msg = ds_queue_dequeue(enqueueID);
			preMessage = actMessage;
			actMessage = _msg;
			
			return true;
		}
		
		return false;
	}
	
	static blockMessage = function()
	{
		messageBlock = true;
		return self;
	}
	
	#region Añadir como singleton
	var _static = MallDatabase.wate;
	_static.manager = self;
	
	#endregion
}


function wateSingleton() 
{
	static manager = MallDatabase.wate.manager;
	return (manager);
}