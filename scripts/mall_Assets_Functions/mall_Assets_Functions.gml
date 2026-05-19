/// @desc Registers an asset reference by key.
/// @param {String} key Asset key.
/// @param {Any} asset Asset reference.
function mall_add_asset(_key, _asset)
{
	if (__mall_validate_registry_args("mall_add_asset", _key, undefined, undefined, "Asset", true, false) )
	{
		// If the asset already exists, we log a warning and overwrite it.
		if (mall_asset_exists(_key) ) { __mall_alert($"Asset '{_key}' already exists and will be overwritten."); }
		__Systemall.__assets[$ _key] = _asset;
	}
}

/// @desc Gets an asset by key.
/// @param {String} key Asset key.
/// @return {Any}
function mall_asset_get(_key)
{
	if (!__mall_validate_registry_args("mall_asset_get", _key, undefined, undefined, "Asset", true, false) ) return undefined;
	return (__Systemall.__assets[$ _key] );
}

/// @desc Checks whether an asset key exists.
/// @param {String} key Asset key.
/// @return {Bool}
function mall_asset_exists(_key)
{
	if (!is_string(_key) || string_length(_key) <= 0) return false;
	return struct_exists(__Systemall.__assets, _key);
}

/// @desc Removes an asset key from the registry.
/// @param {String} key Asset key.
/// @return {Bool}
function mall_asset_remove(_key)
{
	if (!__mall_validate_registry_args("mall_asset_remove", _key, undefined, undefined, "Asset", true, false)) return false;
	struct_remove(__Systemall.__assets, _key);

	return true;
}

/// @desc Clears all registered assets.
function mall_assets_clear()
{
	__Systemall.__assets = {};
}