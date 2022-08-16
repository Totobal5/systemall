/// @param	{Real}		consume				Cuanto gasta para usar este comando
/// @param	{Bool}		[include_caster]	El caster tambien puede ser afectado
/// @param	{Real}		[targets]			Cantidad de objetivos afectados
/// @return {Struct.DarkCommand}
function DarkCommand(_CONSUME=0, _INCLUDE=true, _TARGETS=1) : MallComponent("") constructor 
{
	#region PRIVATE
	__is = instanceof(self);
	
	#endregion
	
	flag = "";
	consume = _CONSUME;	// Cuanto de algo consume
	include = _INCLUDE;	// Si el caster es incluido
	targets = _TARGETS;	// Cuantos targets puede incluir en el hechizo
	
	checkExecute = function(caster, target, flag) {}	// Para check
	eventExecute = function(caster, target, flag) {}	// Evento que ejecuta al ser usado
	eventFail = function(caster, target, flag) {}		// Evento que ejecuta al 
	
	static setEventExecute = function(_METHOD)
	{
		eventExecute = _METHOD;
		return self;
	}
}