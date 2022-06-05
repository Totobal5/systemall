/// @param {Id.Instance} _parent	Indicar padre
function lima_parent_set(_parent) {
	if (!is_lima(_parent) && _parent == id) exit;
	parent = _parent;
	array_push(parent.childrens, id);
}