/// @param [root_value]
/// @return {Struct.Tree}
function tree_create(_root_value = 0) 
{
	return (new Tree("root", _root_value, true) );
}