/// @param {Struct.DarkCommand} command
function dark_create(_command) 
{
	static database = MallDatabase.dark;
	if (!struct_exists(database, _command.key) ) {
		database[$ _command.key] = _command;
	}
}

/// @param {Struct.PocketItem} command
function pocket_create(_item)
{
	static database = MallDatabase.items;
	if (!struct_exists(database, _item.key) ) {
		database[$ _item.key] = _item;
	}
}