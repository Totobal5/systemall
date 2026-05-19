/// @desc Stores the command sets available to an entity.
function MallCommandsInstance() constructor
{
	/// @desc Command keys grouped by category.
	/// @type {Struct}
	commands = {};
	
	/// @desc Category keys used for simpler iteration.
	/// @type {Array<String>}
	commands_key = [];
}