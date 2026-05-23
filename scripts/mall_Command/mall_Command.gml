/// @desc Base template for a battle or menu command.
/// @param {String} key Unique command key.
/// @returns {Struct.MallCommand}
function MallCommand(_key) : MallBehavior(_key) constructor
{
	/// @type {Real} Number of targets this command can affect.
	targets = 1;
	
	/// @type {Bool} Whether this command can target the caster.
	can_target_self = false;
	
	/// @type {Bool} Whether this command can target allies.
	can_target_ally = false;
	
	/// @type {Bool} Whether this command can target enemies.
	can_target_enemy = false;
	
	/// @type {Bool} Whether the same target can be selected more than once on multi-target commands.
	can_target_same = true;

	#region EVENTS

	/// @desc Event key used to check whether the command succeeds.
	/// @param {Struct.MallEntity} caster Entity casting the command.
	/// @param {Struct.MallEntity} target The potential target being checked.
	/// @param {Struct} params Additional parameters passed to the check event.
	/// @returns {Bool} 
	event_check = "";

	/// @desc Default event key used to resolve targets.
	/// @param {Struct.MallEntity} caster Entity casting the command.
	/// @param {Array<Struct.MallEntity>} targets The potential targets being checked.
	/// @param {Struct} params Additional parameters passed to the check event.
	/// @returns {Array<Struct.MallEntity>}
	event_get_target = "";
	
	/// @desc Event key executed on success.
	/// @param {Struct.MallEntity} caster Entity casting the command.
	/// @param {Struct.MallEntity|Array<Struct.MallEntity>} target Target(s) of the command success branch.
	/// @param {Struct} params Additional parameters passed to the check event.
	/// @returns {Struct} Same Params struct from event_check, potentially with modifications.
	event_execute = "";
	
	/// @desc Event key executed on failure.
	/// @param {Struct.MallEntity} caster Entity casting the command.
	/// @param {Struct.MallEntity|Array<Struct.MallEntity>} target Target(s) of the command failed branch.
	/// @param {Struct} params Additional parameters passed to the check event.
	/// @returns {Struct} Same Params struct from event_check, potentially with modifications.
	event_fail = "";
	
	/// @desc Event key executed for cinematic purposes, regardless of success or failure.
	/// The success or failure branch can be checked inside the event using the Params struct passed from event_check.
	/// @param {Struct.MallEntity} caster Entity casting the command.
	/// @param {Struct.MallEntity|Array<Struct.MallEntity>} target Target(s) of the command.
	/// @param {Struct} params Additional parameters passed to the check event.
	/// @returns {Struct} Same Params struct from event_check, potentially with modifications.
	event_cinematic = "";
	
	#endregion
	
	#region PRIVATE API

	/// @ignore
	/// @desc Loads event strings to be used later.
	/// @param {Struct} data The struct containing the behavior data.
	static __LoadEvents = function(_data)
	{
		// Parent load.
		method(self, MallBehavior.__LoadEvents) (_data);

		// Assign event keys.
		event_check =		variable_get_hash(_data[$ "event_check"]		?? "");
		event_get_target =	variable_get_hash(_data[$ "event_get_target"]	?? "");
		event_execute =		variable_get_hash(_data[$ "event_execute"]		?? "");
		event_fail =		variable_get_hash(_data[$ "event_fail"]			?? "");
		event_cinematic =	variable_get_hash(_data[$ "event_cinematic"]	?? "");

		return self;
	}

	#endregion

	#region PUBLIC API

	/// @desc Exports the base instance state to a save struct.
	/// @return {Struct} Struct with essential instance data.
	static Export = function()
	{
		var _this = self;
		with (method(self, MallBehavior.Export) () )
		{
			targets = _this.targets;
			can_target_self =  _this.can_target_self;
			can_target_ally =  _this.can_target_ally;
			can_target_enemy = _this.can_target_enemy;
			can_target_same =  _this.can_target_same;
			
			// Events 
			event_check =		_this.event_check;
			event_get_target =	_this.event_get_target;
			event_execute =		_this.event_execute;
			event_fail =		_this.event_fail;
			event_cinematic =	_this.event_cinematic;

			return self;
		}
	}

	/// @desc Imports and restores the base instance state from a struct.
	/// @param {Struct} data Struct containing component data.
	static Import = function(_data)
	{
		// Call parent import.
		method(self, MallBehavior.Import) (_data);

		// Load command data.
		targets =			_data[$ "targets"] ?? targets;
		can_target_same =	_data[$ "can_target_same"]  ?? can_target_same;
		can_target_self =	_data[$ "can_target_self"]  ?? can_target_self;
		can_target_ally =	_data[$ "can_target_ally"]  ?? can_target_ally;
		can_target_enemy =	_data[$ "can_target_enemy"] ?? can_target_enemy;

		return self;
	}

	/// @desc Returns a string representation of this instance for debugging purposes.
	/// @return {String}
	static toString = function()
	{
		var _parent_str = method(self, MallBehavior.toString) ();
		return $"{_parent_str}\nMallCommand::\nTargets: {targets}\nCan Target Same: {can_target_same}\nCan Target Self: {can_target_self}\nCan Target Ally: {can_target_ally}\nCan Target Enemy: {can_target_enemy}\nEvent Check: {event_check}\nEvent Get Target: {event_get_target}\nEvent Execute: {event_execute}\nEvent Fail: {event_fail}\nEvent Cinematic: {event_cinematic}";
	}

	#endregion
}