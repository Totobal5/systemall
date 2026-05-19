/// @desc AI "brain" for an entity, making decisions from an AI package.
/// @param {Struct.MallEntity} _parent_entity Owner entity.
/// @param {String} _ai_package_key AI package key.
function MallAIInstance(_parent_entity, _ai_package_key) constructor
{
	/// @desc Entity that owns this AI instance.
	/// @type {Struct.MallEntity}
	parent_entity = _parent_entity;
	
	/// @desc Final flattened rules list, sorted by priority.
	/// @type {Array<Struct.MallAI>}
	resolved_rules = [];
	
	/// @desc Runtime AI memory and state storage.
	/// @type {Struct}
	memory = {};

	__Initialize(_ai_package_key);

	#region PRIVATE API

	/// @ignore
	/// @desc Initializes the AI instance by resolving its package and rules.
	/// @param {String} key AI package key.
	static __Initialize = function(_key) 
	{
		var _package = mall_get_ai_package(_key);
		if (!is_undefined(_package) && _package.is_package)
		{
			resolved_rules = _package.ResolveRulesSorted();
		}
		else
		{
			__mall_alert($"AI package '{_key}' was not found or is invalid.");
		}
	}

	/// @ignore
	/// @desc Evaluates one AI rule and returns a battle action when the rule is applicable.
	/// @param {Struct.MallAI} _rule AI rule template.
	/// @param {Struct} _battle_context Battle context.
	/// @returns {Struct.BattleAction|undefined}
	static __SelectActionFromRule = function(_rule, _battle_context)
	{
		var _condition_func = mall_get_event(_rule[$ "condition"]);
		if (!is_callable(_condition_func) || !_condition_func(parent_entity, _battle_context) ) return undefined;

		var _target_func = mall_get_event(_rule[$ "target"]);
		var _targets = is_callable(_target_func) ? _target_func(parent_entity, _battle_context) : [];
		if (array_length(_targets) <= 0) return undefined;

		var _action_func = mall_get_event(_rule[$ "action"]);
		if (!is_callable(_action_func) ) return undefined;

		var _command_key = _action_func(parent_entity, _targets);
		var _command_template = mall_get_command(_command_key);
		if (is_undefined(_command_template) ) return undefined;

		return new BattleAction(parent_entity, _command_template, _targets);
	}
	
	#endregion 

	#region	PUBLIC API

	/// @desc Selects the best action for the current turn.
	/// @param {Struct} battle_context Battle context (allies, enemies, and runtime combat data).
	/// @returns {Struct.BattleAction|undefined} Action to execute, or undefined.
	static SelectAction = function(_battle_context)
	{
		// Iterate through the resolved rules in priority order and return the first valid action.
		var _rules_length = array_length(resolved_rules);
		for (var i = 0; i < _rules_length; i++)
		{
			var _rule = resolved_rules[i];
			var _action = __SelectActionFromRule(_rule, _battle_context);
			if (!is_undefined(_action) ) return _action;
		}
		
		return undefined;
	}

	#endregion
}