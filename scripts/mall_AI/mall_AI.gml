/// @desc Generic AI template used for both rules and packages.
/// @param {String} _key AI key.
/// @param {Bool} [_is_package=false] True for package templates, false for rule templates.
/// @returns {Struct.MallAI}
function MallAI(_key, _is_package=false) : Mall(_key) constructor
{
	/// @desc True when this template represents an AI package.
	/// @type {Bool}
	is_package = _is_package;

	/// @desc Optional note/comment for package definitions.
	/// @type {String}
	comment = "";

	/// @desc Rule priority (used by rule templates).
	/// @type {Real}
	priority = 0;

	/// @desc Condition event key (used by rule templates).
	/// @type {String}
	condition = "";

	/// @desc Action event key (used by rule templates).
	/// @type {String}
	action = "";

	/// @desc Target resolver event key (used by rule templates).
	/// @type {String}
	target = "";

	/// @desc Rule/package references for package templates.
	/// @type {Array<String>}
	rules = [];

	#region PRIVATE API
	/// @ignore
	/// @desc Internal sort function for rule priority.
	/// @param {Struct.MallAI} a First rule.
	/// @param {Struct.MallAI} b Second rule.
	static __SortByPriority = function(_a, _b) 
	{ 
		return _b.priority - _a.priority; 
	};

	#endregion

	#region PUBLIC API

	/// @desc Loads AI template data.
	/// @param {Struct} _data AI rule/package payload.
	/// @returns {Struct.MallAI}
	static FromData = function(_data)
	{
		if (!is_struct(_data))
		{
			__mall_error("MallAI.FromData expected a struct payload.");
			return self;
		}

		if (is_package)
		{
			comment = _data[$ "comment"] ?? comment;
			rules = variable_clone(_data[$ "rules"] ?? []);
		}
		else
		{
			priority = _data[$ "priority"] ?? priority;
			condition = _data[$ "condition"] ?? condition;
			action = _data[$ "action"] ?? action;
			target = _data[$ "target"] ?? target;
		}

		return self;
	}

	/// @desc Resolves package entries into a flat list of rule templates.
	/// @param {Struct} [visited_packages] Internal recursion guard.
	/// @returns {Array<Struct.MallAI>}
	static ResolveRules = function(_visited_packages = {})
	{
		var _flat_rules = [];

		if (!is_package)
		{
			array_push(_flat_rules, self);
			return _flat_rules;
		}

		if (struct_exists(_visited_packages, key) )
		{
			__mall_alert($"AI package recursion detected on '{key}'.");
			return _flat_rules;
		}

		_visited_packages[$ key] = true;

		var i = 0; repeat (array_length(rules) )
		{
			var _entry_key = rules[i++];

			var _rule = mall_get_ai_rule(_entry_key);
			if (!is_undefined(_rule))
			{
				array_push(_flat_rules, _rule);
				continue;
			}

			var _nested_package = mall_get_ai_package(_entry_key);
			if (!is_undefined(_nested_package))
			{
				var _nested_rules = _nested_package.ResolveRules(_visited_packages);
				array_copy(_flat_rules, array_length(_flat_rules), _nested_rules, 0, array_length(_nested_rules));
				continue;
			}

			__mall_alert($"AI reference '{_entry_key}' was not found in rules or packages.");
		}
		
		struct_remove(_visited_packages, key);
		return _flat_rules;
	}

	/// @desc Resolves and sorts package rules by descending priority.
	/// @returns {Array<Struct.MallAI>}
	static ResolveRulesSorted = function()
	{
		var _resolved = ResolveRules();
		array_sort(_resolved, __SortByPriority);
		return _resolved;
	}

	#endregion
}