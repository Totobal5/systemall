/// @param  {string} darkKey
/// @param	{Real}   consume               Cuanto gasta para usar este comando
/// @param	{Bool}   [includeCaster]=true  El caster tambien puede ser afectado
/// @param	{Real}   [targets]=1           Cantidad de objetivos afectados
/// @return {Struct.DarkCommand}
function DarkCommand(_darkKey, _consume=0, _include=true, _targets=1) : Mall(_darkKey) constructor 
{
	vars = {};
	consume = _consume;  // Cuanto de algo consume
	include = _include;  // Si el caster es incluido
	targets = _targets;  // Cuantos targets puede incluir en el hechizo
	
	// function(_caster, _target, _vars) {}
	
	/// @desc funcion para comprobar si acierta o falla
	/// @returns {Bool}
	check   = __dummy;
	
	/// @desc funcion que ejecuta al acertar
	execute = __dummy;
	
	/// @desc funcion que ejecuta al fallar
	fail    = __dummy;
	
	/// @param checkFun function(_caster, _target, _vars) {}
	static setCheck   = function(_fun) 
	{
		check = method(,_fun);
		return self;
	}

	/// @param executeFun function(_caster, _target, _vars) {}
	static setExecute = function(_fun)
	{
		execute = method(,_fun);
		return self;
	}
	
	/// @param failFun function(_caster, _target, _vars) {}
	static setFail    = function(_fun) 
	{
		fail = method(,_fun);
		return self;
	}
}