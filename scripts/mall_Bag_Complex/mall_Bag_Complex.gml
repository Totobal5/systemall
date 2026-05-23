/// @desc Complex bag that groups items by type.
/// @param {String} key
function MallBagComplex(_key) : MallBag(_key) constructor
{
	/// @type {Struct<Struct.MallBagSimple>} Objects in the bag are grouped into categories, which are managed separately.
	categories = { /* is_persistent, limit, event_on_add_item, event_on_remove_item, ... */ };
	
	/// @type {Struct} Optional overrides for specific categories.
	overrides = {};
	
	#region API

	/// @ignore
	/// @desc Resolves the primary category from an item template using the new type array format.
	/// @param {Struct} item_template The item template struct.
	/// @returns {String|undefined}
	static __ResolveCategoryFromItem = function(_item_template)
	{
		if (!is_struct(_item_template) )
		{
			__mall_error("Bag (ResolveCategory): expected an item template struct.");
			return undefined;
		}

		var _type = _item_template[$ "type"];
		if (!is_array(_type) || array_length(_type) <= 0)
		{
			var _item_key = _item_template[$ "key"] ?? "<unknown>";
			__mall_error($"Bag (ResolveCategory): item '{_item_key}' must define 'type' as a non-empty array.");
			return undefined;
		}

		var _category = _type[0];
		if (!is_string(_category) )
		{
			var _item_key_2 = _item_template[$ "key"] ?? "<unknown>";
			__mall_error($"Bag (ResolveCategory): item '{_item_key_2}' has invalid type[0]. Expected string, received: {string(_category)}");
			return undefined;
		}

		return _category;
	}
	
	/// @desc Gets or creates a category compartment.
	/// @param {String} type The category type.
	/// @returns {Struct.MallBagSimple}
	static GetCategory = function(_category)
	{
		if (!is_string(_category) )
		{
			__mall_error($"Bag (GetCategory): category must be a string. Received: {string(_category)}");
			return undefined;
		}

		var _this = self;
		var _base_limit = _this[$ "limit"];
		var _base_key = _this[$ "key"];

		if (!struct_exists(categories, _category) )
		{
			var _limits = struct_exists(overrides, _category)
				? (overrides[$ _category][$ "limit"] ?? _base_limit)
				: _base_limit;
			// Create a new bag compartment for this category.
			// Using 'self' as a template to load category-specific events and settings.
			/// @type {Struct.MallBagSimple}
			var _category_bag = new MallBagSimple(_base_key + "_" + _category);
			_category_bag.limit = _limits;

			categories[$ _category] = _category_bag;

			if (__MALL_BAG_ALERT) { __mall_alert($"Created new bag category '{_category}' with limit { _limits }."); }
		}

		return (categories[$ _category] );
	}

	/// @desc Adds an item amount to the correct category.
	/// Return A result struct with success flag, amount actually added and leftover amount that couldn't be added due to capacity limits.
	/// @param {String} item_key The key of the item to add.
	/// @param {Real} count The amount of the item to add.
	/// @param {Struct} vars Optional struct with item variables to consider for stacking.
	/// @returns {Struct.MallResult}
	static AddItem = function(_item_key, _count, _vars = {})
	{
		// Prepare 
		var _item_template = mall_get_item(_item_key);
		if (is_undefined(_item_template) ) 
		{
			__mall_alert($"Bag (AddItem): item template '{_item_key}' does not exist.");
			return MallBagSimple.__PrepareResult(false);
		}

		// Get item category and delegate to the correct category slot.
		var _item_category = __ResolveCategoryFromItem(_item_template);
		if (is_undefined(_item_category) )
		{
			return MallBagSimple.__PrepareResult(false);
		}

		var _category_slot = GetCategory(_item_category);
		if (is_undefined(_category_slot) )
		{
			return MallBagSimple.__PrepareResult(false);
		}

		var _result = _category_slot.AddItem(_item_key, _count, _vars);

		if (_result.success)
		{
			var _event = method(self, mall_get_event(event_on_add_item) );
			_event(_item_key, _result.GetVar("added"), args);
		}

		return _result;
	}
	
	/// @desc Removes an item amount from its category.
	/// @param {String} item_key The key of the item to remove.
	/// @param {Real} count The amount of the item to remove.
	/// @param {Struct} vars Optional struct with item variables to consider for matching.
	/// @returns {Struct.MallResult}
	static RemoveItem = function(_item_key, _count, _vars = {})
	{
		var _item_template = mall_get_item(_item_key);
		
		if (is_undefined(_item_template) ) 
		{
			__mall_alert($"Bag (RemoveItem): item template '{_item_key}' does not exist.");
			return MallBagSimple.__PrepareResult(true);
		}
		
		var _item_category = __ResolveCategoryFromItem(_item_template);
		if (is_undefined(_item_category) )
		{
			return MallBagSimple.__PrepareResult(true);
		}

		var _category_slot = GetCategory(_item_category);
		if (is_undefined(_category_slot) )
		{
			return MallBagSimple.__PrepareResult(true);
		}

		var _result = _category_slot.RemoveItem(_item_key, _count, _vars);

		if (_result.success)
		{
			var _event = method(self, mall_get_event(event_on_remove_item) );
			_event(_item_key, _result.GetVar("removed"), args);
		}

		return _result;
	}

	/// @desc Returns the total amount for an item in its category.
	/// @param {String} item_key The key of the item to count.
	/// @returns {Real} Total amount of the item in the bag.
	static GetItemCount = function(_item_key)
	{
		var _item_template = mall_get_item(_item_key);
		if (is_undefined(_item_template) )
		{
			__mall_alert($"Bag (GetItemCount): item template '{_item_key}' does not exist.");
			return 0;
		}
		
		var _item_category = __ResolveCategoryFromItem(_item_template);
		if (is_undefined(_item_category) )
		{
			return 0;
		}

		var _category_slot = GetCategory(_item_category);
		if (is_undefined(_category_slot) )
		{
			return 0;
		}

		return (_category_slot.GetItemCount(_item_key) );
	}
	
	/// @desc Returns the first item instance by key.
	/// @param {String} item_key The key of the item to find.
	/// @returns {Struct.MallItemInstance|undefined} An item instance struct with key, count and vars, or undefined if not found.
	static GetItemByKey = function(_item_key)
	{
		var _item_template = mall_get_item(_item_key);
		if (is_undefined(_item_template) )
		{
			__mall_alert($"Bag (GetItemByKey): item template '{_item_key}' does not exist.");
			return undefined;
		}

		var _item_category = __ResolveCategoryFromItem(_item_template);
		if (is_undefined(_item_category) )
		{
			return undefined;
		}

		var _category_slot = GetCategory(_item_category);
		if (is_undefined(_category_slot) )
		{
			return undefined;
		}

		return (_category_slot.GetItemByKey(_item_key) );
	}
	
	/// @desc Returns an item instance by index within a category.
	/// @param {String} category The category type to look into.
	/// @param {Real} index The index of the item within the category.
	/// @returns {Struct.MallItemInstance|undefined} An item instance struct with key, count and vars, or undefined if not found.
	static GetItemByIndexInCategory = function(_category, _index)
	{
		var _category_slot = GetCategory(_category);

		return (_category_slot.GetItemByIndex(_index) );
	}
	
	/// @desc Returns all item instances for a category.
	/// @param {String} type The category type to look into.
	/// @returns {Array<Struct.MallItemInstance>} An array of item instance structs with key, count and vars, or an empty array if no items are found.
	static GetItemsByCategory = function(_type)
	{
		var _category_slot = GetCategory(_type);

		return (_category_slot.GetOrderedItems() );
	}
	
	/// @desc Returns all category keys currently in use.
	/// @returns {Array<String>} An array of category keys.
	static GetAllCategories = function()
	{
		return (struct_get_names(categories) );
	}
	
	/// @desc Exports bag state to a struct.
	/// @returns {Struct}
	static Export = function()
	{
		var _this = self;
		with (method(self, MallBag.Export)() )
		{
			overrides = overrides;
			categories = {}
			
			// Export each category separately to preserve their internal structure and avoid circular references.
			var _category_keys = struct_get_names(categories);
			var i=0; repeat(array_length(_category_keys) )
			{
				var _key = _category_keys[i++];
				categories[$ _key] = _this.categories[$ _key].Export();
			}

			return self;
		}
	}

	/// @desc Configures the bag from a data struct.
	/// @param {Struct} data The data struct to configure the bag with.
	/// @returns {Struct.MallBagComplex}
	static Import = function(_data)
	{
		// Call parent implementation.
		method(self, MallBag.Import)(_data);
		overrides = _data[$ "overrides"] ?? overrides;
		// Load categories.
		if (struct_exists(_data, "categories") )
		{
			var _data_categories = _data[$ "categories"];
			var _category_keys = struct_get_names(_data_categories);
			
			var i=0; repeat(array_length(_category_keys) )
			{
				var _key = _category_keys[ i++ ];
				// Create category slot with configured limits.
				var _category_slot = GetCategory(_key);
				_category_slot.Import(_data_categories[$ _key]);
			}
		}

		return self;
	}	

	#endregion
}