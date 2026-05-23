/// @desc Adds one or more runtime type entries.
/// @param {String|Array<String>} key Type key(s).
/// @param {String|Array<String>} value Value key(s) to register.
function mall_create_type(_key, _value)
{
	__mall_type_bootstrap();

	var _keys = __mall_type_normalize_keys(_key);
	if (array_length(_keys) <= 0)
	{
		__mall_error("mall_create_type expected a non-empty string key or array of keys.");
		exit;
	}

	var _values = __mall_type_normalize_values(_value);
	if (array_length(_values) <= 0)
	{
		__mall_error("mall_create_type expected a non-empty string value or array of values.");
		exit;
	}

	var i = 0; repeat(array_length(_keys) )
	{
		var _tag = _keys[i++];
		var _bucket = __Systemall.__types[$ _tag];
		var _bucket_fast = __Systemall.__types_fast[$ _tag];

		if (!is_array(_bucket))
		{
			_bucket = [];
			__Systemall.__types[$ _tag] = _bucket;
		}

		if (!is_struct(_bucket_fast))
		{
			_bucket_fast = {};
			__Systemall.__types_fast[$ _tag] = _bucket_fast;
		}

		var j = 0; repeat(array_length(_values) )
		{
			var _entry = _values[j++];
			if (struct_exists(_bucket_fast, _entry)) continue;

			_bucket_fast[$ _entry] = true;
			array_push(_bucket, _entry);
		}

		if (!array_contains(__Systemall.__types_keys, _tag) ) { array_push(__Systemall.__types_keys, _tag); }
	}
}

/// @desc Returns whether a type key exists in runtime data.
/// @param {String} key Type key.
/// @return {Bool}
function mall_exists_type(_key)
{
	__mall_type_bootstrap();

	_key = __mall_type_normalize_key(_key);
	if (is_undefined(_key) ) return false;

	if (struct_exists(__Systemall.__types, _key) ) return true;
	if (struct_exists(__Systemall.__types_hierarchy, _key) ) return true;
	if (struct_exists(__Systemall.__types_descendants_fast, _key) ) return true;

	return false;
}

/// @desc Returns all values registered under one or more tags.
/// Includes descendant buckets defined by hierarchy rules.
/// @param {String|Array<String>} key Type key(s).
/// @return {Array<String>|Undefined}
function mall_get_type(_key)
{
	__mall_type_bootstrap();

	var _keys = __mall_type_normalize_keys(_key);
	if (array_length(_keys) <= 0) return undefined;

	var _result = [];
	var _result_fast = {};

	var i = 0; repeat(array_length(_keys))
	{
		var _query = _keys[i++];
		__mall_type_collect_values_by_tag(_query, _result, _result_fast);
	}

	if (array_length(_result) <= 0) return undefined;
	return _result;
}

/// @desc Returns all registered type keys.
/// @return {Array<String>}
function mall_get_type_keys()
{
	__mall_type_bootstrap();

	var _copy = [];
	array_copy(_copy, 0, __Systemall.__types_keys, 0, array_length(__Systemall.__types_keys));
	return _copy;
}

/// @desc Returns true when a value exists in one or more type buckets.
/// Query supports hierarchy on keys.
/// @param {String|Array<String>} key Type key(s).
/// @param {String|Array<String>} value Value key(s) to check.
/// @return {Bool}
function mall_type_has_value(_key, _value)
{
	__mall_type_bootstrap();

	var _keys = __mall_type_normalize_keys(_key);
	var _values = __mall_type_normalize_values(_value);

	if (array_length(_keys) <= 0) return false;
	if (array_length(_values) <= 0) return false;

	var _search_fast = __mall_type_array_to_fast(_values);

	var i = 0; repeat(array_length(_keys) )
	{
		var _tag = _keys[i++];
		if (__mall_type_bucket_has_any(_tag, _search_fast) ) return true;
	}

	return false;
}

