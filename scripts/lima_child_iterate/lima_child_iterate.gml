/// @param {Function} _function
function lima_child_iterate(_function) {
	var i=0; repeat(array_length(childrens) ) {
		_function(childrens[i], i++);
	}
}