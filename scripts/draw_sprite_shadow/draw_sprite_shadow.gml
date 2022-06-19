/// @param	direction
/// @param  distance
/// @param  scale
/// @param  colour
/// @param  alpha
/// @desc	Draws the shadow of a sprite
///			Using the calling object's x, y, image_angle, sprite_index & image_index
function draw_sprite_shadow(dir, len, sca, col, alp) {
	/*
	 * Example use:
	 * draw_sprite_shadow(270, 3, 1, c_black, 0.5);
	 * draw_self();
	 */

	var xx = x + lengthdir_x(len, dir);
	var yy = y + lengthdir_y(len, dir);
	
	gpu_set_fog(true, col, 0, 1);
		draw_sprite_ext(sprite_index, image_index, xx, yy, sca, sca, image_angle, c_white, alp);
	gpu_set_fog(0, 0, 0, 0);
}