/// @desc Removes value key(s) from one or more type buckets.
/// @param {String|Array<String>} key Type key(s).
/// @param {String|Array<String>} value Value key(s) to remove.
/// @return {Bool}
function mall_remove_type_value(_key, _value)
{
	__mall_type_bootstrap();

	var _keys = __mall_type_normalize_keys(_key);
	if (array_length(_keys) <= 0)
	{
		__mall_error("mall_remove_type_value expected a non-empty string key or array of keys.");
		return false;
	}

	var _values = __mall_type_normalize_values(_value);
	if (array_length(_values) <= 0)
	{
		__mall_error("mall_remove_type_value expected a non-empty string value or array of values.");
		return false;
	}

	var _removed_any = false;
	var i = 0; repeat(array_length(_keys) )
	{
		var _tag = _keys[i++];
		if (!struct_exists(__Systemall.__types, _tag)) continue;

		var _bucket = __Systemall.__types[$ _tag];
		if (!is_array(_bucket)) continue;

		var j = 0; repeat (array_length(_values) )
		{
			var _needle = _values[j++];
			while (true)
			{
				var _idx = array_get_index(_bucket, _needle);
				if (_idx == -1) break;

				array_delete(_bucket, _idx, 1);
				_removed_any = true;
			}
		}

		if (array_length(_bucket) <= 0)
		{
			struct_remove(__Systemall.__types, _tag);
			if (struct_exists(__Systemall.__types_fast, _tag) ) struct_remove(__Systemall.__types_fast, _tag);
		}
		else
		{
			__Systemall.__types[$ _tag] = _bucket;
			__Systemall.__types_fast[$ _tag] = __mall_type_array_to_fast(_bucket);
		}
	}

	if (_removed_any) __Systemall.__types_keys = struct_get_names(__Systemall.__types);
	return _removed_any;
}

/// @desc Removes one or more type buckets.
/// @param {String|Array<String>} key Type key(s).
/// @return {Bool}
function mall_remove_type(_key)
{
	__mall_type_bootstrap();

	var _keys = __mall_type_normalize_keys(_key);
	if (array_length(_keys) <= 0)
	{
		__mall_error("mall_remove_type expected a non-empty string key or array of keys.");
		return false;
	}

	var _removed_any = false;
	var i = 0; repeat (array_length(_keys))
	{
		var _tag = _keys[i++];
		if (!struct_exists(__Systemall.__types, _tag) ) continue;

		struct_remove(__Systemall.__types, _tag);
		if (struct_exists(__Systemall.__types_fast, _tag) ) struct_remove(__Systemall.__types_fast, _tag);
		_removed_any = true;
	}
	
	if (_removed_any) __Systemall.__types_keys = struct_get_names(__Systemall.__types);
	return _removed_any;
}

/// @desc Configures hierarchy rules where child tags inherit parent tags.
/// Example: { FIRE: ["MAGIC"] }.
/// @param {Struct} hierarchy_data Struct child -> parent(s).
/// @return {Bool}
function mall_types_set_hierarchy(_hierarchy_data)
{
	__mall_type_bootstrap();

	if (!is_struct(_hierarchy_data))
	{
		__mall_error("mall_types_set_hierarchy expected a struct payload.");
		return false;
	}

	var _normalized = {};
	var _children = struct_get_names(_hierarchy_data);
	var i = 0; repeat (array_length(_children))
	{
		var _child_raw = _children[i++];
		var _child = __mall_type_normalize_key(_child_raw);
		if (is_undefined(_child)) continue;

		var _parents = __mall_type_normalize_keys(_hierarchy_data[$ _child_raw]);
		var _clean_parents = [];
		var j = 0; repeat (array_length(_parents) )
		{
			var _parent = _parents[j++];
			if (_parent == _child) continue;
			if (array_contains(_clean_parents, _parent) ) continue;

			array_push(_clean_parents, _parent);
		}

		if (array_length(_clean_parents) > 0) { _normalized[$ _child] = _clean_parents; }
	}

	__Systemall.__types_hierarchy = _normalized;
	__mall_type_rebuild_graph_caches();

	return true;
}

