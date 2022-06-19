/// @param {Struct.Tree}	tree
/// @desc Comprueba que "tree" sea una clase Tree
/// @return {Bool}
function is_tree(_tree) 
{
    return (is_struct(_tree) && instanceof(_tree) == "Tree");
}