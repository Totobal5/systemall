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
	
	#region JUGADOR
	// Protagonista
	// Personaje balanceado ente fisico y especial
	party_create_template(PARTY_NAME_JON     , function(_level, _vars) {
		show_debug_message("----- JÓN {0} -----", _level);
		
		// Primero crear entity 
		var _entity = new PartyEntity("PARTY.JON");
		var _stats = _entity.getStat();
		var _slots = _entity.getSlot();
		
		#region Stats
		_stats.setBase(
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
		
		// Establecer condicion global para subir de nivel
		_stats.setCheckLevel("fPartyCheckExp");

		// Subir de nivel
		_stats.LevelUp(true, _level, true);
		#endregion
		
		#region Slots
		_slots.setPermited(SLOT_ARMA  , [
			POCKET_ITEM_CUCHARITA,
			POCKET_ITEM_CUCHARA_PLASTICA, POCKET_ITEM_CUCHARA_HIERRO, POCKET_ITEM_CUCHARA_PLATA, 
			POCKET_ITEM_TENEDOR_PLASTICO, POCKET_ITEM_TENEDOR_HIERRO, POCKET_ITEM_TENEDOR_PLATA,
			POCKET_ITEM_CUCHARA_TENEDOR_HIERRO, POCKET_ITEM_CUCHARA_TENEDOR_PLATA,
			POCKET_ITEM_CUCHARON_HIERRO, POCKET_ITEM_CUCHARON_PLATA
		]);
		_slots.setPermited(SLOT_CUERPO, [
			POCKET_ITEM_CAMISA_COLEGIO,  POCKET_ITEM_CAMISA_CUADROS, POCKET_ITEM_CAMISA_VEBRES,
			POCKET_ITEM_POLERA_COLEGIO, POCKET_ITEM_POLERA_COLORIDA, POCKET_ITEM_POLERA_VEBRES
		]);

		_slots.setPermited(SLOT_ACCESORIO1, [
			POCKET_ITEM_GORRO_LANA, POCKET_ITEM_CRUZ, POCKET_ITEM_DIBUJO
		]);
		
		_slots.setPermited(SLOT_ACCESORIO2, [
			POCKET_ITEM_ZAPATOS_GASTADOS
		]);

		#endregion
		
		#region Vars
		_entity.setVar("Picture", spUIBox01);
		_entity.setVar("Object" , oCoJugadorParent);
		_entity.setVar("Instancia", noone);
		_entity.setVar("WaitFor"  , noone);

		_entity.setVar("ObjectVars", {
			sprite_index: spJonQuieto,
			image_index : EntityDir.izq,
			image_speed : 0
		});
		
		#endregion
		
		#region Commands
		_entity.setCommand("defaults",          "DARK.COMMAND.ATAQUE.01" , "ATAQUE.FISICO");
		_entity.setCommand(DARK_CATEGORY_CAST, "DARK.COMMAND.CAST.FORED")
		
		// Animacion de batalla 1 (Ataque fisicos)
		_entity.setVar("BattleAnimation01", method(_entity, function(_target, _command) {
			var _vtName = "BattleAnimation::" + key;
			var _vt = vuelta(_vtName, [
				new VueltaMove(  "instance", 1, -24, 0, true, 0.0, 0.1),
				new VueltaMethod(function() /*=>*/ {
					var _instance  = getVariable("instance");
					
					with (_instance) {
						customShader = shNegativeColor;
						call_later(.1, time_source_units_seconds, function() /*=>*/ {;customShader = noone});
					}
					
					// Sonido
					cueca_play(AUD_SOUND, snCombateGolpe01);
					
					// Avanzar mensajes y ejecutar comando de ataque fisico
					oCoManager.msgAdvance();
					var _this      = getVariable(  "this");
					var _objective = getVariable("target");
					var _command = getVariable("command");
					_command.exAction(_this, _objective);
					
				}),
				// Cambiar de color al target
				new VueltaMethod(function()/*=>*/{
					var _instance = getVariable("instanceT");
					with (_instance) {
						customShader = shNegativeColor;
						call_later(.1, time_source_units_seconds, function() /*=>*/ {;customShader = noone});
					}
					// Regresar personaje a donde estaba
					var _return = vuelta("BattleAnimation::ReturnPlayer", [
						new VueltaMove("instance" , 1, 24, 0, true)
					] )
					_return.setVariable("instance", getVariable("instance") );
					_return.start();
				}),
				new VueltaMove("instanceT", 2, -8, 0, true),
				new VueltaMove("instanceT", 2,  8, 0, true),
				new VueltaLoop(function() /*=>*/ {
					if (oCoManager.msgIsReady() ) {
						oCoManager.msgAdvance();
						return true;
					}
					
					return false;
				})
			] );
			
			_vt.setVariable("this"   , self);
			_vt.setVariable("command", _command);
			_vt.setVariable("target" ,  _target);
			_vt.setVariable("instance" , getVar("Instancia") );
			_vt.setVariable("instanceT", _target.getVar("Instancia") );
			
			setVar("WaitFor", _vt.start() );
		}) );
	

		#endregion
		
		return (_entity );
	});	

	// Protagonista
	// Atacante psiquico de gran poder y muchas habilidades variadas
	party_create_template(PARTY_NAME_GABI    , function(_level, _vars) {
		show_debug_message("----- GABI {0} -----", _level);
		
		var _entity = new PartyEntity("PARTY.GABI");
		var _stats = _entity.getStat();
		var _slots = _entity.getSlot();
		
		#region Stats
		_stats.setBase(
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
	
		// Establecer condicion global para subir de nivel
		_stats.setCheckLevel("fPartyCheckExp");

		// Subir de nivel
		_stats.LevelUp(true, _level, true);
		
		#endregion
		
		#region Slots
		_slots.setPermited(SLOT_ARMA  , [
			POCKET_ITEM_GUANTES_BLANCOS, POCKET_ITEM_GUANTES_NEGROS, POCKET_ITEM_GUANTES_ROJOS, POCKET_ITEM_GUANTES_VERDES,
			POCKET_ITEM_GUANTES_CUERO
		]);
		_slots.setPermited(SLOT_CUERPO, [
			POCKET_ITEM_PLATINAS_HIERRO  , POCKET_ITEM_PLATINAS_ECTO  , POCKET_ITEM_CHALECO_BLINDADO, POCKET_ITEM_CHALECO_IMBUIDO,
			POCKET_ITEM_CHALECO_REFORZADO, POCKET_ITEM_CHALECO_TRATADO, POCKET_ITEM_CHALECO_ELDRO   , POCKET_ITEM_CHALECO_ECTO   ,
			POCKET_ITEM_CHALECO_SQUAD    , POCKET_ITEM_CHALECO_ECTLDRO
		]);
		
		_slots.setPermited(SLOT_ACCESORIO1,  POCKET_ITEMTYPE_ACCES2);
		_slots.setPermited(SLOT_ACCESORIO2,  POCKET_ITEMTYPE_ACCES2);
		
		#endregion
		
		#region Vars
		_entity.setVar("Picture", spUIBox01);
		_entity.setVar("Object" , oCoJugadorParent);
		_entity.setVar("Instancia", noone);
		_entity.setVar("WaitFor"  , noone);
		#endregion
		
		#region Commands
		_entity.setCommand("defaults", "DARK.COMMAND.ATAQUE.01", "ATAQUE.FISICO");
		
		// Animacion de batalla 1 (Ataque fisicos)
		_entity.setVar("BattleAnimation01", method(_entity, function(_target, _command) {
			var _vtName = "BattleAnimation::" + key;
			var _vt = vuelta(_vtName, [
				new VueltaMove(  "instance", 1, -24, 0, true, 0.0, 0.1),
				new VueltaMethod(function() /*=>*/ {
					var _instance  = getVariable("instance");
					
					with (_instance) {
						customShader = shNegativeColor;
						call_later(.1, time_source_units_seconds, function() /*=>*/ {;customShader = noone});						
					}
					
					// Sonido
					cueca_play(AUD_SOUND, snCombateGolpe01);
					
					// Avanzar mensajes y ejecutar comando de ataque fisico
					oCoManager.msgAdvance();
					var _this      = getVariable(  "this");
					var _objective = getVariable("target");
					var _command = getVariable("command");
					_command.exAction(_this, _objective);
					
				}),
				// Cambiar de color al target
				new VueltaMethod(function()/*=>*/{
					var _instance = getVariable("instanceT");
					with (_instance) {
						customShader = shNegativeColor;
						call_later(.1, time_source_units_seconds, function() /*=>*/ {;customShader = noone});						
					}
					// Regresar personaje a donde estaba
					var _return = vuelta("BattleAnimation::ReturnPlayer", [
						new VueltaMove("instance" , 1, 24, 0, true)
					] )
					_return.setVariable("instance", getVariable("instance") );
					_return.start();
				}),
				new VueltaMove("instanceT", 2, -8, 0, true),
				new VueltaMove("instanceT", 2,  8, 0, true),
				new VueltaLoop(function() /*=>*/ {
					if (oCoManager.msgIsReady() ) {
						oCoManager.msgAdvance();
						return true;
					}
					
					return false;
				})
			] );
			
			_vt.setVariable("this"   , self);
			_vt.setVariable("command", _command);
			_vt.setVariable("target" ,  _target);
			_vt.setVariable("instance" , getVar("Instancia") );
			_vt.setVariable("instanceT", _target.getVar("Instancia") );
			
			setVar("WaitFor", _vt.start() );
		}) );
	
		#endregion
		
		return (_entity );
	});
	
	// Amiga y compañera de Jon
	// Atacante psiquico de baja defensas pero de alta velocidad
	party_create_template(PARTY_NAME_SUSANA  , function(_level, _vars) {
		show_debug_message("----- JÓN {0} -----", _level);
		
		var _entity = new PartyEntity   ("PARTY.SUSANA");
		var _stats = _entity.getStat();
		var _slots = _entity.getSlot();
		
		_stats.setBase(
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
		
		
		// Establecer condicion global para subir de nivel
		_stats.setCheckLevel("fPartyCheckExp");

		// Subir de nivel
		_stats.eventLevel(true, _level, true);

		_entity.setVar("Picture", spUIBox01);
		
		#region Commands

		
		#endregion
		
		
		
		
		return (_entity);
	});
	
	// "Niñero" de Gabi
	// Atacante fisico con ciertas habilidades psiquicas
	party_create_template(PARTY_NAME_FERNANDO, function(_level, _vars) {
		show_debug_message("----- FERNANDO {0} -----", _level);
		
		var _entity = new PartyEntity   ("PARTY.FERNANDO")
		var _stats = _entity.getStat();
		var _slots = _entity.getSlot();
		
		#region Stats
		_stats.setBase(
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
		// Establecer condicion global para subir de nivel
		_stats.setCheckLevel("fPartyCheckExp");

		// Subir de nivel
		_stats.LevelUp(true, _level, true);
		
		#endregion
		
		#region Slots
		_slots.setPermited(SLOT_ARMA      , [
			POCKET_ITEM_MONEDA_988  , POCKET_ITEM_MONEDA_942, POCKET_ITEM_MONEDA_NIQUEL,
			POCKET_ITEM_MONEDA_PLATA, POCKET_ITEM_MONEDA_ORO
		]);
		
		_slots.setPermited(SLOT_CUERPO, [
			POCKET_ITEM_PLATINAS_HIERRO  , POCKET_ITEM_PLATINAS_ECTO  , POCKET_ITEM_CHALECO_BLINDADO, POCKET_ITEM_CHALECO_IMBUIDO,
			POCKET_ITEM_CHALECO_REFORZADO, POCKET_ITEM_CHALECO_TRATADO, POCKET_ITEM_CHALECO_ELDRO   , POCKET_ITEM_CHALECO_ECTO   ,
			POCKET_ITEM_CHALECO_SQUAD    , POCKET_ITEM_CHALECO_ECTLDRO
		]);
		
		_slots.setPermited(SLOT_ACCESORIO1, [
			POCKET_ITEM_ANILLO_TAURO, POCKET_ITEM_ANILLO_ARIES, POCKET_ITEM_ANILLO_CAPRICORNIO
		]);
		_slots.setPermited(SLOT_ACCESORIO2, [
			POCKET_ITEM_AMULETO_GALLO
		
		]);
		
		#endregion
		
		#region Vars
		_entity.setVar("Picture", spUIBox01);
		_entity.setVar("Object" , oCoJugadorParent);
		_entity.setVar("Instancia" , noone);
		_entity.setVar("WaitFor"   , noone);
		_entity.setVar("ObjectVars", {
			sprite_index: spFernandoQuieto,
			image_index : EntityDir.izq,
			image_speed : 0
		});
		
		#endregion
		
		#region Commands
		_entity.setCommand("defaults", "DARK.COMMAND.ATAQUE.01", "ATAQUE.FISICO");
		
		// Animacion de batalla 1 (Ataque fisicos)
		_entity.setVar("BattleAnimation01", method(_entity, function(_target, _command) {
			var _vtName = "BattleAnimation::" + key;
			var _vt = vuelta(_vtName, [
				new VueltaMove(  "instance", 1, -24, 0, true, 0.0, 0.1),
				new VueltaMethod(function() /*=>*/ {
					var _instance  = getVariable("instance");
					
					with (_instance) {
						customShader = shNegativeColor;
						call_later(.1, time_source_units_seconds, function() /*=>*/ {;customShader = noone});						
					}
					
					// Sonido
					cueca_play(AUD_SOUND, snCombateGolpe01);
					
					// Avanzar mensajes y ejecutar comando de ataque fisico
					var _this      = getVariable(  "this");
					var _objective = getVariable("target");
					var _command = getVariable("command");
					
					oCoManager.msgAdvance();
					_command.exAction(_this, _objective);
				}),
				// Cambiar de color al target
				new VueltaMethod(function()/*=>*/{
					var _instance = getVariable("instanceT");
					with (_instance) {
						customShader = shNegativeColor;
						call_later(.1, time_source_units_seconds, function() /*=>*/ {;customShader = noone});						
					}
					// Regresar personaje a donde estaba
					var _return = vuelta("BattleAnimation::ReturnPlayer", [
						new VueltaMove("instance" , 1, 24, 0, true)
					] )
					_return.setVariable("instance", getVariable("instance") );
					_return.start();
				}),
				new VueltaMove("instanceT", 2, -8, 0, true),
				new VueltaMove("instanceT", 2,  8, 0, true),
				new VueltaLoop(function() /*=>*/ {
					if (oCoManager.msgIsReady() ) {
						oCoManager.msgAdvance();
						return true;
					}
					
					return false;
				})
			] );
			
			_vt.setVariable("this"   , self);
			_vt.setVariable("command", _command);
			_vt.setVariable("target" ,  _target);
			_vt.setVariable("instance" , getVar("Instancia") );
			_vt.setVariable("instanceT", _target.getVar("Instancia") );
			
			setVar("WaitFor", _vt.start() );
		}) );
	
		#endregion
		
		return (_entity );
	});
	
	// Fantasma que decide acompañar a Jon por un rato
	// Gran atacante fisico pero con velocidad
	party_create_template(PARTY_NAME_CARNICERO, function(_level, _vars) {
		show_debug_message("----- CARNICER0 {0} -----", _level);
		var _entity = new PartyEntity   ("PARTY.CARNICERO")
		var _stats = _entity.getStat();
		var _slots = _entity.getSlot();
		
		_stats.setBase(
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
		// Establecer condicion global para subir de nivel
		_stats.setCheckLevel("fPartyCheckExp");

		// Subir de nivel
		_stats.LevelUp(true, _level, true);
		
		_entity.setVar("Picture", spUIBox01);
		_entity.setVar("Object" , oCoJugadorParent);
		
		return (_entity );
	});
	
	#endregion

	#region ENEMIGOS
	/// Enemigo con altas defensas, en cierto turno evoluciona a un Dead Bird o a un Living Dead
	party_create_template("PARTY.FLOATING_HEAD", function(_level, _vars) {
		show_debug_message("----- FLOATING_HEAD {0} -----", _level);
		
		// Primero crear entity  50, 22, 1,  75, 100, 35, 100, 80,
		var _entity = (new PartyEntity("PARTY.FLOATING_HEAD") );
		var _stats = _entity.getStat();
		var _slots = _entity.getSlot();
		
		#region Stats
		// Establecer estadistica
		_stats.setBase(
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
		_stats.setCheckLevel("fPartyCheckExp");

		// Subir de nivel
		_stats.LevelUp(true, _level, true);
		
		#endregion
		
		#region Slot
		_slots.setPermited(SLOT_ARMA,  POCKET_ITEMTYPE_ENEMY);  // Permitir equipar armas de enemigos
		_slots.equip(SLOT_ARMA, choose("POCKET.ENE.MIRADA_DE_MIEDO", "POCKET.ENE.MIRADA_DE_TEMOR") );
		
		#endregion
		
		#region Commands
		_entity.setCommand("defaults", "DARK.COMMAND.ATAQUE.01");

		#endregion
		
		#region Vars
		_entity.setVar("Picture", spUIBox01);
		_entity.setVar("Object"   , oCoEnemyParent);
		_entity.setVar("Instancia", noone);
		_entity.setVar("WaitFor"  , noone);
		_entity.setVar("ObjectVars", {
			sprite_index: spEnFloatingHead,
			image_speed : 0
		});
		_entity.setVar("DropExp", 100);
		
		_entity.setVar("EnterAction", method(_entity, function(_team, _enemies) {
			/// @param {Struct.PartyEntity} v1
			/// @param {Struct.PartyEntity} v2
			static filterByEN = function(v1, v2) {
				// Hacer más rapido
				var _v1Stat = v1.getStat();
				var _v2Stat = v2.getStat();
				
				var _v1EN = _v1Stat.get(STAT_EN);
				var _v2EN = _v2Stat.get(STAT_EN);
				
				return (_v1EN.control - _v2EN.control);
			};
			
			var _target = 0;
			// Seleccionar al que posee menos vida de los enemigos
			if (percent_chance(80) ) {
				var _newArray = array_create(0);
				// Copiar array de enemigos
				array_copy(_newArray, 0, _enemies, 0, array_length(_enemies) );
				// Filtrar por EN
				array_sort(_newArray, filterByEN);
				
				_target = _newArray[0];
			} 
			// Selecciona al azar
			else {
				var _index = irandom(array_length(_enemies) - 1);
				_target = _enemies[_index];
			}
			
			var _command = getCommand("defaults", "DARK.COMMAND.ATAQUE.01");
			var _vt = vuelta("Ataque", [
				new VueltaMethod(function() /*=>*/ {
					// Enviar primer mensaje
					oCoManager.msgAdvance();
					oCoManager.msgSend("En la pensaá maxima", 60);	
				}),
				// Esperar que termine de escribir el mensaje
				new VueltaLoop(  function() /*=>*/ {
					return (oCoManager.msgIsReady() >= 1);
				}).setDelay(0.0, 0.1),
				new VueltaMethod(function() /*=>*/ {
					var _ins = getVariable("Instancia"), _tween;
					with (_ins) {
						_tween = TweenFire("~", EaseInCubic, "#", TWEEN_MODE_BOUNCE, "$", .1, "image_yscale>", 1.2);
						// -- Cambiar color
						customShader = shNegativeColor;
						// Regresar color a la normalidad
						call_later(0.2, time_source_units_seconds, function() /*=>*/ {customShader = noone;});						
					}
				}).setDelay(0.0, 0.1),
				new VueltaLoop(  function() /*=>*/ {
					var _tween = getVariable("Tween");
					// Avanzar cuando su tween termine
					if (!TweenIsActive(_tween) && oCoManager.msgIsReady() ) {
						var _command = getVariable("Command");
						var _this = getVariable("This")
						var _obje = getVariable("Objective"); /// @is {PartyEntity}
						// Desbloquear mensaje
						oCoManager.msgAdvance();
						_command.exAction(_this, _obje);
						
						// Reproducir sonido de golpe
						cueca_play(AUD_SOUND, snCombateGolpe01);
						
						// Cambiar color a la instancia del jugador
						var _objeIns = _obje.getVar("Instancia");
						with (_objeIns) {
							customShader = shNegativeColor;
							//image_alpha = 0;
							call_later(.2, time_source_units_seconds, function() /*=>*/ {customShader = noone;});
						}
						
						return true;
					}
					
					return false;
				})
			] );
			_vt.setVariable("This", self);
			_vt.setVariable("Objective", _target);
			_vt.setVariable("Command"  , _command);
			_vt.setVariable("Instancia", getVar("Instancia") );

			setVar("WaitFor", _vt.start());
		}) );

		#endregion
		
		
		
		return (_entity);
	});
	
	/// Enemigo debil a ataques fisicos y altamente resistente a ataques psiquicos. Posee mucha velocidad y ataque fisico
	party_create_template("PARTY.DEAD_BIRD", function(_level, _vars) {
		show_debug_message("----- DEAD BIRD {0} -----", _level);
		
		// Primero crear entity 22, 1, 130, 25, 1, 510, 100,
		var _entity = new PartyEntity("PARTY.DEAD_BIRD");
		var _stats = _entity.getStat();
		var _slots = _entity.getSlot();
		// Establecer estadistica
		_stats.setBase(
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
		_stats.setCheckLevel("fPartyCheckExp");

		// Subir de nivel
		_stats.LevelUp(true, _level, true);

		#region Slot
		_slots.setPermited(SLOT_ARMA,  POCKET_ITEMTYPE_ENEMY);  // Permitir equipar armas de enemigos
		_slots.equip(SLOT_ARMA, choose("POCKET.ENE.ALAS_DE_ECTO", "POCKET.ENE.ALAS_DE_PETO") );
		
		#endregion

		#region Vars
		_entity.setVar("Picture", spUIBox01);
		_entity.setVar("Object" , oCoEnemyParent);
		
		#endregion
		
		return (_entity);
	});
	
	/// Enemigo debil a ataques psiquicos y altamente resistente a ataques fisicos. Posee mucho ataque psiquico
	party_create_template("PARTY.ZOMBIE", function(_level, _vars) {
		show_debug_message("----- ZOMBIE {0} -----", _level);
		
		// Primero crear entity 22, 1, 130, 25, 1, 510, 100,
		var _entity = new PartyEntity("PARTY.ZOMBIE");
		var _stats = _entity.getStat();
		var _slots = _entity.getSlot();
		// Establecer estadistica
		_stats.setBase(
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
		_stats.setCheckLevel("fPartyCheckExp");

		// Subir de nivel
		_stats.LevelUp(true, _level, true);
		
		#region Slots
		_slots.setPermited(SLOT_ARMA, POCKET_ITEMTYPE_ENEMY);
		_slots.equip(SLOT_ARMA, "POCKET.ENE.BLOOD");
		
		#endregion
		
		#region Vars
		_entity.setVar("Picture", spUIBox01);
		_entity.setVar("Object" , oCoEnemyParent);
		
		#endregion
		
		return (_entity);
	});
	
	
	#endregion
}