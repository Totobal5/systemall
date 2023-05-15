/// @param {string} templateKey  Llave template de Wate
/// @return {function}
function wate_get_template(_wateKey) 
{
    static database = MallDatabase.wate.templates;
	return (database[$ _wateKey] );
}