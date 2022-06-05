/// @param {Resource.GMSprite} _sprite
/// @param {Real} _xscale
/// @param {Real} _yscale
/// @param {Constant.HAlign} [_halign]
/// @param {Constant.VAlign} [_valign]
function lima_set_sprite(_sprite, _xscale, _yscale, _halign, _valign) {
	sprite_index = _sprite;
	
	image_xscale = _xscale;
	image_yscale = _yscale;
	
	halign = _halign;
	valign = _valign;
	
	lima_place(x, y);
} 