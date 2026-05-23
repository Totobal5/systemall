/// @desc Creates a bag at runtime.
/// @param {String} key Bag key (for example "BAG_INVENTORY").
/// @param {Struct.MallBag} _template MallBag template.
function mall_create_bag(_key, _template)
{
	if (!is_string(_key) || _key == "")
	{
		__mall_error("mall_create_bag expected a non-empty string key.");
		return false;
	}

	if (!is_struct(_template) )
	{
		__mall_error("mall_create_bag expected a struct template.");
		return false;
	}

	if (mall_exists_bag(_key) ) 
	{ 
		__mall_error($"Bag '{_key}' already exists."); 
		return false;
	}

	__Systemall.__bags[$ _key] = _template;
	array_push(__Systemall.__bags_keys, _key);

	// If persistent, include it in save/load flow.
	if (_template.is_persistent) { array_push(__Systemall.__persistent_bags, _key); }

	return true;
}

/// @desc Creates a bag template from data and registers it in __Systemall.
/// @param {String} key Unique bag key.
/// @param {Struct} data Raw bag data.
/// @returns {Struct.MallBagSimple|Struct.MallBagComplex|undefined}
function mall_create_bag_from_data(_key, _data)
{
	if (!is_struct(_data) )
	{
		__mall_error("mall_create_bag_from_data expected a struct data.");
		return false;
	}

	var _bag_type = string_upper(_data[$ "bag_type"] ?? "SIMPLE");
	if (_bag_type != "SIMPLE" && _bag_type != "COMPLEX")
	{
		__mall_alert($"Mall bag '{_key}' has unknown bag_type '{_bag_type}'. Falling back to 'simple'.");
		_bag_type = "SIMPLE";
	}

	/// @type {Struct.MallBagComplex|Struct.MallBagSimple}
	var _bag; 
	switch (_bag_type)
	{
		// Category-based bag.
		case "COMPLEX": _bag = new MallBagComplex(_key); break;
		// Flat single-list bag.
		default: _bag = new MallBagSimple(_key); break;
	}
	
	return (mall_create_bag(_key, _bag.Import(_data)) )
}

/// @desc Returns a bag template by key.
/// @param {String} key The unique bag key.
/// @returns {Struct.MallBagSimple|Struct.MallBagComplex|undefined}
function mall_get_bag(_key)
{
	return (__Systemall.__bags[$ _key] );
}

/// @desc Returns whether a bag template exists.
/// @param {String} key The unique bag key.
/// @returns {Bool}
function mall_exists_bag(_key)
{
	return (struct_exists(__Systemall.__bags, _key) );
}

// -- SHOP --

/// @desc Returns an array with all registered bag keys.
/// @returns {Array<String>}
function mall_get_bag_keys()
{
	return (__Systemall.__bags_keys);
}

/// @desc Creates a shop template from data and registers it in __Systemall.
/// @param {String} key Unique shop key.
/// @param {Struct} data Raw shop data.
/// @returns {Struct.MallShop|undefined} The created shop template.
function mall_create_shop_from_data(_key, _data)
{
	if (!__mall_validate_registry_args("mall_create_shop_from_data", _key, _data, mall_exists_shop, "Mall shop")) return undefined;
	
	var _shop = (new MallShop(_key) ).Import(_data);
	__Systemall.__shops[$ _key] = _shop;
	array_push(__Systemall.__shops_keys, _key);

	return (_shop);
}

/// @desc Returns a shop template by key.
/// @param {String} key The unique shop key.
/// @returns {Struct.MallShop|undefined}
function mall_get_shop(_key)
{
	return (__Systemall.__shops[$ _key] );
}

/// @desc Returns whether a shop template exists.
/// @param {String} key The unique shop key.
/// @returns {Bool}
function mall_exists_shop(_key)
{
	return (struct_exists(__Systemall.__shops, _key));
}