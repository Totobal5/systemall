function PartyEntity(_GROUP_KEY, _DISPLAY_KEY, _DISPLAY_METHOD) : MallComponent("") constructor 
{
	setDisplay(_DISPLAY_KEY, _DISPLAY_METHOD);
	group = _GROUP_KEY;	// Key del party group
	index = -1;			// Indice del party group
	
	// Estructuras
	stats   = undefined;	// Estadisticas
	control = undefined;	// Control de estados / buffos
	equipment = undefined;	// Equipo y partes
	
	turnCombat  = 0; // En que turno se mueve
	turnControl = 0; // Numero de turnos que han habido 
	
	pass = false;	// Si se salta un turno
	passCount = 0;	// Cuantos turnos a saltado
	passReset = 0;	// Reiniciar __pass a esta cantidad de turnos -1 es infinito
	
	commands = {};	// Que comandos puede realizar
	modifys  = {};
	// {modificador: []}
	
	#region Metodos
	/// @return {Struct.PartyStats}
	static getStats		= function()
	{
		return (stats);	
	}
	
	/// @return {Struct.PartyControl}
	static getControl	= function()
	{
		return (control);
	}
	
	/// @return {Struct.PartyEquipment}
	static getEquipment = function()
	{
		return (equipment);
	}
	
	static updateComponents = function()
	{
		stats	.getComponents();
		control	.getComponents();
		equipment.getComponents();
	}
	
	#endregion
}