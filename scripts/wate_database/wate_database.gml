function wate_database() 
{
	dark_create_function("fWateComplete", function(_target, _caster) {
		/// @context {Struct.WateManager}
		var i=0; repeat(array_length(loot) ) {
			var _lt = loot[i];
			switch (_lt.type) {
				case   "stat": #region Añadir un valor a una stat
					var _entitys = groups.every, _sval;
					var j=0; repeat(array_length(_entitys) ) {
						var _en = _entitys[j];
						// Obtener componentes
						var _stat = _en.getStat();
						var _cont = _en.getControl();
						// Si ha perdido esta entidad aplicar la mitad del valor
						if (!_cont.isAffected(_lt.reduceKey) ) {
							_sval = _lt.value div _lt.reduce;
						} else {
							_sval = _lt.value;
						}
						
						_stat.add(_lt.key, _sval);
						_stat.LevelUp(false,   1);
						
						j++;
					}
				break;
				#endregion
			
				case "object": #region Añadir objeto
				
				break;
				#endregion
			}
		}
	});
	
	
	wate_create_template("GHOSTS.SIMPLE", function(_level, _rmGo) {
		var _mn   = new WateManager("df");
		// Crear al manager de combates
		var _comn = instance_create_layer(0, 0, LYR_CONTROLLERS, oCoManager, { 
			wate: _mn
		});
		
		// Enemigos
		var _enems = [];
		var _enem1 = party_create("PARTY.FLOATING_HEAD",, irandom_range(48, 55) );
		_mn.add("enemys", _enem1);
		
		
		// Agregar otro enemigo
		if (percent_chance(60) ) {
			var _enem2 = party_create("PARTY.FLOATING_HEAD",, irandom_range(48, 50) );
			_mn.add("enemys", _enem2);
		}
		
		// Ultimo enemigo más poderoso
		if (percent_chance(30) ) {
			var _enem3 = party_create("PARTY.FLOATING_HEAD",, irandom_range(52, 54) );
			_mn.add("enemys", _enem3);
		}
    
		// Agregar jugadores al manager
		var _party = party_group_get(PARTY_GP_PRINCIPAL);
		var _partyArray = _party.entitys;
		var i=0; repeat(array_length(_partyArray) ) {
			var _eny = _partyArray[i];
			_mn.add("players", _eny);
			i++;
		}
		
		/*
		// Ordenar por velocidad (todos)
		var _grp = _mn.groups;
		/// @param {Struct.PartyEntity} v1
		/// @param {Struct.PartyEntity} v2
		var _fun = function(v1, v2) {
			// Hacer más rapido
			var _v1Speed, _v2Speed;
			if (!v1.existsVar("fastVel") ) {
				var _v1Stat  = v1.getStat();
				var _v1Speed = _v1Stat.get(STAT_VELOCIDAD);
				
				v1.setVar("fastVel", _v1Speed);
			}
			if (!v2.existsVar("fastVel") ) {
				var _v2Stat  = v2.getStat();
				var _v2Speed = _v2Stat.get(STAT_VELOCIDAD);
				
				v2.setVar("fastVel", _v2Speed);
			}
			
			var _v1Speed = v1.getVar("fastVel");
			var _v2Speed = v2.getVar("fastVel");
			
			return (_v1Speed.control - _v2Speed.control);
		};
		
		array_sort(_grp.enemys , _fun);
		array_sort(_grp.players, _fun);
		array_sort(_grp.every  , _fun);
		// Indicar en que turno actual
		array_foreach(_grp.every, function(v, i) {
			v.turnAct = i;
		});
		*/
		
		// Cambiar cuarto
		instance_create_layer(0, 0, LYR_CONTROLLERS, fxFadeIO, {
			cm: _comn,
			eventMiddle: function() {
				// Construir fsm del oCoManager
				fsm.build().start(1);
				
				// Marcar como listo
				cm.ready = true;
				room_goto(rCombatDefault);
			}
		});
	});

	wate_create_template("GHOSTS.TUTORIAL01", function(_vars) {
		// Crear manager
		var _wate    = new WateManager("df");
		var _manager = instance_create_layer(0, 0, LYR_CONTROLLERS, oCoManager, { 
			wate: _wate,
		});
		
		#region Jugador en el mundo
		with (oPlayer) {
			// Evitar que se siga moviendo y ejecutando algun codigo de colision
			ready = false;
			
			// Detener movimiento y image-speed
			sprite_index = spQuieto;
			image_speed  = 0;
			image_index  = dir;
		}
		
		#endregion
		
		#region Crear grupos
		var _enem1 = party_create("PARTY.FLOATING_HEAD", undefined, 50);
		_wate.add("enemies", _enem1);
		
		// Añadir jugadores
		var _party = party_group_get_entities(PARTY_GP_PRINCIPAL);
		var i=0; repeat(array_length(_party) ) {
			var _char = _party[i];
			_wate.add("players", _char);
			i++;
		}
		
		_wate.create("playersDefeated");
		_wate.create("enemiesDefeated");
		
		#endregion
		
		// Aumentar ruido
		var _noiseBackTween = noise_ease(0, 0.65).tweenBack;

		// Reproducir sonido de inicio de combate
		cueca_play(AUD_SOUND, snCombateInicio01, 250, 0.2, 0.5);
		
		// Crear cambio de cuarto
		instance_create_layer(0,0,LYR_CONTROLLERS,  fxFadeIOPre, {
			iTime: 0.35, oDelay: 0.6,
			color: c_red,
			combatManager : _manager,
			tweenBackNoise: _noiseBackTween,
			eventMiddle: function() {
				// Cambiar cuarto
				room_goto(rCombatDefault);
				// 1 frame despues
				call_later(1, time_source_units_frames, function() {
					with (oPlayer) instance_destroy();
					// Reproducir musica de batalla
					cueca_play_loop(AUD_MUSIC, ".", msCombate01, 100, 1, 1);
					
					// Construir fsm del oCoManager
					with (combatManager) {
						// Sortear entidades
						sortEntitys();

						// Obtener posiciones
						getPositions();
		
						// Crear instancias
						makeInstances();
					}
					
					// Quitar ruido
					TweenPlay(tweenBackNoise);
				});
			},
		});
	
		// Tutorial de combate
		cinChp01_cyh01_03()
		
		// Funcion al completar
		_wate.fnComplete = function() {
			// Eliminar al caster de esta batalla
			with (ncTer12x18) {
				if (name == "BatleCaller::Tutorial01") {
					instance_destroy();
				}
			}
			
			// Terminar combate iniciar vuelta
			cinChp01_cyh01_04();
		};
	});
	
	wate_create_template("GHOSTS.CITY.01", function(_name) {
		var _wate    = new WateManager("df");
		var _manager = instance_create_layer(0,0,LYR_CONTROLLERS, oCoManager, {wate: _wate});

		// Reproducir sonido de inicio de combate
		cueca_play(AUD_SOUND, snCombateInicio01, 250, 0.0, 0.35);
		
		// Grupos extras
		_wate.create("playersDefeated");
		_wate.create("enemiesDefeated");
		
		
		_wate.fnComplete = method({name: _name}, function() {
			var _name = name;
			with (ncTer12x18) {
				if (name == _name) {
					instance_destroy();
				}
			}
		});
		
		// Congelar al jugador
		instance_freeze(oPlayer);
		
		// Congelar otros enemigos
		instance_freeze(ncTer12x16);
		
		// Crear enemigos y agregarlos
		var _enemy = party_create("PARTY.FLOATING_HEAD", undefined, irandom_range(48, 50) );
		_enemy.addDrop(POCKET_ITEM_ECTOLITA, [1, 4], 80);
		
		_wate.add("enemies", _enemy);
		
		if (percent_chance(50) ) {
			var _enemy = party_create("PARTY.FLOATING_HEAD", undefined, 55);
			_wate.add("enemies", _enemy);
		}
		
		// Agregar aliados
		_wate.create("players");
		var _party = party_group_get_entities(PARTY_GP_PRINCIPAL);
		var i=0; repeat(array_length(_party) ) {
			var _char = _party[i];
			_wate.add("players", _char);
			i++;
		}
	
		// Aumentar ruido
		var _noiseBackTween = noise_ease(0, 0.65).tweenBack;

		// Crear cambio de cuarto
		instance_create_layer(0,0,LYR_CONTROLLERS,  fxFadeIOPre, {
			iTime: 0.35, oDelay: 0.6,
			color: c_red,
			combatManager : _manager,
			tweenBackNoise: _noiseBackTween,
			eventMiddle: function() {
				// Cambiar cuarto
				room_goto(rCombatDefault);
				// 1 frame despues
				call_later(1, time_source_units_frames, function() {
					with (oPlayer) instance_destroy();
					// Reproducir musica de batalla
					cueca_play_loop(AUD_MUSIC, ".", msCombate01);
					
					// Construir fsm del oCoManager
					with (combatManager) {
						// Sortear entidades
						sortEntitys();

						// Obtener posiciones
						getPositions();
		
						// Crear instancias
						makeInstances();
						
						// Iniciar combate
						fsm.build().start(1);
						TweenPlay(twnStart);
						ready = true;
					}
					
					// Quitar ruido
					TweenPlay(tweenBackNoise);
				});
			},
		});
		
		
	});
}






















