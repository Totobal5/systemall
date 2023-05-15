// Feather ignore all
function pocket_save(_bagKey)
{
	var _bag = pocket_get_bag(_bagKey);
	return (_bag.save() );
}