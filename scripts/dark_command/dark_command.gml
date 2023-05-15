/// @param  {string} darkKey
/// @param	{Real}   consume               Cuanto gasta para usar este comando
/// @param	{Bool}   [includeCaster]=true  El caster tambien puede ser afectado
/// @param	{Real}   [targets]=1           Cantidad de objetivos afectados
/// @return {Struct.DarkCommand}
function DarkCommand(_darkKey, _consume=0, _include=true, _targets=1) : MallComponent(_darkKey, false) constructor 
{
	type = "";
	consume = _consume;  // Cuanto de algo consume
	targets = _targets;  // Cuantos targets puede incluir en el hechizo
	
	onSelf    = _include // Si se puede usar en si mismo
	onAllies  = true;    // Si se puede usar en aliados
	onEnemies = true;    // Si se puede usar en enemigos

	// function(_caster, _target, _vars) {}
	
	/// @desc funcion para comprobar si acierta o falla
	/// @returns {Bool}
	funCheck   = function(_caster, _target) {};
	
	/// @desc funcion que ejecuta al acertar
	funAction = function(_caster, _target) {};
	
	/// @desc funcion que ejecuta al fallar
	funFail   = function(_caster, _target) {};
	
	/// @param checkFun function(_caster, _target, _vars) {}
	static setCheck   = function(_fun) 
	{
		funCheck = method(,_fun);
		return self;
	}

	/// @param executeFun function(_caster, _target, _vars) {}
	static setExecute = function(_fun)
	{
		funAction = method(,_fun);
		return self;
	}
	
	/// @param failFun function(_caster, _target, _vars) {}
	static setFail    = function(_fun) 
	{
		funFail = method(,_fun);
		return self;
	}
	
	static setType = function(_type)
	{
		type = _type;
		return self;
	}
	
	
	static exAction = function(_caster, _target)
	{
		return (funAction(_caster, _target) );
	}
	
	static exCheck  = function(_caster, _target)
	{
		return (funCheck(_caster, _target) );
	}
	
}
