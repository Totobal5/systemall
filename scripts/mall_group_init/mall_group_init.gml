/// @desc Inicia todo los componentes del grupo actual
/// @return {Struct.MallGroup}
function mall_group_init() 
{
	return (global.__mall_group_actual.initialize() );	
}