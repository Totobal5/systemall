/// @desc Base template for a battle or menu command.
/// @param {String} key Unique command key.
/// @returns {Struct.MallCommand}
function MallCommand(_key) : MallBehavior(_key) constructor
{
    // --- Command properties ---
	
    /// @desc Command family, for example "PHYSICAL" or "MAGIC".
    /// @type {String}
	command_type = "";
	
    /// @desc Number of targets this command can affect.
    /// @type {Real}
    targets = 1;
	
    /// @desc Parameters used to configure reusable events.
    /// @type {Struct}
	params = {};
    
    // Targeting capabilities.
	
    /// @desc Whether this command can target the caster.
    /// @type {Bool}
    can_target_self = false;
	
    /// @desc Whether this command can target allies.
    /// @type {Bool}
    can_target_ally = false;
	
    /// @desc Whether this command can target enemies.
    /// @type {Bool}
    can_target_enemy = false;
    
    /// @desc Whether the same target can be selected more than once on multi-target commands.
    /// @type {Bool}
    can_target_same = true;
    
    #region EVENTS
    /// @desc Event key used to check whether the command succeeds.
    /// @returns {Bool}
    event_check = "";
	
    /// @desc Event key executed on success.
    /// @returns {undefined}
    event_execute = "";
	
    /// @desc Event key executed on failure.
    /// @returns {undefined}
    event_fail = "";
	
    /// @desc Event key used to run a cinematic.
    /// @returns {undefined}
    event_cinematic = "";
	
    /// @desc Default event key used to resolve targets.
    /// @returns {Array<Struct.MallEntity>}
    event_get_target = "";
	
    #endregion
    
    #region METHODS
    /// @desc Configures the command from a data struct.
    /// @param {Struct} _data Command configuration data.
    /// @returns {Struct.MallCommand}
    static FromData = function(_data)
    {
        command_type = _data[$ "command_type"] ?? "";
        targets = _data[$ "targets"] ?? 1;
        can_target_same = _data[$ "can_target_same"] ?? true;

        // Load parameters.
		params = variable_clone(_data[$ "params"] ?? {});
		
		// Reset target flags before loading fresh data.
		can_target_self = false;
		can_target_ally = false;
		can_target_enemy = false;
		
		// Load target capabilities from string keys.
        var _targets = _data[$ "target_types"] ?? [];
        if (is_array(_targets) )
        {
            for (var i = 0; i < array_length(_targets); i++)
            {
                switch (_targets[i] )
                {
                    case "self":	can_target_self = true; break;
                    case "ally":	can_target_ally = true; break;
                    case "enemy":	can_target_enemy = true; break;
                }
            }
        }
        
		// Load event function keys.
        event_check =		_data[$ "event_check"]		?? "";
        event_execute =		_data[$ "event_execute"]	?? "";
        event_fail =		_data[$ "event_fail"]		?? "";
        event_cinematic =	_data[$ "event_cinematic"]	?? "";
        event_get_target =	_data[$ "event_get_target"]	?? "";
        
        return self;
    }
    
    #endregion
}