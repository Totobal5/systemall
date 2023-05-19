/// @param  {string} darkKey
/// @return {Struct.DarkCommand}
function DarkCommand(_key) : Mall(_key) constructor 
{
	type = "";  // Tipo de comando
	consume = 0;  // Cuanto de algo consume
	targets = 1;  // Cuantos targets puede incluir en el hechizo
	
	onSelf    = false;  // Si se puede usar en si mismo
	onAllies  = true;   // Si se puede usar en aliados
	onEnemies = true;   // Si se puede usar en enemigos
	
	/// @desc funcion para comprobar si acierta o falla
	/// @returns {Bool}
	static check  = function(_caster, _target) {};
	
	/// @desc funcion que ejecuta al acertar
	static action = function(_caster, _target) {};
	
	/// @desc funcion que ejecuta al fallar
	static fail   = function(_caster, _target) {};
	
	static cinematic = function() {}
}