/// @desc Configures mutual exclusion rules.
/// Example: { ALIVE:["UNDEAD"], UNDEAD:["ALIVE"] }.
/// @param {Struct} mutex_data Struct tag -> incompatible tag(s).
/// @return {Bool}
function mall_types_set_mutex(_mutex_data)
{
	__mall_type_bootstrap();

	if (!is_struct(_mutex_data))
	{
		__mall_error("mall_types_set_mutex expected a struct payload.");
		return false;
	}

	var _mutex = {};
	var _keys = struct_get_names(_mutex_data);
	var i = 0; repeat (array_length(_keys))
	{
		var _tag_raw = _keys[i++];
		var _tag = __mall_type_normalize_key(_tag_raw);
		if (is_undefined(_tag) ) continue;

		var _others = __mall_type_normalize_keys(_mutex_data[$ _tag_raw]);
		var j = 0; repeat (array_length(_others) )
		{
			var _other = _others[j++];
			if (_other == _tag) continue;

			__mall_type_add_mutex_link(_mutex, _tag, _other);
			__mall_type_add_mutex_link(_mutex, _other, _tag);
		}
	}

	__Systemall.__types_mutex = _mutex;
	return true;
}

/// @desc Builds a fast index for a direct type array.
/// @param {Array<String>} types Direct tags from JSON/component data.
/// @return {Struct} { direct, direct_fast, effective_fast }
function mall_types_make_index(_types)
{
	__mall_type_bootstrap();

	var _direct = __mall_type_normalize_keys(_types);
	var _direct_fast = __mall_type_array_to_fast(_direct);
	var _effective_fast = __mall_type_build_effective_fast(_direct);

	return {
		direct: _direct,
		direct_fast: _direct_fast,
		effective_fast: _effective_fast
	};
}

/// @desc Returns true if source has tag (directly or by hierarchy inheritance).
/// @param {Array<String>|Struct} source Type array or index struct from mall_types_make_index.
/// @param {String} tag Tag to test.
/// @return {Bool}
function mall_types_has(_source, _tag)
{
	__mall_type_bootstrap();

	var _query = __mall_type_normalize_key(_tag);
	if (is_undefined(_query)) return false;

	var _fast = __mall_type_resolve_effective_fast(_source);
	if (!is_struct(_fast)) return false;

	return struct_exists(_fast, _query);
}

/// @desc Tries to append one tag into a direct type array applying mutex validation.
/// @param {Array<String>} types Direct type array.
/// @param {String} tag Tag to add.
/// @return {Struct} { success, types, conflicts }
function mall_types_try_add(_types, _tag)
{
	__mall_type_bootstrap();

	var _direct = __mall_type_normalize_keys(_types);
	var _new_tag = __mall_type_normalize_key(_tag);
	if (is_undefined(_new_tag))
	{
		return { success: false, types: _direct, conflicts: [] };
	}

	if (array_contains(_direct, _new_tag))
	{
		return { success: true, types: _direct, conflicts: [] };
	}

	var _current_effective = __mall_type_build_effective_fast(_direct);
	var _incoming_effective = __mall_type_expand_tag_to_fast(_new_tag);
	var _conflicts = __mall_type_collect_mutex_conflicts(_current_effective, _incoming_effective);

	if (array_length(_conflicts) > 0)
	{
		return { success: false, types: _direct, conflicts: _conflicts };
	}

	array_push(_direct, _new_tag);
	return { success: true, types: _direct, conflicts: [] };
}

/// @desc Evaluates AND/OR/NOT query against source tags.
/// Query struct shape: { and:[...], or:[...], not:[...] }.
/// @param {Array<String>|Struct} source Type array or index struct.
/// @param {Struct} query Query struct.
/// @return {Bool}
function mall_types_match_query(_source, _query)
{
	__mall_type_bootstrap();

	if (!is_struct(_query)) return false;
	var _fast = __mall_type_resolve_effective_fast(_source);
	if (!is_struct(_fast)) return false;

	var _and = __mall_type_normalize_keys(_query[$ "and"] ?? []);
	var _or = __mall_type_normalize_keys(_query[$ "or"] ?? []);
	var _not = __mall_type_normalize_keys(_query[$ "not"] ?? []);

	var i = 0; repeat (array_length(_and))
	{
		var _and_tag = _and[i++];
		if (!struct_exists(_fast, _and_tag) ) return false;
	}

	if (array_length(_or) > 0)
	{
		var _has_any_or = false;
		i = 0; repeat (array_length(_or))
		{
			var _or_tag = _or[i++];
			if (struct_exists(_fast, _or_tag))
			{
				_has_any_or = true;
				break;
			}
		}

		if (!_has_any_or) return false;
	}

	i = 0; repeat (array_length(_not))
	{
		var _not_tag = _not[i++];
		if (struct_exists(_fast, _not_tag) ) return false;
	}

	return true;
}

