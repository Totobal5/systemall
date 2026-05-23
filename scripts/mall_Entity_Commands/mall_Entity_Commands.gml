/// @desc Stores the command sets available to an entity.
/// @param {Struct.MallEntity} owner Owner entity.
/// @param {String} key Command set key.
function MallEntityCommands(_owner, _key) : Mall(_key) constructor
{
	/// @type {Struct.MallEntity|Undefined} Owner entity.
	owner = weak_ref_create(_owner);

	/// @type {Struct} Command keys grouped by category.
	commands = {};
	
	/// @type {Array<String>} Category keys used for simpler iteration.
	commands_key = [];

	#region PRIVATE API

	/// @ignore
	/// @desc Returns owner id (or fallback label) for diagnostics.
	/// @return {String}
	static __OwnerLabel = function()
	{
		return (weak_ref_alive(owner) ) ? owner.ref.id : "unknown";
	}
	
	/// @ignore
	/// @desc Logs an alert message with command-context metadata.
	/// @param {String} _message Alert message.
	static __Alert = function(_message)
	{
		if (__MALL_ENTITIES_ALERT) __mall_alert($"\n\tMallEntityCommands '{__OwnerLabel()}': {_message}");
	}

	/// @ignore
	/// @desc Logs an error message with command-context metadata.
	/// @param {String} _message Error message.
	static __Error = function(_message)
	{
		__mall_error($"\n\tMallEntityCommands '{__OwnerLabel()}': {_message}");
	}

	#endregion
	
	#region PUBLIC API

	/// @desc Exports the command instance state to a struct.
	/// @returns {Struct}
	static Export = function()
	{
		var _this = self;
		return with (method(self, Mall.Export)() )
		{
			commands = variable_clone(_this.commands);
			commands_key = variable_clone(_this.commands_key);

			return self;
		}
	}

	/// @desc Imports the command instance state from a struct.
	/// @param {Struct} data Struct containing instance data.
	static Import = function(_data)
	{
		method(self, Mall.Export) (_data);

		commands = variable_clone(_data[$ "commands"] ?? commands);
		commands_key = variable_clone(_data[$ "commands_key"] ?? commands_key);

		return self;
	}

	/// @desc Ensures a category exists and tracks it in category keys.
	/// @param {String} _category_key Category key.
	/// @return {Bool} True when category exists after call.
	static EnsureCategory = function(_category_key)
	{
		if (_category_key == "")
		{
			__Error("EnsureCategory: category key cannot be empty.");
			return false;
		}

		if (struct_exists(commands, _category_key) ) return true;

		commands[$ _category_key] = {};
		array_push(commands_key, _category_key);
		
		__Alert($"EnsureCategory: category '{_category_key}' created.");

		return true;
	}

	/// @desc Adds a command key into a category.
	/// @param {String} _category_key Category key.
	/// @param {String} _command_key Command key.
	/// @return {Bool} True if inserted.
	static AddCommand = function(_category_key, _command_key)
	{
		if (_command_key == "")
		{
			__Error("AddCommand: command key cannot be empty.");
			return false;
		}

		if (!mall_exists_command(_command_key) )
		{
			__Alert($"AddCommand: command '{_command_key}' is not registered in the database.");
			return false;
		}

		if (!EnsureCategory(_category_key) ) return false;

		var _category = commands[$ _category_key];
		if (struct_exists(_category, _command_key) )
		{
			__Alert($"AddCommand: command '{_command_key}' already exists in category '{_category_key}'.");
			return false;
		}

		_category[$ _command_key] = true;
		return true;
	}

	/// @desc Removes a command key from a category.
	/// @param {String} _category_key Category key.
	/// @param {String} _command_key Command key.
	/// @return {Bool} True if removed.
	static RemoveCommand = function(_category_key, _command_key)
	{
		if (!struct_exists(commands, _category_key) )
		{
			__Error($"RemoveCommand: category '{_category_key}' does not exist.");
			return false;
		}

		var _category = commands[$ _category_key];
		if (!struct_exists(_category, _command_key) )
		{
			__Error($"RemoveCommand: command '{_command_key}' does not exist in category '{_category_key}'.");
			return false;
		}

		struct_remove(_category, _command_key);

		// Keep category list synchronized when a category becomes empty.
		if (array_length(struct_get_names(_category)) == 0)
		{
			struct_remove(commands, _category_key);
			var _index = -1;
			var i=0; repeat(array_length(commands_key))
			{
				if (commands_key[i] == _category_key)
				{
					_index = i;
					break;
				}
				i++;
			}

			if (_index > -1) array_delete(commands_key, _index, 1);
		}

		return true;
	}

	/// @desc Checks whether a command key exists in a category.
	/// @param {String} _category_key Category key.
	/// @param {String} _command_key Command key.
	/// @return {Bool}
	static HasCommand = function(_category_key, _command_key)
	{
		if (!struct_exists(commands, _category_key) ) return false;
		return struct_exists(commands[$ _category_key], _command_key);
	}

	/// @desc Returns a command template if present in category.
	/// @param {String} _category_key Category key.
	/// @param {String} _command_key Command key.
	/// @return {Struct.MallCommand|Undefined}
	static GetCommand = function(_category_key, _command_key)
	{
		if (!HasCommand(_category_key, _command_key) ) return undefined;
		return mall_get_command(_command_key);
	}

	/// @desc Returns all command keys for a category.
	/// @param {String} _category_key Category key.
	/// @return {Array<String>}
	static GetAllCommands = function(_category_key)
	{
		if (!struct_exists(commands, _category_key) ) return [];
		return struct_get_names(commands[$ _category_key]);
	}

	/// @desc Returns a random command key from a category.
	/// @param {String} _category_key Category key.
	/// @return {String|Undefined}
	static GetRandomCommand = function(_category_key)
	{
		var _all_commands = GetAllCommands(_category_key);
		var _count = array_length(_all_commands);
		if (_count == 0) return undefined;
		return _all_commands[irandom(_count - 1)];
	}

	/// @desc Returns a shallow copy of category keys.
	/// @return {Array<String>}
	static GetCategories = function()
	{
		var _result = [];
		array_copy(_result, 0, commands_key, 0, array_length(commands_key));
		return _result;
	}

	#endregion
}