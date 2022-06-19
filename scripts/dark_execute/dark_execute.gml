function dark_execute(_key, _caster, _target, _extra)
{
	var _dark = dark_get(_key);
	return (_dark.execute(_caster, _target, _extra) );
}