/// @desc Filters components by tag query.
/// Expects each component to expose a type array field.
/// @param {Array<Struct>} source Array of components.
/// @param {Struct} query Query struct {and, or, not}.
/// @return {Array<Struct>}
function mall_types_filter_components(_source, _query)
{
	var _result = [];
	if (!is_array(_source) ) return _result;

	var i = 0; repeat (array_length(_source))
	{
		var _entry = _source[i++];
		if (!is_struct(_entry)) continue;
		if (!struct_exists(_entry, "type")) continue;

		var _entry_type = _entry[$ "type"];
		if (!is_array(_entry_type)) continue;

		var _index = mall_types_make_index(_entry_type);
		if (mall_types_match_query(_index, _query) ) array_push(_result, _entry);
	}

	return _result;
}

/// @ignore
/// @desc Initializes runtime containers used by the type subsystem.
function __mall_type_bootstrap()
{
	if (!is_struct(__Systemall.__types)) __Systemall.__types = {};
	if (!is_array(__Systemall.__types_keys)) __Systemall.__types_keys = [];
	if (!is_struct(__Systemall.__types_fast)) __Systemall.__types_fast = {};

	if (!is_struct(__Systemall.__types_hierarchy)) __Systemall.__types_hierarchy = {};
	if (!is_struct(__Systemall.__types_ancestors_fast)) __Systemall.__types_ancestors_fast = {};
	if (!is_struct(__Systemall.__types_descendants_fast)) __Systemall.__types_descendants_fast = {};
	if (!is_struct(__Systemall.__types_mutex)) __Systemall.__types_mutex = {};
}

/// @ignore
/// @desc Rebuilds ancestor and descendant caches after hierarchy updates.
function __mall_type_rebuild_graph_caches()
{
	__Systemall.__types_ancestors_fast = {};
	__Systemall.__types_descendants_fast = {};

	var _hierarchy = __Systemall.__types_hierarchy;
	var _children = struct_get_names(_hierarchy);
	var i = 0; repeat (array_length(_children))
	{
		var _child = _children[i++];
		if (is_undefined(__mall_type_get_ancestors_fast(_child) )) continue;
	}

	var _child_keys = struct_get_names(__Systemall.__types_ancestors_fast);
	i = 0; repeat (array_length(_child_keys))
	{
		var _node = _child_keys[i++];
		var _anc_fast = __Systemall.__types_ancestors_fast[$ _node];
		var _ancestors = struct_get_names(_anc_fast);

		var j = 0; repeat (array_length(_ancestors))
		{
			var _ancestor = _ancestors[j++];
			if (!struct_exists(__Systemall.__types_descendants_fast, _ancestor))
			{
				__Systemall.__types_descendants_fast[$ _ancestor] = {};
			}

			__Systemall.__types_descendants_fast[$ _ancestor][$ _node] = true;
		}
	}
}

/// @ignore
/// @desc Memoized ancestor closure for one tag.
/// @param {String} tag Tag key.
/// @return {Struct|Undefined}
function __mall_type_get_ancestors_fast(_tag)
{
	_tag = __mall_type_normalize_key(_tag);
	if (is_undefined(_tag)) return undefined;

	if (struct_exists(__Systemall.__types_ancestors_fast, _tag))
	{
		return __Systemall.__types_ancestors_fast[$ _tag];
	}

	var _visiting = {};
	var _result = __mall_type_collect_ancestors(_tag, _visiting);
	__Systemall.__types_ancestors_fast[$ _tag] = _result;

	return _result;
}

/// @ignore
/// @desc DFS helper for ancestor closure.
function __mall_type_collect_ancestors(_tag, _visiting)
{
	if (struct_exists(_visiting, _tag)) return {};
	_visiting[$ _tag] = true;

	var _result = {};
	if (!struct_exists(__Systemall.__types_hierarchy, _tag))
	{
		struct_remove(_visiting, _tag);
		return _result;
	}

	var _parents = __Systemall.__types_hierarchy[$ _tag];
	var i = 0; repeat (array_length(_parents))
	{
		var _parent = _parents[i++];
		_result[$ _parent] = true;

		var _parent_anc = __mall_type_get_ancestors_fast(_parent);
		if (is_struct(_parent_anc))
		{
			var _names = struct_get_names(_parent_anc);
			var j = 0; repeat (array_length(_names) ) { _result[$ _names[j++]] = true; }
		}
	}

	struct_remove(_visiting, _tag);
	return _result;
}

