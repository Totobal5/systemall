#macro PARTY_GP_PRINCIPAL   "HEROES"
#macro PARTY_GP_SECUNDARIO  "RESERVA"
#macro PARTY_GP_NOUSE       "NOUSE"

#macro PARTY_NAME_JON		"PARTY.JON"
#macro PARTY_NAME_SUSANA	"PARTY.SUSANA"
#macro PARTY_NAME_GABI		"PARTY.GABI"
#macro PARTY_NAME_FERNANDO	"PARTY.FERNANDO"
#macro PARTY_NAME_CARNICERO "PARTY.CARNICERO"

/// @ignore
function party_database() 
{
	party_group_create(PARTY_GP_PRINCIPAL );    // Donde estan los heroes (estos son los que salen a pelear)
	party_group_create(PARTY_GP_SECUNDARIO);    // Donde se guardaran las reservas
	
	party_group_create(PARTY_GP_NOUSE);         // No estan presentes en la party actual

}


function EntityDfLevelUp() 
{
	var _exp = statGet(STAT_EXP);
	return (_exp.actual == _exp.peak);
}


function Entity(_key) : PartyEntity(_key) constructor
{
	// Variables comunes
	picture  = noone;
	object   = noone;
	instance = noone;
	
	// Que esperar
	waitFor  = noone;
	
	objectVars = {};
}

// Protagonista
// Personaje balanceado ente fisico y especial
function EntityJon(_level) : Entity(PARTY_NAME_JON) constructor 
{
	show_debug_message("----- JON {0} -----", _level);
	
	// -- Otros
	displayKey = key;
	
	picture = noone;
	object  = noone;
	instance = noone;
	
	// -- Stats
	statSetBase(
		STAT_EN ,  9999, MALL_NUMTYPE.REAL, // 44 
		STAT_EPM,  9999, MALL_NUMTYPE.REAL, // 4.4
			
		STAT_FUERZA,    70, MALL_NUMTYPE.REAL,
		STAT_DEFENSA,   75, MALL_NUMTYPE.REAL,
		STAT_FESPECIAL, 70, MALL_NUMTYPE.REAL,
		STAT_DESPECIAL, 52, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, 58, MALL_NUMTYPE.REAL,
		STAT_EXP      , 42, MALL_NUMTYPE.REAL,
		STAT_CRITICO  , 10, MALL_NUMTYPE.PERCENT
		);
	// Solo si exp actual es igual al peak
	fnCLevel = method(self, EntityDfLevelUp);
	// Subir de nivel
	levelUp(true, _level, true);
		
	// -- Slots
	slotCreate(SLOT_ARMA);
	slotCreate(SLOT_CUERPO);
	slotCreate(SLOT_ACCESORIO1);
	slotCreate(SLOT_ACCESORIO2);
		
	slotPermitedAdd(SLOT_ARMA, [
		IT_JonCucharita    , IT_JonCucharaPlastica, IT_JonTenedorPlastico, IT_JonCucharaHierro,
		IT_JonTenedorHierro, IT_JonCucharaPlata,    IT_JonTenedorPlata   , 
		IT_JonCTHierro     , IT_JonCTPlata     ,    IT_JonCucharonHierro , 
		]);
	
	
	setCommand(, new DK_DJonAttack());
}

// Protagonista
// Atacante psiquico de gran poder y muchas habilidades variadas
function EntityGabi(_level) : Entity(PARTY_NAME_GABI) constructor
{
	show_debug_message("----- GABI {0} -----", _level);
	
	// -- Otros
	displayKey = key;
	
	// -- Stats
	setBase(
		STAT_EN ,  28, MALL_NUMTYPE.REAL,
		STAT_EPM,  13, MALL_NUMTYPE.REAL,
			
		STAT_FUERZA,      40,  MALL_NUMTYPE.REAL,
		STAT_DEFENSA,     60,  MALL_NUMTYPE.REAL,
		STAT_FESPECIAL,  180,  MALL_NUMTYPE.REAL,
		STAT_DESPECIAL,  150,  MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD,   74,  MALL_NUMTYPE.REAL,
		STAT_EXP      ,   25,  MALL_NUMTYPE.REAL,
		STAT_CRITICO  ,    0,  MALL_NUMTYPE.PERCENT
		);
		
	fnCLevel = method(self, EntityDfLevelUp);
	levelUp(true, _level, true);
	
	// -- Slots
	slotCreate(SLOT_ARMA);
	slotCreate(SLOT_CUERPO);
	slotCreate(SLOT_ACCESORIO1);
	slotCreate(SLOT_ACCESORIO2);
	
	slotPermitedAdd(SLOT_ARMA  , [
		IT_GabiGuantesBlancos, IT_GabiGuantesNegros, IT_GabiGuantesRojos, IT_GabiGuantesVerdes, 
		IT_GabiGuantesCuero  
		]);
	slotPermitedAdd(SLOT_CUERPO, [
		IT_CPPlatinasHierro,   IT_CPPlatinasEcto,   IT_CPChalecoBlindado, IT_CPChalecoImbuido,
		IT_CPChalecoReforzado, IT_CPChalecoTratado, IT_CPChalecoEldro,    IT_CPChalecoEcto,
		IT_CPChalecoSquad,     IT_CPChalecoEctldro
		]);
	
	slotPermitedAdd(SLOT_ACCESORIO1,  POCKET_ITEMTYPE_ACCES2);
	slotPermitedAdd(SLOT_ACCESORIO2,  POCKET_ITEMTYPE_ACCES2);
	
	
	setCommand(, new DK_DGabiAttack());
}

