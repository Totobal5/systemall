/// @ignore
/// @desc Internal compartment used by complex bag categories.
function __MallCategorySlot(_slot_limit) constructor
{
	/// Maximum item count for this category.
	/// @type {Real}
	slot_limit = _slot_limit;
	/// Items currently in this category, indexed by item key.
	/// @type {Struct}
	items = {};
	/// Array to track item order within the category. Each entry is { key: item_key, count: item_count }.
	/// @type {Array<Struct.MallItemInstance>}
	order =	[];
	/// Arguments for event callbacks. Shared with parent bag.
	/// @type {Struct}
	args =	{};

	#region PRIVATE
	static __CompareVars =	MallBagSimple.__CompareVars;
	
	#endregion
	
	#region API
	static AddItem =		MallBagSimple.AddItem;
	static RemoveItem =		MallBagSimple.RemoveItem;
	static GetItemCount =	MallBagSimple.GetItemCount;
	static GetItemByKey =	MallBagSimple.GetItemByKey;
	static GetItemByIndex = MallBagSimple.GetItemByIndex;
	
	/// @desc Exports the category slot state to a struct.
	/// @returns {Struct} Struct with the category slot data.
	static Export = function() 
	{ 
		return { items: items, order: order }; 
	}
	
	/// @desc Imports the category slot state from a struct.
	/// @param {Struct} data Struct with the category slot data.
	/// @returns {undefined}
	static Import = function(_data)
	{ 
		items = _data[$ "items"] ?? {}; 
		order = _data[$ "order"] ?? []; 
	}
	
	#endregion
}

