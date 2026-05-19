/// @description
var _hor = keyboard_check(vk_right) - keyboard_check(vk_left);
var _ver = keyboard_check(vk_down ) - keyboard_check(vk_up);

x += _hor * 3;
y += _ver * 3;