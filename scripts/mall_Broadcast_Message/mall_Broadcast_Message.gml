/// @desc Represents one UI queue message.
/// @param {String} _text Message text.
/// @param {Constant.Color} [_color=c_white] Text color.
/// @param {Asset.Sprite} [_icon=undefined] Optional message icon.
function MallBroadcastMessage(_text, _color = c_white, _icon = undefined) constructor
{
    /// @desc Message text to display.
	/// @type {String}
    text = _text;
	
    /// @desc Message text color.
	/// @type {Constant.Color}
    color = _color;
	
    /// @desc Optional sprite shown with the message.
	/// @type {Asset.Sprite}
    icon = _icon;
}