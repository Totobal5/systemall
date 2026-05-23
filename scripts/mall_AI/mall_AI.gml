/// @desc Mall AI rule class representing individual AI behaviors that can be executed by entities in the system. Each rule defines conditions, actions, and target selection logic through event keys that reference externally defined scripts.
/// @param {String} key Unique identifier for the AI rule template.
function MallAI(_key) : MallBehavior(_key) constructor
{
	/// @type {Real} Rule priority (used by rule templates).
	priority = 0;

	#region EVENTS

	/// @desc Condition event key.
	/// @param {Struct.MallEntity} entity The entity being evaluated.
	/// @param {Struct.MallEntity} target The potential target being evaluated (if applicable).
	/// @param {Struct} [context] Optional context struct for additional data.
	/// @returns {Bool}
	event_on_check = "";

	/// @desc Action resolver event key.
	/// @param {Struct.MallEntity} entity The entity executing the action.
	/// @param {Array<Struct.MallEntity>} targets The selected targets.
	/// @param {Struct} [context] Optional context struct for additional data.
	event_on_action = "";

	/// @desc Target resolver event key.
	/// @param {Struct.MallEntity} entity The entity resolving the target.
	/// @param {Struct} [context] Optional context struct for additional data.
	/// @returns {Array<Struct.MallEntity>}
	event_on_get_target = "";

	#endregion

	#region PRIVATE API

	/// @ignore
	/// @desc Loads AI rule fields from data.
	/// @param {Struct} data The struct containing the behavior data.
	static __LoadEvents = function(_data)
	{
		method(self, MallBehavior.__LoadEvents) (_data);

		event_on_check =		variable_get_hash(_data[$ "event_on_check"] ?? "");
		event_on_action =		variable_get_hash(_data[$ "event_on_action"] ?? "");
		event_on_get_target =	variable_get_hash(_data[$ "event_on_get_target"] ?? "");

		return self;
	}

	#endregion

	#region PUBLIC API

	/// @desc 
	/// @param {Struct} context Battle context.
	/// @returns {Struct.MallBattleAction|undefined}
	static SelectCommand = function(_context)
	{
		if (!struct_get_from_hash(__cache, event_on_check) )
		{
			var _check_func = method(_context, mall_get_event_check_true(event_on_check));
			struct_set_from_hash(__cache, event_on_check, _check_func);
		}
		else 
		{
			var _check_func = struct_get_from_hash(__cache, event_on_check);
		}

		if (!_check_func(_context) ) return undefined;

		if (!struct_get_from_hash(__cache, event_on_get_target) )
		{
			var _target_func = method(_context, mall_get_event(event_on_get_target));
			struct_set_from_hash(__cache, event_on_get_target, _target_func);
		}
		else 
		{
			var _target_func = struct_get_from_hash(__cache, event_on_get_target);
		}

		// Obtain targets from event, ensuring we have an array to work with.
		var _targets = _target_func(_context);
		if (is_undefined(_targets) ) return undefined;

		if (!is_array(_targets) ) 
		{
			_targets = [_targets];
		}
		else
		{
			// Filter out undefined targets.
			_targets = array_filter(_targets, function(_t) { return !is_undefined(_t); } );
		}

		// Get event_on_action.
		if (!struct_get_from_hash(__cache, event_on_action) )
		{
			var _action_func = method(_context, mall_get_event(event_on_action));
			struct_set_from_hash(__cache, event_on_action, _action_func);
		}
		else 
		{
			var _action_func = struct_get_from_hash(__cache, event_on_action);
		}

		var _command_key = _action_func(_context, _targets);
		if (!is_string(_command_key) || _command_key == "")
		{
			__mall_alert($"rule_cmd_invalid::{key}", $"Rule '{key}' returned an invalid command key.");
			return undefined;
		}

		if (!mall_exists_command(_command_key))
		{
			__mall_alert($"rule_cmd_missing::{key}::{_command_key}", $"Rule '{key}' resolved command '{_command_key}' that is not registered.");
			return undefined;
		}

		// Get command template.
		var _command_template = mall_get_command(_command_key);
		if (is_undefined(_command_template) ) return undefined;

		return new MallBattleAction(_command_key, _context, _command_template, _targets);
	}

	/// @desc Exports the iterator runtime state to a struct.
	/// @return {Struct}	
	static Export = function()
	{
		var _this = self;
		// Parent export.
		with (method(self, MallBehavior.Export)() )
		{
			priority = _this.priority;
			
			// Events
			event_on_check = _this.event_on_check;
			event_on_action = _this.event_on_action;
			event_on_get_target = _this.event_on_get_target;

			return self;
		}
	}

	/// @desc Imports iterator state from a struct.
	/// @param {Struct} data Struct containing component data.
	static Import = function(_data)
	{
		// Parent import.
		method(self, MallBehavior.Import) (_data);
		priority = _data[$ "priority"] ?? priority;

		return self;
	}

	/// @desc Returns a string representation of this instance for debugging purposes.
	/// @return {String}
	static toString = function()
	{
		var _parent_str = method(self, MallBehavior.toString) ();
		return $"{_parent_str}\nMallAI::\nPriority: {priority}\nCondition: {event_on_check}\nAction: {event_on_action}\nTarget: {event_on_get_target}\n";
	}

	#endregion
}