/// @ignore
/// @desc Collects values from one tag bucket and all descendant buckets.
function __mall_type_collect_values_by_tag(_tag, _result, _result_fast)
{
	if (struct_exists(__Systemall.__types_fast, _tag))
	{
		__mall_type_merge_bucket_fast(__Systemall.__types_fast[$ _tag], _result, _result_fast);
	}

	if (!struct_exists(__Systemall.__types_descendants_fast, _tag)) return;

	var _children_fast = __Systemall.__types_descendants_fast[$ _tag];
	var _children = struct_get_names(_children_fast);
	var i = 0;
	repeat (array_length(_children))
	{
		var _child = _children[i++];
		if (!struct_exists(__Systemall.__types_fast, _child)) continue;
		__mall_type_merge_bucket_fast(__Systemall.__types_fast[$ _child], _result, _result_fast);
	}
}

/// @ignore
/// @desc Returns true if one bucket or any descendant bucket contains at least one value from search_fast.
function __mall_type_bucket_has_any(_tag, _search_fast)
{
	if (struct_exists(__Systemall.__types_fast, _tag))
	{
		if (__mall_type_fast_intersects(__Systemall.__types_fast[$ _tag], _search_fast)) return true;
	}

	if (!struct_exists(__Systemall.__types_descendants_fast, _tag)) return false;

	var _children_fast = __Systemall.__types_descendants_fast[$ _tag];
	var _children = struct_get_names(_children_fast);
	var i = 0; repeat (array_length(_children))
	{
		var _child = _children[i++];
		if (!struct_exists(__Systemall.__types_fast, _child)) continue;
		if (__mall_type_fast_intersects(__Systemall.__types_fast[$ _child], _search_fast)) return true;
	}

	return false;
}

/// @ignore
/// @desc Converts array entries into a fast struct set.
function __mall_type_array_to_fast(_arr)
{
	var _fast = {};
	if (!is_array(_arr)) return _fast;

	var i = 0; repeat (array_length(_arr))
	{
		var _v = _arr[i++];
		if (!is_string(_v)) continue;
		_fast[$ string_trim(_v)] = true;
	}

	return _fast;
}

/// @ignore
/// @desc Returns true if two struct sets share at least one key.
function __mall_type_fast_intersects(_a, _b)
{
	if (!is_struct(_a) || !is_struct(_b)) return false;
	var _names = struct_get_names(_a);
	var i = 0; repeat (array_length(_names) )
	{
		if (struct_exists(_b, _names[i++])) return true;
	}

	return false;
}

/// @ignore
/// @desc Adds all keys from source fast set into result.
function __mall_type_merge_bucket_fast(_source_fast, _result, _result_fast)
{
	if (!is_struct(_source_fast)) return;
	var _names = struct_get_names(_source_fast);
	var i = 0; repeat (array_length(_names))
	{
		var _name = _names[i++];
		if (struct_exists(_result_fast, _name)) continue;

		_result_fast[$ _name] = true;
		array_push(_result, _name);
	}
}

/// @ignore
/// @desc Builds effective tag set from direct tags plus ancestors.
function __mall_type_build_effective_fast(_direct)
{
	var _effective = {};
	if (!is_array(_direct)) return _effective;

	var i = 0; repeat (array_length(_direct))
	{
		var _tag = _direct[i++];
		_effective[$ _tag] = true;

		var _anc_fast = __mall_type_get_ancestors_fast(_tag);
		if (!is_struct(_anc_fast)) continue;

		var _anc = struct_get_names(_anc_fast);
		var j = 0; repeat (array_length(_anc) ) { _effective[$ _anc[j++]] = true; }
	}

	return _effective;
}

/// @ignore
/// @desc Expands one tag into itself + ancestors as fast set.
function __mall_type_expand_tag_to_fast(_tag)
{
	var _fast = {};
	if (is_undefined(_tag)) return _fast;

	_fast[$ _tag] = true;
	var _anc_fast = __mall_type_get_ancestors_fast(_tag);
	if (!is_struct(_anc_fast)) return _fast;

	var _anc = struct_get_names(_anc_fast);
	var i = 0; repeat (array_length(_anc) ) { _fast[$ _anc[i++]] = true; }

	return _fast;
}

