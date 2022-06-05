/// @param {Real} _x
/// @param {Real} _y
function draw_crosshair(_x, _y) {
	draw_line(0, _y, display_get_gui_width(), _y);
    draw_line(_x, 0, _x, display_get_gui_height() );
}