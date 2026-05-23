/// @desc AI "brain" for an entity, making decisions from an AI package.
/// @param {Struct.MallEntity} owner Owner entity.
/// @param {String} ai_package_key AI package key.
function MallAIInstance(_owner, _ai_package_key) : MallAIPackage(_ai_package_key) constructor
{
	/// @type {Struct.MallEntity} Entity that owns this AI instance.
	owner = weak_ref_create(_owner);
	
	/// @type {Array<Struct.MallAI>} Final flattened rules list, sorted by priority.
	resolved_rules = [];
	
	/// @type {Struct} Runtime AI memory and state storage.
	SetVar("last_selected_rule", undefined);

	#region	PUBLIC API

	/// @desc Exports the AI instance state to a struct.
	/// @returns {Struct}
	static Export = function()
	{
		var _this = self;
		return with (method(self, MallAIPackage.Export)() )
		{
			memory = variable_clone(_this.memory);
			memory_keys = variable_clone(_this.memory_keys);

			return self;
		}
	}

	/// @desc Exports the AI instance state to a struct.
	/// @returns {Struct}
	static Import = function(_data)
	{
		method(self, MallAIPackage.Import) (_data);

		// Initialize resolved rules after import.
		resolved_rules = GetResolvedRules();

		return self;
	}

	/// @desc Selects the best action for the current turn.
	/// @param {Struct} battle_context Battle context (allies, enemies, and runtime combat data).
	/// @returns {Struct.MallBattleAction|undefined} Action to execute, or undefined.
	static SelectCommand = function(_battle_context)
	{
		static __hash = variable_get_hash("last_selected_rule");

		if (array_length(resolved_rules) <= 0)
		{
			__mall_alert("SelectCommand: resolved_rules is empty.");
			return undefined;
		}

		// Iterate through the resolved rules in priority order and return the first valid action.
		var i=0; repeat(array_length(resolved_rules) )
		{
			var _rule = resolved_rules[i++];
			var _action = _rule.SelectCommand(_battle_context);
			if (!is_undefined(_action) )
			{
				// Save in memory which rule was selected for this turn, in case it's needed for later logic.
				SetVar(__hash, _rule.key);
				return _action;
			}
		}

		return undefined;
	}

	#endregion
}