/// @ignore
/// @desc Returns conflicts between existing effective tags and incoming effective tags.
function __mall_type_collect_mutex_conflicts(_current_fast, _incoming_fast)
{
	var _conflicts_fast = {};
	var _incoming_names = struct_get_names(_incoming_fast);

	var i = 0; repeat (array_length(_incoming_names))
	{
		var _incoming_tag = _incoming_names[i++];
		if (!struct_exists(__Systemall.__types_mutex, _incoming_tag)) continue;

		var _forbidden_fast = __Systemall.__types_mutex[$ _incoming_tag];
		var _forbidden = struct_get_names(_forbidden_fast);
		var j = 0; repeat (array_length(_forbidden))
		{
			var _blocked = _forbidden[j++];
			if (!struct_exists(_current_fast, _blocked)) continue;

			_conflicts_fast[$ _blocked] = true;
			_conflicts_fast[$ _incoming_tag] = true;
		}
	}

	return struct_get_names(_conflicts_fast);
}

/// @ignore
/// @desc Resolves effective fast set from source.
/// Source can be an index struct from mall_types_make_index or a direct array.
function __mall_type_resolve_effective_fast(_source)
{
	if (is_struct(_source))
	{
		if (struct_exists(_source, "effective_fast") && is_struct(_source.effective_fast))
		{
			return _source.effective_fast;
		}

		if (struct_exists(_source, "direct") && is_array(_source.direct))
		{
			return __mall_type_build_effective_fast(__mall_type_normalize_keys(_source.direct));
		}

		if (struct_exists(_source, "type") && is_array(_source.type))
		{
			return __mall_type_build_effective_fast(__mall_type_normalize_keys(_source.type));
		}
	}
	else if (is_array(_source))
	{
		return __mall_type_build_effective_fast(__mall_type_normalize_keys(_source));
	}

	return undefined;
}

/// @ignore
/// @desc Adds one mutex edge into destination struct set.
function __mall_type_add_mutex_link(_mutex, _from_tag, _to_tag)
{
	if (!struct_exists(_mutex, _from_tag)) _mutex[$ _from_tag] = {};
	_mutex[$ _from_tag][$ _to_tag] = true;
}

/// @ignore
/// @desc Normalizes type keys into a unique uppercase array.
/// @param {String|Array<String>} key Key(s) to normalize.
/// @return {Array<String>}
function __mall_type_normalize_keys(_key)
{
	var _result = [];
	if (is_array(_key))
	{
		var i = 0; repeat (array_length(_key))
		{
			var _n = __mall_type_normalize_key(_key[i++]);
			if (is_undefined(_n) ) continue;
			if (array_contains(_result, _n) ) continue;

			array_push(_result, _n);
		}

		return _result;
	}

	var _single = __mall_type_normalize_key(_key);
	if (!is_undefined(_single) ) array_push(_result, _single);

	return _result;
}

/// @ignore
/// @desc Normalizes value keys into a unique trimmed array.
/// @param {String|Array<String>} value Value(s) to normalize.
/// @return {Array<String>}
function __mall_type_normalize_values(_value)
{
	var _result = [];
	if (is_array(_value))
	{
		var i = 0; repeat (array_length(_value))
		{
			var _n = __mall_type_normalize_value(_value[i++]);
			if (is_undefined(_n) ) continue;
			if (array_contains(_result, _n) ) continue;

			array_push(_result, _n);
		}
		return _result;
	}

	var _single = __mall_type_normalize_value(_value);
	if (!is_undefined(_single) ) array_push(_result, _single);
	
	return _result;
}

/// @ignore
/// @desc Normalizes one type key.
function __mall_type_normalize_key(_key)
{
	if (!is_string(_key)) return undefined;

	var _n = string_trim(_key);
	if (_n == "") return undefined;

	return string_upper(_n);
}

/// @ignore
/// @desc Normalizes one value key.
function __mall_type_normalize_value(_value)
{
	if (!is_string(_value)) return undefined;

	var _n = string_trim(_value);
	if (_n == "") return undefined;

	return _n;
}
