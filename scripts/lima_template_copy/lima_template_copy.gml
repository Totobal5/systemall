/// @param _template
/// @param _instance
/// @desc Copiar templates
function lima_template_copy(_template, _instance) {
	var _method;
	with (_instance) _method = lima_template_get(_template);
	lima_template_set(_template, _method);
}