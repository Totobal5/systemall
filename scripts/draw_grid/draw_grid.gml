/// @param {Real} _size Tamaño de la grid
function draw_grid(_size) {
	var _w = display_get_gui_width ();
	var _h = display_get_gui_height();

	for(var i=0; i<= max(_w, _h); i += _size) {
	     draw_line(0, i, _w, i);
	     draw_line(i, 0, i, _h);
	}	
}