/// @desc Complex bag that groups items by type.
/// @param {String} key
function MallBagComplex(_key) : MallBag(_key) constructor
{
	/// Objects in the bag are grouped into categories, which are managed separately.
	/// @type {Struct}
	categories = {};
	/// Default limits for each category type. Each key is a category name, and its value is an object with limit properties (e.g. slot_limit).
	/// @type {Struct}
	category_defaults = { slot_limit: 30 };
	/// Optional overrides for specific categories.
	/// @type {Struct}
	category_overrides = {};
	
	#region PRIVATE
	
	/// @ignore
	/// @desc Gets or creates a category compartment.
	/// @param {String} type The category type.
	/// @returns {Struct}
	static __GetCategory = function(_type)
	{
		if (!struct_exists(categories, _type) )
		{
			var _limits = struct_exists(category_overrides, _type)
				? category_overrides[$ _type]
				: category_defaults;
			if (!is_struct(_limits) ) _limits = category_defaults;
			
			var _category = new __MallCategorySlot(_limits[$ "slot_limit"]);
			categories[$ _type] = _category;
			
			// Mirror parent bag events.
			_category[$ "event_on_add_item"] = self.event_on_add_item;
			_category[$ "event_on_remove_item"] = self.event_on_remove_item;

			// Share callback args context.
			_category[$ "args"] = self.args;
		}
		
		return (categories[$ _type] );
	}
	
	#endregion
	
	#region API
	/// @desc Adds an item amount to the correct category.
	/// @param {String} item_key The key of the item to add.
	/// @param {Real} count The amount of the item to add.
	/// @param {Struct} vars Optional struct with item variables to consider for stacking.
	/// @returns {{success: Bool, added: Real, leftover: Real}}
	static AddItem = function(_item_key, _count, _vars = {})
	{
		/// @ignore
		var __default = { success: false, added: 0, leftover: _count };

		var _item_template = mall_get_item(_item_key);
		
		if (is_undefined(_item_template) )
		{
			__mall_alert($"Pocket (AddItem): item template '{_item_key}' does not exist.");
			return __default;
		}
		
		// Determine category and delegate addition to it.
		var _item_type = _item_template[$ "item_type"];
		var _category_slot = __GetCategory(_item_type);
		var _add_item = _category_slot[$ "AddItem"];
		var _result = __default;

		// If the category slot has an AddItem method, call it. Otherwise, return failure.
		if (is_callable(_add_item) ) { _result = method(_category_slot, _add_item)(_item_key, _count, _vars); }
		
		return _result;
	}
	
	/// @desc Removes an item amount from its category.
	/// @param {String} item_key The key of the item to remove.
	/// @param {Real} count The amount of the item to remove.
	/// @param {Struct} vars Optional struct with item variables to consider for matching.
	/// @returns {Bool}
	static RemoveItem = function(_item_key, _count, _vars = {})
	{
		var _item_template = mall_get_item(_item_key);
		
		if (is_undefined(_item_template) ) 
		{
			__mall_alert($"Pocket (RemoveItem): item template '{_item_key}' does not exist.");
			return false;
		}
		
		var _item_type = _item_template[$ "item_type"];
		var _category_slot = __GetCategory(_item_type);
		var _remove_item = _category_slot[$ "RemoveItem"];
		if (is_callable(_remove_item) && method(_category_slot, _remove_item)(_item_key, _count, _vars) ) 
		{
			return true;
		}
		
		return false;
	}

	/// @desc Returns the total amount for an item in its category.
	/// @param {String} item_key The key of the item to count.
	/// @returns {Real} Total amount of the item in the bag.
	static GetItemCount = function(_item_key)
	{
		var _item_template = mall_get_item(_item_key);
		if (is_undefined(_item_template) )
		{
			__mall_alert($"Pocket (GetItemCount): item template '{_item_key}' does not exist.");
			return 0;
		}
		
		var _type = _item_template[$ "item_type"];
		if (struct_exists(categories, _type) )
		{
			var _get_item_count = categories[$ _type][$ "GetItemCount"];
			return is_callable(_get_item_count) ? method(categories[$ _type], _get_item_count)(_item_key) : 0;
		}
		
		return 0;
	}
	
	/// @desc Returns the first item instance by key.
	/// @param {String} item_key The key of the item to find.
	/// @returns {Struct.MallItemInstance|undefined} An item instance struct with key, count and vars, or undefined if not found.
	static GetItemByKey = function(_item_key)
	{
		var _item_template = mall_get_item(_item_key);
		if (is_undefined(_item_template) )
		{
			__mall_alert($"Pocket (GetItemByKey): item template '{_item_key}' does not exist.");
			return undefined;
		}

		var _type = _item_template[$ "item_type"];
		if (struct_exists(categories, _type) ) 
		{
			var _get_item_by_key = categories[$ _type][$ "GetItemByKey"];
			return is_callable(_get_item_by_key) ? method(categories[$ _type], _get_item_by_key)(_item_key) : undefined;
		}
		
		return undefined;
	}
	
	/// @desc Returns an item instance by index within a category.
	/// @param {String} category The category type to look into.
	/// @param {Real} index The index of the item within the category.
	/// @returns {Struct.MallItemInstance|undefined} An item instance struct with key, count and vars, or undefined if not found.
	static GetItemByIndexInCategory = function(_category, _index)
	{
		if (struct_exists(categories, _category) )
		{
			return categories[$ _category].GetItemByIndex(_index);
		}

		__mall_alert($"Pocket (GetItemByIndexInCategory): category '{_category}' does not exist.");
		
		return undefined;
	}
	
	/// @desc Returns all item instances for a category.
	/// @param {String} type The category type to look into.
	/// @returns {Array<Struct.MallItemInstance>} An array of item instance structs with key, count and vars, or an empty array if no items are found.
	static GetItemsByCategory = function(_type)
	{
		if (struct_exists(categories, _type) ) 
		{
			return categories[$ _type].order;
		}

		__mall_alert($"Bag (GetItemsByCategory): category '{_type}' does not exist.");
		
		return [];
	}
	
	/// @desc Returns all category keys currently in use.
	/// @returns {Array<String>} An array of category keys.
	static GetAllCategories = function()
	{
		return (struct_get_names(categories) );
	}
	
	/// @desc Configures the bag from a data struct.
	/// @param {Struct} data The data struct to configure the bag with.
	/// @returns {Struct.MallBagComplex}
	static FromData = function(_data)
	{
		static __default = { slot_limit: 30 };
		
		// Call parent implementation.
		method(self, MallBag.FromData)(_data);
		
		category_defaults  = variable_clone(_data[$ "category_defaults"]  ?? __default);
		category_overrides = variable_clone(_data[$ "category_overrides"] ?? {});
		if (struct_exists(_data, "category_defaults") && !is_struct(category_defaults) )
		{
			__mall_alert("Pocket bag category_defaults must be a struct. Falling back to defaults.");
			category_defaults = variable_clone(__default);
		}
		if (!is_struct(category_overrides)) category_overrides = {};
		
		return self;
	}
	
	/// @desc Exports bag state to a struct.
	/// @returns {Struct}
	static Export = function()
	{
		var _export_data = method(self, Mall.Export)();
		_export_data.categories = {};
		
		var _category_keys = struct_get_names(categories);
		var i=0; repeat(array_length(_category_keys) )
		{
			var _key = _category_keys[ i++ ];
			_export_data.categories[$ _key] = categories[$ _key].Export(); 	
		}
		
		return _export_data;
	}
	
	/// @desc Imports bag state from a struct.
	/// @param {Struct} data The data struct to import the bag state from.
	/// @returns {undefined}
	static Import = function(_data)
	{
		method(self, Mall.Import)(_data);
		categories = {};
		
		if (struct_exists(_data, "categories") )
		{
			var _saved_categories = _data[$ "categories"];
			var _category_keys = struct_get_names(_saved_categories);
			
			var i=0; repeat(array_length(_category_keys) )
			{
				var _key = _category_keys[ i++ ];
				
				// Create category slot with configured limits.
				var _category_slot = __GetCategory(_key);
				var _import_category = _category_slot[$ "Import"];
				if (is_callable(_import_category)) method(_category_slot, _import_category)(_saved_categories[$ _key]);
			}
		}
	}

	/// @desc Creates a new instance of this complex bag template.
	/// @param {String} instance_key The key for the new bag instance.
	/// @returns {Struct.MallBagComplex} A new instance of MallBagComplex configured from this template.
	static CreateInstance = function(_instance_key)
	{
		var _new_inst = new MallBagComplex(_instance_key);
		// Here, 'self' is the template.
		_new_inst.FromData(self);
		
		return _new_inst;
	}
	
	#endregion
}