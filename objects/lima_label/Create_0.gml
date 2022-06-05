/// @description [TEXT]
/// LIMA ELEMENTS USE SCRIBBLE AND LEXICON
#region PRIVATE
event_inherited();
__lima_initalize(LIMA_TYPE.TEXT);

sprite_index = noone;

#endregion

#region PUBLIC
/*
	La variable text puede ser un simple texto, pero si esta posee los simbolos $ o %s realizará un parser con los elementos de
	textLexicon
*/
if (font_exists(font) ) {
	font = font_get_name(font);	
}
else if (sprite_exists(font) ) {
	font = sprite_get_name(font);
}

w = (is_array(size) ) ? size[0] : size;
h = (is_array(size) ) ? size[1] : size;

skb = (scribble("") ).starting_format("fLimaText", c_white);
typ = scribble_typist().pause();

// Valor para guardar valores.
parserText  = text;	// Texto final luego de los parser
pointerCount = string_count("$l", text);
array_resize(pointer, pointerCount);

valuesCount = string_count("%s", text);
array_resize(values, valuesCount);
 
#endregion

#region METHODS
/// @desc Template para interactivos (Select, Deselect, Aim, Desactive)
updateTemplate = function() {
	if (isActive) {
		if (isFocus) {
			if (templatesActual != "Select") {
				lima_template_execute("Select");	 
				templatesActual = "Select";
			}
		}
		else {
			if (templatesActual != "Deselect") {
				lima_template_execute("Deselect"); 
				templatesActual = "Deselect";
			}
		}	
	}
	else {
		if (isFocus) {
			if (templatesActual != "Aim") {
				lima_template_execute("Aim");
				templatesActual = "Aim";
			}
		}
		else {
			if (templatesActual != "Desactive") {
				lima_template_execute("Desactive"); 
				templatesActual = "Desactive";
			}
		}
	}
}

/// @desc inicia el scribble del elemento con los valores establecidos en las variable definition
defaultTemplate = function(_force=false) {
	#region Simple Parser
	var _value, i;
		
	parserText = text;
		
	// -- LEXICON --
	pointerCount = string_count("$l", text);
	array_resize(pointer, pointerCount);
		
	i=0; repeat (pointerCount) {
		_value = string(pointer[i++] );
		parserText = string_replace(parserText, "$l", lexicon_text(_value) );	
	}
		
	// -- REPLACE VALUE --
	valuesCount = string_count("%s", text);
	array_resize(values, valuesCount);
		
	i=0; repeat (valuesCount) {
		_value = string(values[i++] );
		parserText = string_replace(parserText, "%s", _value);	
	}
				
	#endregion
	
	skb = scribble(parserText, __numberId);
	skb.starting_format(font, c_white);
	skb.align(halign, valign);
	skb.transform(w, h, angle);
		
	if (wrap)		skb.wrap(wrapW, wrapH, wrapChar); 
	if (thick > 0)  skb.msdf_border(thickColor, thick);
}

/// @desc Solo actualizar el texto, pasando parser para valores (%s) y lexicon ($l)
reorganize = function() {
	#region Simple Parser
	var _value, i;
		
	parserText = text;
		
	// -- LEXICON --
	pointerCount = string_count("$l", text);
	array_resize(pointer, pointerCount);
		
	i=0; repeat (pointerCount) {
		_value = string(pointer[i++] );
		parserText = string_replace(parserText, "$l", lexicon_text(_value) );	
	}
		
	// -- REPLACE VALUE --
	valuesCount = string_count("%s", text);
	array_resize(values, valuesCount);
		
	i=0; repeat (valuesCount) {
		_value = string(values[i++] );
		parserText = string_replace(parserText, "%s", _value);	
	}
				
	#endregion
	
	lima_template_execute("Change");
	skb.overwrite(parserText, __numberId);
}

/// @desc Buscar valores
checkFor = function() {return false; }

/// @param {Real} _index
get = function(_index) {
	return (values[_index] );
}

/// @param {Real} _index
/// @param _value
set = function(_index, _value) {
	values[_index] = _value;
	return true;
}

#endregion

if (__parent == lima_parent) event_user(0);