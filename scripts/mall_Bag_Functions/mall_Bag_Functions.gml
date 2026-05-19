/// @desc Creates a bag template from data and registers it in __Systemall.
/// @param {String} key Unique bag key.
/// @param {Struct} data Raw bag data.
/// @returns {Struct.MallBagSimple|Struct.MallBagComplex|undefined}
function mall_create_bag_from_data(_key, _data)
{
	if (!__mall_validate_registry_args("mall_create_bag_from_data", _key, _data, mall_bag_exists, "Pocket bag")) return undefined;
	
	var _bag_type = string_lower(_data[$ "bag_type"] ?? "simple");
	if (_bag_type != "simple" && _bag_type != "complex")
	{
		__mall_alert($"Pocket bag '{_key}' has unknown bag_type '{_bag_type}'. Falling back to 'simple'.");
		_bag_type = "simple";
	}

	/// @type {Struct.MallBagComplex|Struct.MallBagSimple}
	var _bag;
	switch (_bag_type)
	{
		// Category-based bag.
		case "complex": _bag = new MallBagComplex(_key); break;
		// Flat single-list bag.
		default: _bag = new MallBagSimple(_key); break;
	}
	
	// Register in __Systemall.
	_bag.FromData(_data);
	__Systemall.__bags[$ _key] = _bag;

	// Maintain ordered keys list for data export.
	array_push(__Systemall.__bags_keys, _key);
	
	// If persistent, include it in save/load flow.
	if (_bag.is_persistent) { array_push(__Systemall.__persistent_bags, _key); }

	return (_bag);
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
function mall_bag_exists(_key)
{
	return (struct_exists(__Systemall.__bags, _key) );
}

/// @desc Creates a shop template from data and registers it in __Systemall.
/// @param {String} key Unique shop key.
/// @param {Struct} data Raw shop data.
/// @returns {Struct.MallShop|undefined} The created shop template.
function mall_create_shop_from_data(_key, _data)
{
	if (!__mall_validate_registry_args("mall_create_shop_from_data", _key, _data, mall_shop_exists, "Pocket shop")) return undefined;
	
	var _shop = (new MallShop(_key) ).FromData(_data);
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
function mall_shop_exists(_key)
{
	return (struct_exists(__Systemall.__shops, _key));
}

/// @desc Creates an item template from data and registers it in __Systemall.
/// @param {String} key Unique item key.
/// @param {Struct} data Raw item data.
/// @returns {Struct.MallItem|undefined}
function mall_create_item_from_data(_key, _data)
{
	if (!__mall_validate_registry_args("mall_create_item_from_data", _key, _data, mall_item_exists, "Pocket item")) return undefined;

	var _item = (new MallItem(_key) ).FromData(_data);

	__Systemall.__items[$ _key] = _item;
	array_push(__Systemall.__items_keys, _key);
	
	// Register item in runtime type index.
	mall_create_type(_item.item_type, _key);
	
	return _item;
}

/// @desc Returns an item template by key.
/// @param {String} key The unique item key.
/// @returns {Struct.MallItem|undefined}
function mall_get_item(_key)
{ 
	return (__Systemall.__items[$ _key] ); 
}

/// @desc Returns whether an item template exists.
/// @param {String} key The unique item key.
/// @returns {Bool}
function mall_item_exists(_key) 
{ 
	return (struct_exists(__Systemall.__items, _key) ); 
}