// Amiga y compañera de Jon
// Atacante psiquico de baja defensas pero de alta velocidad
function EntitySusana(_level) : Entity(PARTY_NAME_SUSANA) constructor
{
	// -- Otros
	displayKey = key;
	
	// -- Stats
	statSetBase(
		STAT_EN ,  34, MALL_NUMTYPE.REAL,
		STAT_EPM,   8, MALL_NUMTYPE.REAL,
		
		STAT_FUERZA,      40, MALL_NUMTYPE.REAL,
		STAT_DEFENSA,     45, MALL_NUMTYPE.REAL,
		STAT_FESPECIAL,  120, MALL_NUMTYPE.REAL,
		STAT_DESPECIAL,   60, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD,   84, MALL_NUMTYPE.REAL,
		STAT_EXP      ,   40, MALL_NUMTYPE.REAL,
		STAT_CRITICO  ,   10, MALL_NUMTYPE.PERCENT
		);
	// Para subir de nivel
	fnCLevel = method(self, EntityDfLevelUp);
	levelUp(true, _level, true);
}

// "Niñero" de Gabi
// Atacante fisico con ciertas habilidades psiquicas
function EntityFernando(_level) : Entity(PARTY_NAME_FERNANDO) constructor
{
	show_debug_message("----- FERNANDO {0} -----", _level);
	
	// -- Otros
	displayKey = key;
	
	// -- Stats
	statSetBase(
		STAT_EN ,  40, MALL_NUMTYPE.REAL,
		STAT_EPM,   6, MALL_NUMTYPE.REAL,
			
		STAT_FUERZA,    92, MALL_NUMTYPE.REAL,
		STAT_DEFENSA,   64, MALL_NUMTYPE.REAL,
		STAT_FESPECIAL, 60, MALL_NUMTYPE.REAL,
		STAT_DESPECIAL, 65, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, 54, MALL_NUMTYPE.REAL,
		STAT_EXP      , 60, MALL_NUMTYPE.REAL,
		STAT_CRITICO  , 10, MALL_NUMTYPE.PERCENT
		);

	// Para subir de nivel
	fnCLevel = method(self, EntityDfLevelUp);
	levelUp(true, _level, true);
	
	// -- Slots
	slotCreate(SLOT_ARMA);
	slotCreate(SLOT_CUERPO);
	slotCreate(SLOT_ACCESORIO1);
	slotCreate(SLOT_ACCESORIO2);	
	
	slotPermitedAdd(SLOT_ARMA, [
		IT_FernMoneda988,   IT_FernMoneda942, IT_FernMonedaNiquel,
		IT_FernMonedaPlata, IT_FernMonedaOro
		]);
		
	slotPermitedAdd(SLOT_CUERPO, [
		IT_CPPlatinasHierro,   IT_CPPlatinasEcto,   IT_CPChalecoBlindado, IT_CPChalecoImbuido,
		IT_CPChalecoReforzado, IT_CPChalecoTratado, IT_CPChalecoEldro,    IT_CPChalecoEcto,
		IT_CPChalecoSquad,     IT_CPChalecoEctldro
		]);
		
	slotPermitedAdd(SLOT_ACCESORIO1, [IT_ACCAnilloToro, IT_ACCAnilloCabra, IT_ACCAnilloCaballo]);
	slotPermitedAdd(SLOT_ACCESORIO2, [IT_ACCAnilloGallo]);	
	
	
	// -- Comandos
	setCommand(, new DK_DFernAttack());
}

// Fantasma que decide acompañar a Jon por un rato
// Gran atacante fisico pero con velocidad
function EntityCarnicero(_level) : Entity(PARTY_NAME_CARNICERO) constructor
{
	// -- Stats
	statSetBase(
		STAT_EN ,   60, MALL_NUMTYPE.REAL,
		STAT_EPM,  0.5, MALL_NUMTYPE.REAL,
			
		STAT_FUERZA,    130, MALL_NUMTYPE.REAL,
		STAT_DEFENSA,    90, MALL_NUMTYPE.REAL,
		STAT_FESPECIAL,  20, MALL_NUMTYPE.REAL,
		STAT_DESPECIAL,  30, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD,  37, MALL_NUMTYPE.REAL,
		STAT_EXP      ,  60, MALL_NUMTYPE.REAL,
		STAT_CRITICO  ,   5, MALL_NUMTYPE.PERCENT
		);	
	// Solo si exp actual es igual al peak
	fnCLevel = method(self, EntityDfLevelUp);
	// Subir de nivel
	levelUp(true, _level, true);
}


