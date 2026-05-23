/// @desc AI package template that groups and resolves AI rules.
/// @param {String} _key AI package key.
/// @returns {Struct.MallAIPackage}
function MallAIPackage(_key) : MallBehavior(_key) constructor
{
	/// @type {Struct} Rule priority (used by rule templates).
	rules = {};

	/// @type {Array<String>} Resolved rule keys for array operations.
	rules_keys = [];

	#region PRIVATE API

	/// @ignore
	/// @desc Internal sort function for rule priority.
	/// @param {String} rule_a First rule.
	/// @param {String} rule_b Second rule.	
	static __SortByPriority = function(_rule_a, _rule_b)
	{
		var _priority_a = rules[$ _rule_a];
		var _priority_b = rules[$ _rule_b];

		return _priority_b - _priority_a;
	}

	/// @desc Resolves package entries into a flat list of rule templates.
	/// @param {Array<String>} package_array Array of package keys to resolve. If undefined, resolves this package's rules.
	/// @param {String} key The current package key being resolved (used for recursion).
	static __LoadRules = function(_package_array, _key="")
	{
		static __visited_packages = {};
		static __seen_rules = {};

		var _is_root_call = (_key == "");
		if (_is_root_call)
		{
			__visited_packages = {};
			__seen_rules = {};
		}

		if (_key != "")
		{
			// Protect against package recursion.
			if (struct_exists(__visited_packages, _key) )
			{
				__mall_alert($"AI package recursion detected on '{_key}'.");
				return;
			}

			struct_set(__visited_packages, _key, true);
		}

		// For method recursion.
		_package_array ??= rules_keys;
		var i=0; repeat(array_length(_package_array) )
		{
			var _key = _package_array[i++];
			if (mall_exists_ai_package(_key) )
			{
				var _package = mall_get_ai_package(_key);
				if (!is_undefined(_package) ) _package.__LoadRules(_package.rules, _key);
			}
			else if (mall_exists_ai_rule(_key) )
			{
				var _rule = mall_get_ai_rule(_key);
				if (struct_exists(__seen_rules, _key) ) continue;
				
				// Set rule priority for sorting and push key for reference.
				struct_set(rules, _key, _rule.priority);
				array_push(rules_keys, _key);

				// Mark rule as seen.
				struct_set(__seen_rules, _key, true);
			}
			else
			{
				__mall_alert($"MallAIPackage reference '{_key}' was not found in rules or packages.");
			}
		}

		if (_key != "") struct_remove(__visited_packages, _key);
	}

	#endregion

	#region PUBLIC API

	/// @desc Returns the keys of the rules included in this package.
	/// @returns {Array<String>}
	static GetRules = function()
	{
		return variable_clone(rules_keys);
	}

	/// @desc Resolves and sorts package rules by descending priority, returning the rule templates.
	/// @returns {Array<String>}
	static GetRulesSorted = function()
	{
		var _sorted_rules = GetRules();
		array_sort(_sorted_rules, __SortByPriority);

		return (_sorted_rules);
	}

	/// @desc Resolves package rules and returns the highest priority rule template that passes its check event, or undefined if no rules pass.
	/// @return {Array<Struct.MallAI>|Undefined}
	static GetResolvedRules = function(_sorted=true)
	{
		var _rules = (_sorted) ? GetRulesSorted() : GetRules();
		return array_map(_rules, function(_rule_key) {
			var _template = mall_get_ai_rule(_rule_key);
			return _template.Import(_template);
		} );
	}

	/// @desc Exports the iterator runtime state to a struct.
	/// @return {Struct}	
	static Export = function()
	{
		var _this = self;
		// Parent export.
		with (method(self, MallBehavior.Export)() )
		{
			rules = variable_clone(_this.rules);

			return self;
		}
	}

	/// @desc Imports iterator state from a struct.
	/// @param {Struct} data Struct containing component data.
	static Import = function(_data)
	{
		// Parent import.
		method(self, MallBehavior.Import) (_data);
		rules = _data[$ "rules"] ?? rules;
		
		__LoadRules();

		return self;
	}

	/// @desc Returns a string representation of this package for debugging purposes.
	/// @return {String}
	static toString = function()
	{
		var _parent_str = method(self, MallBehavior.toString) ();
		return $"{_parent_str}\nMallAIPackage::\nRules: {rules}\n";
	}

	#endregion
}