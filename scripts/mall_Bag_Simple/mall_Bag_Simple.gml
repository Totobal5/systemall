/// @desc Simple bag that stores items in a single list.
/// @param {String} key
function MallBagSimple(_key) : MallBag(_key) constructor
{
	/// @desc Slot capacity.
	/// @type {Real}
	slot_limit = 30;
	
	/// @desc Ordered array of item instances in this bag.
	/// @type {Array<Struct.MallItemInstance>}
	order = [];
	
	#region PRIVATE
	
	/// @ignore
	/// @desc Compares two structs and returns true when they are identical.
	/// @param {Struct} struct1
	/// @param {Struct} struct2
	/// @returns {Bool}
	static __CompareVars = function(struct1, struct2)
	{
		var _keys1 = struct_get_names(struct1);
		var _keys2 = struct_get_names(struct2);
		// If they are not the same length, they can't be identical.
		if (array_length(_keys1) != array_length(_keys2) ) return false;
		
		// Validate all keys and values.
		var i=0; repeat(array_length(_keys1) )
		{
			var _key = _keys1[i];
			// If a key is missing or value differs, structs are not equal.
			if (!struct_exists(struct2, _key) || struct1[$ _key] != struct2[$ _key] ) 
			{
				return false;
			}		
			
			i++;
		}

		return true;
	}
	
	#endregion
	
	#region API
	/// @desc Adds an item amount to the bag.
	/// @param {String} item_key The key of the item to add.
	/// @param {Real} count The amount of the item to add.
	/// @param {Struct} vars Optional struct with item variables to consider for stacking.
	/// @returns {{success: Bool, added: Real, leftover: Real}}
	static AddItem = function(_item_key, _count, _vars = {})
	{
		var _default = { success: false, added: 0, leftover: _count };
		if (_count <= 0) return _default;
		
		var _item_template = mall_get_item(_item_key);
		if (is_undefined(_item_template) ) { return _default; }

		var _is_stackable = _item_template[$ "is_stackable"];
		var _stack_limit = _item_template[$ "stack_limit"];
		
		var _result = { success: false, added: 0, leftover: 0 };
		var _amount_to_add = _count;
		
		// Stackable items.
		if (_is_stackable)
		{
			// Fill existing stacks first.
			var i=0; repeat(array_length(order) )
			{
				var _inst = order[i++];
				if (_inst.key == _item_key && __CompareVars(_inst.vars, _vars) )
				{
					var _can_add = _stack_limit - _inst.count;
					var _to_add_here = min(_amount_to_add, _can_add);
					
					if (_to_add_here > 0) 
					{
						_inst.count		+= _to_add_here;
						_result.added	+= _to_add_here;
						_amount_to_add	-= _to_add_here;
					}
				}
				
				if (_amount_to_add <= 0) break;
			}
			
			// Create new stacks for remaining quantity.
			while (_amount_to_add > 0 && array_length(order) < slot_limit)
			{
				var _to_add_here =	min(_amount_to_add, _stack_limit);
				var _new_instance = new MallItemInstance(_item_key, _to_add_here, variable_clone(_vars));
				array_push(order, _new_instance);
				
				_result.added	+= _to_add_here;
				_amount_to_add	-= _to_add_here;
			}
		}
		// Non-stackable items.
		else
		{
			// Add one by one for non-stackable items.
			while (_amount_to_add > 0 && array_length(order) < slot_limit)
			{
				// Reject duplicates with same key and vars.
				var _already_exists = false;
				var i=0; repeat(array_length(order) )
				{
					var _inst = order[i++];
					if (_inst.key == _item_key && __CompareVars(_inst.vars, _vars) ) 
					{
						_already_exists = true;
						break;
					}
				}
				
				// Same instance already exists.
				if (_already_exists) break;
				
				// Add a new instance.
				var _new_instance = new MallItemInstance(_item_key, 1, variable_clone(_vars) );
				array_push(order, _new_instance);
				_result.added++;
				_amount_to_add--;
			}
		}
		
		_result.leftover =	_amount_to_add;
		_result.success =	_result.added > 0;
		
		if (_result.success && is_callable(event_on_add_item) ) 
		{
			event_on_add_item(_item_key, _result.added, args);
		}
		
		return _result;
	}
	
	/// @desc Removes an item amount from the bag.
	/// @param {String} item_key The key of the item to remove.
	/// @param {Real} count The amount of the item to remove.
	/// @param {Struct} vars Optional struct with item variables to consider for matching.
	/// @returns {Bool} True if any items were removed, false otherwise.
	static RemoveItem = function(_item_key, _count, _vars = {})
	{
		if (_count <= 0) return false;
		var _amount_to_remove = _count;
		
		// Iterate backwards to allow safe deletes.
		for (var i = array_length(order) - 1; i >= 0; i--)
		{
			var _inst = order[i];
			if (_inst.key == _item_key && __CompareVars(_inst.vars, _vars) )
			{
				var _removed_here =		min(_amount_to_remove, _inst.count);
				_inst.count -=			_removed_here;
				_amount_to_remove -=	_removed_here;
				
				if (_inst.count <= 0) array_delete(order, i, 1);
			}
			
			if (_amount_to_remove <= 0) break;
		}
		
		var _total_removed = _count - _amount_to_remove;
		if (_total_removed > 0 && is_callable(event_on_remove_item) )
		{
			event_on_remove_item(_item_key, _total_removed, args);
		}
		
		return (_total_removed > 0);
	}
	
	/// @desc Returns total amount for a specific item key.
	/// @param {String} item_key The key of the item to count.
	/// @returns {Real} Total amount of the item in the bag.
	static GetItemCount = function(_item_key)
	{
		var _total = 0;
		var _length = array_length(order);
		
		var i=0; repeat(_length) 
		{
			if (order[i].key == _item_key) {_total += order[i].count; }
			i++;
		}
		
		return _total;
	}

	/// @desc Returns all item instances.
	/// @returns {Array<Struct.MallItemInstance>} An array of item instance structs with key, count and vars.
	static GetOrderedItems = function() 
	{ 
		return order; 
	}
	
	/// @desc Returns the first item instance by key.
	/// @param {String} item_key The key of the item to find.
	/// @returns {Struct.MallItemInstance|undefined} An item instance struct with key, count and vars, or undefined if not found.
	static GetItemByKey = function(_key)
	{
		var i = 0; repeat(array_length(order))
		{
			var _inst = order[i++];
			if (_inst.key == _key) return _inst;
		}
		
		return undefined;
	}
	
	/// @desc Returns an item instance by inventory index.
	/// @param {Real} index The index of the item to find.
	/// @returns {Struct.MallItemInstance|undefined} An item instance struct with key, count and vars, or undefined if not found.
	static GetItemByIndex = function(_index)
	{
		return (_index >= 0 && _index < array_length(order) ) ? order[_index] : undefined;	
	}
	
	/// @desc Configures the bag from a data struct.
	/// @param {Struct} data The data struct to configure the bag with.
	/// @returns {Struct.MallBagSimple} The configured bag instance.
	static FromData = function(_data)
	{
		// Call parent implementation.
		method(self, MallBag.FromData)(_data);
		slot_limit = _data[$ "slot_limit"] ?? 30;
		
		return self;
	}
	
	/// @desc Exports bag state to a struct.
	/// @returns {Struct}
	static Export = function()
	{
		var _export_data = method(self, Mall.Export)();
		
		_export_data.order = [];
		var i=0; repeat(array_length(order) )
		{
			array_push(_export_data.order, order[i++].Export() );
		}
		
		return _export_data;
	}
	
	/// @desc Imports bag state from a struct.
	/// @param {Struct} data The struct containing saved bag state.
	/// @returns {undefined}
	static Import = function(_data)
	{
		method(self, Mall.Import)(_data);
		order = [];
		
		var _saved_order = _data[$ "order"] ?? [];
		var i=0; repeat(array_length(_saved_order) )
		{
			var _item_data = _saved_order[i++];
			array_push(order, new MallItemInstance(_item_data[$ "key"], _item_data[$ "count"], _item_data[$ "vars"] ?? {}) );			
		}
	}

	/// @desc Creates a new instance of this simple bag template.
	/// @param {String} instance_key The key for the new bag instance.
	/// @returns {Struct.MallBagSimple} A new instance of MallBagSimple configured from this template.
	static CreateInstance = function(_instance_key)
	{
		var _new_inst = new MallBagSimple(_instance_key);
		// Here, 'self' is the template.
		_new_inst.FromData(self);
		
		return _new_inst;
	}
	
	#endregion
}