#region Enemigos
/// Enemigo con altas defensas, en cierto turno evoluciona a un Dead Bird o a un Living Dead
function EntityEFloatingHead(_level=1) : Entity("PARTY.FLOATING.HEAD") constructor
{
	// -- Otros
	displayKey = key;
	
	// -- Stats
	setBase(
		STAT_EN ,  1, MALL_NUMTYPE.REAL, //22
		STAT_EPM,   4, MALL_NUMTYPE.REAL,
			
		STAT_FUERZA,     75, MALL_NUMTYPE.REAL,
		STAT_DEFENSA,   100, MALL_NUMTYPE.REAL,
		STAT_FESPECIAL,  35, MALL_NUMTYPE.REAL,
		STAT_DESPECIAL, 100, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD,  80, MALL_NUMTYPE.REAL,
		STAT_EXP      ,  38, MALL_NUMTYPE.REAL,
		STAT_CRITICO  ,  10, MALL_NUMTYPE.PERCENT
		);
		
	// Establecer condicion global para subir de nivel
	fnCLevel = method(self, EntityDfLevelUp);
	
	// Subir de nivel
	levelUp(true, _level, true);
	
	// -- Slots
	slotCreate(SLOT_ARMA)
	slotPermitedAdd(SLOT_ARMA, POCKET_ITEMTYPE_ENEMY);
	
	// Equipar arma al enemigo
	slotEquip(SLOT_ARMA, IT_EnemyMiradaMiedo);
	
	
}

/// Enemigo debil a ataques fisicos y altamente resistente a ataques psiquicos. Posee mucha velocidad y ataque fisico
function EntityEFDeadBird(_level=1) : Entity("PARTY.DEAD.BIRD") constructor
{
	displayKey = key;	
	
	// -- Stats
	statSetBase(
		STAT_EN ,  22, MALL_NUMTYPE.REAL,
		STAT_EPM,   1, MALL_NUMTYPE.REAL,
			
		STAT_FUERZA,     25, MALL_NUMTYPE.REAL,
		STAT_DEFENSA,   255, MALL_NUMTYPE.REAL,
		STAT_FESPECIAL, 140, MALL_NUMTYPE.REAL,
		STAT_DESPECIAL,  50, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD,  80, MALL_NUMTYPE.REAL,
		STAT_EXP      ,  42, MALL_NUMTYPE.REAL,
		STAT_CRITICO  ,  10, MALL_NUMTYPE.PERCENT
		);	

	// Establecer condicion global para subir de nivel
	fnCLevel = method(self, EntityDfLevelUp);
	
	// Subir de nivel
	levelUp(true, _level, true);

	// -- Slots
	slotCreate(SLOT_ARMA);
	slotPermitedAdd(SLOT_ARMA, POCKET_ITEMTYPE_ENEMY);
	
	// Varios tipos de equipamiento
	var _choice = choose("A", "B");
	if (_choice == "A") {slotEquip(SLOT_ARMA, IT_EnemyAlasEcto); } else 
	if (_choice == "B") {slotEquip(SLOT_ARMA, IT_EnemyAlasPeto); }
}

/// Enemigo debil a ataques psiquicos y altamente resistente a ataques fisicos. Posee mucho ataque psiquico
function EntityEFLivingDead(_level=1) : Entity("PARTY.LIVING.DEAD") constructor
{
	displayKey = key;
	
	// -- Stats
	statSetBase(
		STAT_EN ,  22, MALL_NUMTYPE.REAL,
		STAT_EPM,   1, MALL_NUMTYPE.REAL,
		
		STAT_FUERZA,    130, MALL_NUMTYPE.REAL,
		STAT_DEFENSA,    50, MALL_NUMTYPE.REAL,
		STAT_FESPECIAL,   1, MALL_NUMTYPE.REAL,
		STAT_DESPECIAL, 255, MALL_NUMTYPE.REAL,
		STAT_VELOCIDAD, 100, MALL_NUMTYPE.REAL,
		STAT_EXP      ,  45, MALL_NUMTYPE.REAL,
		STAT_CRITICO  ,  10, MALL_NUMTYPE.PERCENT
		);	

	// Establecer condicion global para subir de nivel
	fnCLevel = method(self, EntityDfLevelUp);
	
	// Subir de nivel
	levelUp(true, _level, true);

	// -- Slots
	slotCreate(SLOT_ARMA);
	slotPermitedAdd(SLOT_ARMA, POCKET_ITEMTYPE_ENEMY);
	
	slotEquip(SLOT_ARMA, IT_EnemyDBlood);
}

#endregion















