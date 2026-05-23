/// @desc Simple bag that stores items in a single list.
/// @param {String} key
function MallBagSimple(_key) : MallBag(_key) constructor
{
	/// @type {Array<Struct.MallItemInstance>} Ordered array of item instances in this bag.
	order = [];
	
	#region PRIVATE API

	/// @ignore
	/// @desc Prepares a default result struct for add/remove operations.
	static __PrepareResult = function(_add_or_remove)
	{
		var _result = new MallResult(false);
		_result.SetVar(!_add_or_remove ? "added" : "removed", 0);
		_result.SetVar("leftover", 0);

		return _result;
	}

	#endregion

	#region API

	/// @desc Adds an item amount to the bag.
	/// Return a result struct with success flag, amount actually added and leftover amount that couldn't be added due to capacity limits.
	/// @param {String} item_key The key of the item to add.
	/// @param {Real} count The amount of the item to add.
	/// @param {Struct} vars Optional struct with item variables to consider for stacking.
	/// @returns {Struct.MallResult}
	static AddItem = function(_item_key, _count, _vars = {})
	{
		var _result = __PrepareResult(false);
		if (_count <= 0) return _result;

		// Check if item exists in the database.
		var _item_template = mall_get_item(_item_key);
		if (is_undefined(_item_template) ) { return _result; }

		var _is_stackable = _item_template[$ "is_stackable"];
		var _stack_limit = _item_template[$ "stack_limit"];
		var _amount_to_add = _count;
		
		// Stackable items.
		if (_is_stackable)
		{
			// Fill existing stacks first.
			var i=0; repeat(array_length(order) )
			{
				/// @type {Struct.MallItemInstance}
				var _inst = order[i++];
				// Check for same item key and same vars for stacking.
				if (_inst.key == _item_key && _inst.SameVars(_vars) )
				{
					var _can_add = _stack_limit - _inst.count;
					var _to_add_here = min(_amount_to_add, _can_add);
					
					if (_to_add_here > 0) 
					{
						_inst.count		+= _to_add_here;
						_result.SetVar("added", _result.GetVar("added") + _to_add_here);
						_amount_to_add	-= _to_add_here;
					}
				}
				
				if (_amount_to_add <= 0) break;
			}
			
			// Create new stacks for remaining quantity.
			while (_amount_to_add > 0 && array_length(order) < limit)
			{
				var _to_add_here =	min(_amount_to_add, _stack_limit);
				var _new_instance = new MallItemInstance(_item_key, _to_add_here, variable_clone(_vars));
				array_push(order, _new_instance);
				
				_result.SetVar("added", _result.GetVar("added") + _to_add_here);
				_amount_to_add	-= _to_add_here;
			}
		}
		// Non-stackable items.
		else
		{
			// Add one by one for non-stackable items.
			while (_amount_to_add > 0 && array_length(order) < limit)
			{
				// Reject duplicates with same key and vars.
				var _already_exists = false;
				var i=0; repeat(array_length(order) )
				{
					var _inst = order[i++];
					if (_inst.key == _item_key && _inst.SameVars(_vars) ) 
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
				_result.SetVar("added", _result.GetVar("added") + 1);
				_amount_to_add--;
			}
		}
		
		_result.SetVar("leftover", _amount_to_add);
		_result.success = _result.GetVar("added") > 0;

		// Execute 'Add' event if any items were actually added.
		if (_result.success ) 
		{
			var _event = method(self, mall_get_event(event_on_add_item) );
			_event(_item_key, _result.GetVar("added"), args);
		}
		
		return _result;
	}
	
	/// @desc Removes an item amount from the bag. Return True if any items were removed, false otherwise.
	/// @param {String} item_key The key of the item to remove.
	/// @param {Real} count The amount of the item to remove.
	/// @param {Struct} vars Optional struct with item variables to consider for matching.
	/// @returns {Struct.MallResult}
	static RemoveItem = function(_item_key, _count, _vars = {})
	{
		var _result = __PrepareResult(true);
		if (_count <= 0) return _result;

		var _amount_to_remove = _count;
		
		// Iterate backwards to allow safe deletes.
		for (var i = array_length(order) - 1; i >= 0; i--)
		{
			/// @type {Struct.MallItemInstance}
			var _inst = order[i];
			if (_inst.key == _item_key && _inst.SameVars(_vars) )
			{
				var _removed_here =		min(_amount_to_remove, _inst.count);
				_inst.count -=			_removed_here;
				_amount_to_remove -=	_removed_here;
				
				if (_inst.count <= 0) array_delete(order, i, 1);
			}
			
			if (_amount_to_remove <= 0) break;
		}
		
		var _total_removed = _count - _amount_to_remove;
		_result.SetVar("removed", _total_removed);
		_result.SetVar("leftover", _amount_to_remove);
		_result.success = _total_removed > 0;

		if (_result.success)
		{
			var _event = method(self, mall_get_event(event_on_remove_item) );
			_event(_item_key, _total_removed, args);
		}

		return _result;
	}
	
	/// @desc Returns total amount for a specific item key. Return the total amount of the item in the bag.
	/// @param {String} item_key The key of the item to count.
	/// @returns {Real}
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

	/// @desc Return a struct mapping each item key to its unique instance count in the bag.
	/// Unique instances are grouped by item key and variable set, regardless of stack count.
	/// @param {String} [_item_key] Optional item key to filter the result.
	/// @return {Struct} Struct with item keys and their unique counts.
	static GetItemCountUnique = function(_item_key)
	{
		var _counts = {};
		var _length = array_length(order);
		
		var i = 0; repeat(_length)
		{
			/// @type {Struct.MallItemInstance}
			var _inst = order[i];
			var _current_key = _inst.key;
			var _is_unique = true;

			for (var j = 0; j < i; j++)
			{
				/// @type {Struct.MallItemInstance}
				var _other = order[j];
				if (_other.key == _current_key && _other.SameVars(_inst.vars) )
				{
					_is_unique = false;
					break;
				}
			}

			if (_is_unique)
			{
				if (!struct_exists(_counts, _current_key)) { _counts[$ _current_key] = 0; }
				_counts[$ _current_key] += 1;
			}

			i++;
		}

		if (!is_undefined(_item_key))
		{
			var _filtered = {};
			_filtered[$ _item_key] = _counts[$ _item_key] ?? 0;
			return _filtered;
		}

		return _counts;
	}

	/// @desc Returns all item instances. Return an array of item instance structs with key, count and vars.
	/// @returns {Array<Struct.MallItemInstance>}
	static GetOrderedItems = function() 
	{ 
		return order; 
	}
	
	/// @desc Returns the first item instance by key. Return an item instance struct with key, count and vars, or undefined if not found.
	/// @param {String} item_key The key of the item to find.
	/// @returns {Struct.MallItemInstance|undefined}
	static GetItemByKey = function(_key)
	{
		var i = 0; repeat(array_length(order) )
		{
			var _inst = order[i++];
			if (_inst.key == _key) return _inst;
		}
		
		return undefined;
	}
	
	/// @desc Returns an item instance by inventory index. Return an item instance struct with key, count and vars, or undefined if not found.
	/// @param {Real} index The index of the item to find.
	/// @returns {Struct.MallItemInstance|undefined}
	static GetItemByIndex = function(_index)
	{
		return (_index >= 0 && _index < array_length(order) ) ? order[_index] : undefined;	
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

	/// @desc Configures the bag from a data struct.
	/// @param {Struct} data The data struct to configure the bag with.
	/// @returns {Struct.MallBagSimple} The configured bag instance.
	static Import = function(_data)
	{
		// Call parent implementation.
		method(self, MallBag.Import)(_data);

		// Load items in order, replacing them with proper instances.
		order = _data[$ "order"] ?? order;
		
		var i=0; repeat(array_length(order) )
		{
			var _item_data = order[i++];
			// Validate item data.
			if (!struct_exists(_item_data, "key") || !struct_exists(_item_data, "count") )
			{
				__mall_alert("Bag (Import): invalid item data struct, missing 'key' or 'count' fields.");
				continue;
			}
			
			var _item_key = _item_data[$ "key"];
			var _item_count = _item_data[$ "count"];
			var _item_vars = _item_data[$ "vars"] ?? {};
			
			AddItem(_item_key, _item_count, _item_vars);
		}

		return self;
	}

	#endregion
}