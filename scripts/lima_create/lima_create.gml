function lima_create(_x, _y, _layer, _lima_object, _pre_create={} ) {
	// Añadir creador
	_pre_create[$ "creator"] = other;
	var _ins = instance_create_layer(_x, _y, _layer, _lima_object, _pre_create);
	
	/// @context {lima_parent}
	with (_ins) {
		lima_parent_set(parent);
		
		// Reposicionar
		lima_place(_x, _y, relative);
		
		#region Eventos
		var _save = eventStart;
		eventStart = method(undefined, _save) ();
		
		_save = eventEnd;
		eventEnd = method(undefined, _save);
		#endregion
	}
}