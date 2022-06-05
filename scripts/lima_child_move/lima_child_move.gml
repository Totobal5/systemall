/// @desc Mueve todos los hijos que son relativos en relacion a la posicion del padre
function lima_child_move() {
	/// @context {lima_parent}
	var i=0; repeat(array_length(childrens) ) {
		with (childrens[i++] ) {
			// Solamente si es relativo al padre
			if (relative == other) {
				lima_place(relative_x, relative_y, other);	
			}
		}
	}	
}