function __mall_test_core(_runner)
{
	var suite_core = new TestSuite("Pruebas de Componentes Base");
	_runner.addTestSuite(suite_core);

	// --- Caso de Prueba 1.1: MallIterator ---
	var test_iterator = new TestCase("Test MallIterator Ticks", function() {
	    // Arrange: Crear un iterador que dure 3 ticks y no se repita.
	    var iter = new MallIterator();
	    iter.Configure(3, 0);

	    // Act & Assert
	    assertEqual(iter.Tick(), MALL_ITERATOR_STATE.WORKING, "El primer tick debe estar en estado WORKING.");
	    assertEqual(iter.Tick(), MALL_ITERATOR_STATE.WORKING, "El segundo tick debe estar en estado WORKING.");
	    assertEqual(iter.Tick(), MALL_ITERATOR_STATE.COMPLETED, "El tercer tick debe estar en estado COMPLETED.");
	    assertFalse(iter.IsActive(), "El iterador debe estar inactivo después de completarse.");
	});
	suite_core.addTestCase(test_iterator);

	// --- Caso de Prueba 1.2: MallResult ---
	var test_result = new TestCase("Test MallResult Totals", function() {
	    // Arrange: Crear un resultado y añadir datos.
	    var result = new MallResult();
	    result.Push(false, 0, 50, 0, 0); // Daño de 50
	    result.Push(true, 0, 120, 0, 0); // Daño de 120, objetivo derrotado

	    // Act
	    var total_damage = result.GetTotalDamage();
	    var any_defeated = result.WasAnyDefeated();

	    // Assert
	    assertEqual(total_damage, 170, "El daño total debe ser 170.");
	    assertTrue(any_defeated, "Se debe detectar que al menos un objetivo fue derrotado.");
	});
	suite_core.addTestCase(test_result);
}

function __mall_test_load(_runner)
{
	var suite_loading = new TestSuite("Pruebas del Sistema de Carga");
	_runner.addTestSuite(suite_loading);

	// --- Configuración de la Suite de Carga ---
	suite_loading.setUp(function() {
	    // Arrange: Crear archivos JSON temporales para las pruebas.
    
	    var master_content = json_stringify({ "Components": ["./test_stats.json"] });
	    var file = file_text_open_write("test_master.json");
	    file_text_write_string(file, master_content);
	    file_text_close(file);
    
	    var stats_content = json_stringify({ "type": "Stats", "EN": { "max_value": 9999 }, "FUERZA": { "max_value": 255 } });
	    file = file_text_open_write("test_stats.json");
	    file_text_write_string(file, stats_content);
	    file_text_close(file);
    
	    var malformed_content = "{ \"type\": \"Stats\", \"EN\":, }";
	    file = file_text_open_write("test_stats_malformed.json");
	    file_text_write_string(file, malformed_content);
	    file_text_close(file);
    
		// Limpiar systemall
	    mall_system_cleanup();
	});

	suite_loading.tearDown(function() {
	    if (file_exists("test_master.json")) file_delete("test_master.json");
	    if (file_exists("test_stats.json")) file_delete("test_stats.json");
	    if (file_exists("test_stats_malformed.json")) file_delete("test_stats_malformed.json");
	});

	// --- Caso de Prueba 2.1: Carga Exitosa ---
	var test_load_success = new TestCase("Test Carga Exitosa de JSON", function() {
	    mall_init("test_master.json");
	    assertTrue(mall_exists_stat("EN"), "La estadística 'EN' debería existir después de la carga.");
	    assertTrue(mall_exists_stat("FUERZA"), "La estadística 'FUERZA' debería existir después de la carga.");
	    assertEqual(array_length(mall_get_stat_keys()), 2, "Deberían haberse cargado 2 estadísticas.");
	});
	suite_loading.addTestCase(test_load_success);

	// --- Caso de Prueba 2.2: Falla con JSON Malformado ---
	var test_load_fail = new TestCase("Test Falla con JSON Malformado", function() {
	    var master_content = json_stringify({ "Components": ["./test_stats_malformed.json"] });
	    var file = file_text_open_write("test_master_malformed.json");
	    file_text_write_string(file, master_content);
	    file_text_close(file);
    
	    assertRaises(function() {
	        mall_init("test_master_malformed.json");
	    }, "Se esperaba un error al intentar parsear un JSON con sintaxis incorrecta.");
    
	    file_delete("test_master_malformed.json");
	});
	suite_loading.addTestCase(test_load_fail);
	
}

function __mall_test_pocket_bag_simple(_runner)
{
	var suite_pocket = new TestSuite("Pruebas del Sistema de Inventario");
	_runner.addTestSuite(suite_pocket);

	// --- Configuración de la Suite de Inventario ---
	suite_pocket.setUp(function() {
	    var master_content = json_stringify({ "Items": ["./test_items.json"] });
	    var file = file_text_open_write("test_master_pocket.json");
	    file_text_write_string(file, master_content);
	    file_text_close(file);
    
	    var items_content = json_stringify({
	        "type": "Items",
	        "ITEM_POCION": { "item_type": "CONSUMABLE", "is_stackable": true, "stack_limit": 99 },
	        "ITEM_ESPADA_HIERRO": { "item_type": "WEAPON", "is_stackable": false }
	    });
	    file = file_text_open_write("test_items.json");
	    file_text_write_string(file, items_content);
	    file_text_close(file);
    
		// Limpiar systemall
	    mall_system_cleanup();
	
	    mall_init("test_master_pocket.json");
	});

	suite_pocket.onRunBegin(function() {
	    self.bag = new PocketBagSimple("test_bag");
	});

	suite_pocket.tearDown(function() {
	    if (file_exists("test_master_pocket.json")) file_delete("test_master_pocket.json");
	    if (file_exists("test_items.json")) file_delete("test_items.json");
	});

	// --- Caso de Prueba 3.1: Añadir y Contar Items ---
	var test_pocket_add = new TestCase("Test Añadir y Contar Items", function() {
	    parent.bag.AddItem("ITEM_POCION", 15);
	    assertEqual(parent.bag.GetItemCount("ITEM_POCION"), 15, "La mochila debe tener 15 pociones.");
	    assertEqual(array_length(parent.bag.GetOrderedItems()), 1, "Debe haber 1 slot de item en la mochila.");
	});
	suite_pocket.addTestCase(test_pocket_add);

	// --- Caso de Prueba 3.2: Apilamiento de Items ---
	var test_pocket_stack = new TestCase("Test Apilamiento de Items", function() {
	    parent.bag.AddItem("ITEM_POCION", 90);
	    var result = parent.bag.AddItem("ITEM_POCION", 20);
    
	    // Assert del estado final
	    assertEqual(parent.bag.GetItemCount("ITEM_POCION"), 110, "La cantidad total de pociones debe ser 110.");
	    assertEqual(array_length(parent.bag.GetOrderedItems()), 2, "Debe haber 2 stacks de pociones.");
	    assertEqual(parent.bag.GetOrderedItems()[0].count, 99, "El primer stack debe tener 99 pociones.");
	    assertEqual(parent.bag.GetOrderedItems()[1].count, 11, "El segundo stack debe tener 11 pociones.");
    
	    // Assert del resultado de la operación
	    assertEqual(result.added, 20, "Se debieron añadir 20 pociones en total.");
	    assertEqual(result.leftover, 0, "No debieron sobrar pociones.");
	});
	suite_pocket.addTestCase(test_pocket_stack);

	// --- Caso de Prueba 3.3: Items No Apilables ---
	var test_pocket_no_stack = new TestCase("Test Items No Apilables", function() {
	    parent.bag.AddItem("ITEM_ESPADA_HIERRO", 1);
	    var result = parent.bag.AddItem("ITEM_ESPADA_HIERRO", 1); // Intentar añadir una segunda espada
    
	    assertEqual(parent.bag.GetItemCount("ITEM_ESPADA_HIERRO"), 1, "La cantidad total de espadas debe seguir siendo 1.");
	    assertEqual(array_length(parent.bag.GetOrderedItems()), 1, "Solo debe haber 1 slot de item ocupado.");
	    assertEqual(result.added, 0, "No se debió añadir ninguna espada nueva.");
	    assertEqual(result.leftover, 1, "Debió sobrar 1 espada.");
	});
	suite_pocket.addTestCase(test_pocket_no_stack);

	// --- Caso de Prueba 3.4: Añadir Múltiples Items No Apilables ---
	var test_pocket_add_multiple_non_stackable = new TestCase("Test Añadir Múltiples Items No Apilables", function() {
	    // Act
	    var result = parent.bag.AddItem("ITEM_ESPADA_HIERRO", 5);
    
	    // Assert
	    assertEqual(result.added, 1, "Solo se debe añadir 1 objeto no apilable.");
	    assertEqual(result.leftover, 4, "Deben sobrar 4 objetos no apilables.");
	    assertEqual(parent.bag.GetItemCount("ITEM_ESPADA_HIERRO"), 1, "La cantidad total de espadas debe ser 1.");
	    assertEqual(array_length(parent.bag.GetOrderedItems()), 1, "Solo debe haber 1 slot de item ocupado.");
	});
	suite_pocket.addTestCase(test_pocket_add_multiple_non_stackable);

	// --- Caso de Prueba 3.5: Items No Apilables con Vars Distintas ---
	var test_pocket_non_stackable_with_vars = new TestCase("Test Items No Apilables con Vars Distintas", function() {
	    // Act
	    parent.bag.AddItem("ITEM_ESPADA_HIERRO", 1);
	    var result = parent.bag.AddItem("ITEM_ESPADA_HIERRO", 1, { enchantment: "fire" });
    
	    // Assert
	    assertEqual(parent.bag.GetItemCount("ITEM_ESPADA_HIERRO"), 2, "La cantidad total de espadas debe ser 2.");
	    assertEqual(array_length(parent.bag.GetOrderedItems()), 2, "Deben existir 2 slots, uno para cada espada.");
	    assertEqual(result.added, 1, "Se debió añadir la nueva espada con vars.");
	    assertEqual(result.leftover, 0, "No debió sobrar ninguna espada.");
	});
	suite_pocket.addTestCase(test_pocket_non_stackable_with_vars);

	// --- Caso de Prueba 3.6: Eliminar Items ---
	var test_pocket_remove = new TestCase("Test Eliminar Items", function() {
	    static _array_empty = function(_array) { return (array_length(_array) == 0); };

	    parent.bag.AddItem("ITEM_POCION", 50);
	    parent.bag.RemoveItem("ITEM_POCION", 20);
	    assertEqual(parent.bag.GetItemCount("ITEM_POCION"), 30, "Deben quedar 30 pociones.");
    
	    parent.bag.RemoveItem("ITEM_POCION", 35);
	    assertEqual(parent.bag.GetItemCount("ITEM_POCION"), 0, "No deben quedar pociones.");
	    assertTrue(_array_empty(parent.bag.GetOrderedItems()), "El inventario debe estar vacío.");
	});
	suite_pocket.addTestCase(test_pocket_remove);	
	
}

function __mall_test_pocket_bag_complex(_runner)
{
	var suite_pocket_complex = new TestSuite("Pruebas de Mochila Compleja");
	_runner.addTestSuite(suite_pocket_complex);

	// --- Configuración de la Suite ---
	suite_pocket_complex.setUp(function() {
	    var master_content = json_stringify({ 
	        "Items": ["./test_items_complex.json"],
	        "Bags": ["./test_bags_complex.json"]
	    });
	    var file = file_text_open_write("test_master_complex.json");
		file_text_write_string(file, master_content);
		file_text_close(file);
    
	    var items_content = json_stringify({
	        "type": "Items",
	        "ITEM_POCION": { "item_type": "CONSUMABLE", "is_stackable": true, "stack_limit": 20 },
	        "ITEM_ESPADA_HIERRO": { "item_type": "WEAPON", "is_stackable": false },
	        "ITEM_LLAVE_MAESTRA": { "item_type": "KEY_ITEM", "is_stackable": false }
	    });
	    file = file_text_open_write("test_items_complex.json");
		file_text_write_string(file, items_content);
		file_text_close(file);
    
	    var bags_content = json_stringify({
	        "type": "Bags",
	        "BAG_CATEGORIZED": {
	            "bag_type": "complex",
	            "category_defaults": { "slot_limit": 10 },
	            "category_overrides": {
	                "KEY_ITEM": { "slot_limit": 2 }
	            }
	        }
	    });
	    file = file_text_open_write("test_bags_complex.json");
		file_text_write_string(file, bags_content);
		file_text_close(file);
    
	    mall_system_cleanup();
	    mall_init("test_master_complex.json");
	});

	suite_pocket_complex.onRunBegin(function() {
	    self.bag = pocket_bag_get("BAG_CATEGORIZED");
	});

	suite_pocket_complex.tearDown(function() {
	    if (file_exists("test_master_complex.json")) file_delete("test_master_complex.json");
	    if (file_exists("test_items_complex.json")) file_delete("test_items_complex.json");
	    if (file_exists("test_bags_complex.json")) file_delete("test_bags_complex.json");
	});

	// --- Casos de Prueba ---
	var test_complex_add = new TestCase("Test Bag Compleja por Categoría", function() {
	    // Act
	    parent.bag.AddItem("ITEM_POCION", 5);
	    parent.bag.AddItem("ITEM_ESPADA_HIERRO", 1);
    
	    // Assert
	    assertEqual(parent.bag.GetItemCount("ITEM_POCION"), 5);
	    assertEqual(parent.bag.GetItemCount("ITEM_ESPADA_HIERRO"), 1);
	    assertEqual(array_length(parent.bag.GetItemsByCategory("CONSUMABLE")), 1, "Debe haber 1 item en la categoría CONSUMABLE.");
	    assertEqual(array_length(parent.bag.GetItemsByCategory("WEAPON")), 1, "Debe haber 1 item en la categoría WEAPON.");
	});
	suite_pocket_complex.addTestCase(test_complex_add);

	var test_complex_limits = new TestCase("Test Límites de Categoría en Bag Compleja", function() {
	    // Act
	    parent.bag.AddItem("ITEM_LLAVE_MAESTRA", 1);
	    parent.bag.AddItem("ITEM_LLAVE_MAESTRA", 1, { id: 2 }); // Otra llave con vars distintas
	    var result = parent.bag.AddItem("ITEM_LLAVE_MAESTRA", 1, { id: 3 }); // Intentar añadir una tercera
    
	    // Assert
	    assertEqual(parent.bag.GetItemCount("ITEM_LLAVE_MAESTRA"), 2, "Solo deben caber 2 llaves maestras.");
	    assertEqual(array_length(parent.bag.GetItemsByCategory("KEY_ITEM")), 2, "La categoría KEY_ITEM debe estar llena.");
	    assertEqual(result.added, 0, "No se debió añadir la tercera llave.");
	    assertEqual(result.leftover, 1, "Debió sobrar 1 llave.");
	});
	suite_pocket_complex.addTestCase(test_complex_limits);
}

function __mall_test_pocket_bag_events(_runner)
{
	var suite_pocket_events = new TestSuite("Pruebas de Eventos de Inventario");
	_runner.addTestSuite(suite_pocket_events);
	
	// --- Configuración de la Suite de Eventos de Inventario ---
	suite_pocket_events.setUp(function() {
	    // Arrange: Crear archivos JSON temporales para items y una mochila con eventos.
	    var master_content = json_stringify({ 
	        "Items": ["./test_items_events.json"],
	        "Bags": ["./test_bags_events.json"]
	    });
	    var file = file_text_open_write("test_master_events.json");
	    file_text_write_string(file, master_content);
	    file_text_close(file);
    
	    var items_content = json_stringify({
	        "type": "Items",
	        "ITEM_POCION": { "item_type": "CONSUMABLE", "is_stackable": true, "stack_limit": 99 }
	    });
	    file = file_text_open_write("test_items_events.json");
	    file_text_write_string(file, items_content);
	    file_text_close(file);
    
	    var bags_content = json_stringify({
	        "type": "Bags",
	        "BAG_WITH_EVENTS": {
	            "bag_type": "simple",
	            "event_on_add_item": "EVT_BAG_OnItemAdded_Test",
	            "event_on_remove_item": "EVT_BAG_OnItemRemoved_Test"
	        }
	    });
	    file = file_text_open_write("test_bags_events.json");
	    file_text_write_string(file, bags_content);
	    file_text_close(file);
    
	    // Inicializar Systemall y definir las funciones de evento simuladas
	    mall_system_cleanup();
    
	    // Estas funciones se añadirán a la base de datos de funciones de Systemall
	    Systemall.__functions[$ "EVT_BAG_OnItemAdded_Test"] = function(_item_key, _count, _args) {
	        /// @context BAG_WITH_EVENTS
			_args.test.assertEqual(_args.bag, self, "El contexto actual debería ser el mismo que la bag que ejecuta el evento");
			event_fired = true;
		
	        _args.test.assertEqual(_item_key, "ITEM_POCION", "El argumento de llave debería ser ITEM_POCION");
	        _args.test.assertEqual(_count, 10, "El argumento de cantidad debería ser 10");	
	    };
	
	    Systemall.__functions[$ "EVT_BAG_OnItemRemoved_Test"] = function(_item_key, _removed, _args) {
			/// @context BAG_WITH_EVENTS
			_args.test.assertEqual(_args.bag, self, "El contexto actual debería ser el mismo que la bag que ejecuta el evento");
			event_fired = true;
		
			_args.test.assertEqual(_item_key, "ITEM_POCION", "El argumento de llave debería ser ITEM_POCION");
			_args.test.assertEqual(_removed, 5, "El argumento de eliminados debería ser 5");
	    };
    
	    mall_init("test_master_events.json");
	});
	
	suite_pocket_events.tearDown(function() {
	    // Limpiar archivos
	    if (file_exists("test_master_events.json")) file_delete("test_master_events.json");
	    if (file_exists("test_items_events.json")) file_delete("test_items_events.json");
	    if (file_exists("test_bags_events.json")) file_delete("test_bags_events.json");
	});
	
	// --- Caso de Prueba 4.1: Evento al Añadir Objeto ---
	var test_event_add = new TestCase("Test Evento al Añadir Objeto", function() {
	    // Arrange
	    var bag = pocket_bag_get("BAG_WITH_EVENTS");
	    // Añadimos una variable al TestCase
		var _this = self; with (bag) 
		{
			event_fired = false; 
			var _me = self;
			args = { test: _this, bag: _me };
		}

	    // Act
	    bag.AddItem("ITEM_POCION", 10);
    
	    // Assert
	    assertTrue(bag.event_fired, "El evento event_on_add_item debería haberse disparado.");
	});
	suite_pocket_events.addTestCase(test_event_add);

	// --- Caso de Prueba 4.2: Evento al Eliminar Objeto ---
	var test_event_remove = new TestCase("Test Evento al Eliminar Objeto", function() {
	    // Arrange
	    var bag = pocket_bag_get("BAG_WITH_EVENTS");
	    // Añadimos una variable al TestCase
		var _this = self; with (bag) 
		{
			event_fired = false; 
			var _me = self;
			args = { test: _this, bag: _me };
		}
    
	    // Act
	    bag.RemoveItem("ITEM_POCION", 5);
    
	    // Assert
	    assertTrue(bag.event_fired, "El evento event_on_remove_item debería haberse disparado.");
	});
	suite_pocket_events.addTestCase(test_event_remove);	
	
}

function __mall_test_party_entity(_runner)
{
	var suite_party = new TestSuite("Pruebas de Entidades y Eventos");
	_runner.addTestSuite(suite_party);

	// --- Configuración de la Suite de Entidades ---
	suite_party.setUp(function() {
		// Limpiar
		mall_system_cleanup();
		
	    // Arrange: Crear un set de datos completo para probar una entidad
	    var master = {
	        "Stats":	["./test_p_stats.json"],
	        "Items":	["./test_p_items.json"],
	        "Slots":	["./test_p_slots.json"],
	        "States":	["./test_p_states.json"],
	        "Effects":	["./test_p_effects.json"],
	        "Commands": ["./test_p_commands.json"],
	        "Party":	["./test_p_entities.json"]
	    };
		
	    var file = file_text_open_write("test_master_party.json");
		file_text_write_string(file, json_stringify(master));
		file_text_close(file);
    
	    var stats = { 
			"type": "Stats", 
			"EN": {
				"max_value": 9999,
				"event_on_start": "EVT_EnStart",
				"event_on_level_up": "EVT_GenericStatUp"
			}, 
			"FUERZA": {
				"max_value": 255, 
				"event_on_level_up": "EVT_GenericStatUp",
				"event_on_equip": "EVT_STAT_OnEquip_Test"
			}
		};
		
	    file = file_text_open_write("test_p_stats.json");
		file_text_write_string(file, json_stringify(stats));
		file_text_close(file);
    
	    var items = { 
			"type": "Items", 
			"ITEM_ESPADA_BASICA": { 
				"item_type": "WEAPON", 
				"stats": {
					"FUERZA+": 10 
				},
				"event_on_equip": "EVT_ITEM_OnEquip_Test",
				"event_on_desequip": "EVT_ITEM_OnDesequip_Test"
			}
		};
		
	    file = file_text_open_write("test_p_items.json");
		file_text_write_string(file, json_stringify(items));
		file_text_close(file);
    
	    var slots = { 
			"type": "Slots", 
			"SLOT_ARMA": { 
				"permited": ["WEAPON"],
				"event_on_equip": "EVT_SLOT_OnEquip_Test"
			} 
		};
		
	    file = file_text_open_write("test_p_slots.json");
		file_text_write_string(file, json_stringify(slots));
		file_text_close(file);

	    var states = { 
			"type": "States", 
			"STATE_TEST_BUFF": { 
				"event_on_add_effect": "EVT_STATE_OnAddEffect_Test", 
				"event_can_add_effect": "EVT_STATE_CanAddEffect_Test" 
			},
			"STATE_FUERZA_AUMENTADA": { 
				"stats": { "FUERZA+": 5 } 
			}
		};
		
	    file = file_text_open_write("test_p_states.json");
		file_text_write_string(file, json_stringify(states));
		file_text_close(file);

	    var effects = { 
			"type": "Effects", 
			"EFFECT_TEST_BUFF": { "state_key": "STATE_TEST_BUFF" },
			"EFFECT_BUFF_FUERZA": { "state_key": "STATE_FUERZA_AUMENTADA" }
		};
		
	    file = file_text_open_write("test_p_effects.json");
		file_text_write_string(file, json_stringify(effects));
		file_text_close(file);
	
	    var commands = { "type": "Commands", "CMD_BOLA_FUEGO": {} };
	    file = file_text_open_write("test_p_commands.json");
		file_text_write_string(file, json_stringify(commands));
		file_text_close(file);
    
	    var entities = {
	        "type": "Party",
	        "HERO_TEST": {
	            "stats": { "FUERZA": 10 },
	            "learnset": [ { "level": 5, "command": "CMD_BOLA_FUEGO", "category": "MAGIC" } ]
	        }
	    };
		
	    file = file_text_open_write("test_p_entities.json");
		file_text_write_string(file, json_stringify(entities));
		file_text_close(file);
		
	    Systemall.__functions[$ "EVT_GenericStatUp"] = function(_stat) 
		{ 
			return _stat.base_value + level * 2;
		};
		
		Systemall.__functions[$ "EVT_SLOT_OnEquip_Test"] = function() 
		{ 
			global.crispy_test_flags.slot = true;
		};
		
	    Systemall.__functions[$ "EVT_ITEM_OnEquip_Test"] = function() 
		{ 
			global.crispy_test_flags.item = true;
		};
		
	    Systemall.__functions[$ "EVT_STAT_OnEquip_Test"] = function() 
		{ 
			global.crispy_test_flags.stat = true;
		};		
		
		Systemall.__functions[$ "EVT_STATE_OnAddEffect_Test"] = function(_state, _effect)
		{
			global.crispy_test_flags.effect = true;
			global.crispy_test_flags.test.assertEqual(_effect.template.key, "EFFECT_TEST_BUFF");
		};
		
		Systemall.__functions[$ "EVT_STATE_CanAddEffect_Test"] = function() 
		{ 
			return true;
		};
		
		Systemall.__functions[$ "EVT_STATE_CanAddEffect_Test"] = function() 
		{ 
			return global.crispy_test_flags.can_add; 
		};
		
		
	    mall_init("test_master_party.json");
	});

	suite_party.onRunBegin(function() {
	    // Usar una variable global para rastrear los eventos
	    global.crispy_test_flags = {
			wait: true,
	        slot: false,
	        item: false,
	        stat: false,
			effect: false,
			can_add: true,
			test: undefined,
	    };
	});

	suite_party.tearDown(function() {
	    // Limpiar archivos y la variable global
	    if (file_exists("test_master_party.json")) file_delete("test_master_party.json");
	    if (file_exists("test_p_stats.json")) file_delete("test_p_stats.json");
	    if (file_exists("test_p_items.json")) file_delete("test_p_items.json");
	    if (file_exists("test_p_slots.json")) file_delete("test_p_slots.json");
	    if (file_exists("test_p_states.json")) file_delete("test_p_states.json");
	    if (file_exists("test_p_effects.json")) file_delete("test_p_effects.json");
	    if (file_exists("test_p_commands.json")) file_delete("test_p_commands.json");
	    if (file_exists("test_p_entities.json")) file_delete("test_p_entities.json");
		global.crispy_test_flags = undefined;
	});

	// --- Casos de Prueba ---
	var test_party_stat_calc = new TestCase("Test Cálculo de Estadísticas", function() {
		global.crispy_test_flags.test = self;
		var hero = party_entity_create_instance("HERO_TEST", 1);
	    assertEqual(hero.StatGet("FUERZA").base_value, 10, "El valor base de Fuerza debe ser 10.");
	    assertEqual(hero.StatGet("FUERZA").peak_value, 12, "El valor peak de Fuerza a nivel 1 debe ser 12.");
	});
	suite_party.addTestCase(test_party_stat_calc);

	var test_party_equip = new TestCase("Test Equipar y Recalcular Stats", function() {
		global.crispy_test_flags.test = self;
		var hero = party_entity_create_instance("HERO_TEST", 1);
	    hero.SlotEquip("SLOT_ARMA", "ITEM_ESPADA_BASICA");
	    assertEqual(hero.StatGet("FUERZA").equipment_value, 22, "La Fuerza con equipo debe ser 22 (12 de base + 10 de la espada).");
	});
	suite_party.addTestCase(test_party_equip);

	var test_party_learnset = new TestCase("Test Aprendizaje de Habilidades por Nivel", function() {
		global.crispy_test_flags.test = self;
		var hero = party_entity_create_instance("HERO_TEST", 1);
	    assertFalse(hero.CommandExists("MAGIC", "CMD_BOLA_FUEGO"), "No debería tener Bola de Fuego a nivel 1.");
	    hero.LevelUp(4); // Subir a nivel 5
	    assertTrue(hero.CommandExists("MAGIC", "CMD_BOLA_FUEGO"), "Debería haber aprendido Bola de Fuego a nivel 5.");
	});
	suite_party.addTestCase(test_party_learnset);
	
	var test_party_equip_events = new TestCase("Test Eventos de Equipamiento (Slot, Item, Stat)", function() {
		global.crispy_test_flags.test = self;
	    // Arrange
		var hero = party_entity_create_instance("HERO_TEST", 1);
		hero.event_on_equip = function() { global.crispy_test_flags.entity = true; };
		
	    // Act
	    hero.SlotEquip("SLOT_ARMA", "ITEM_ESPADA_BASICA");
		
	    // Assert
	    assertTrue(global.crispy_test_flags.entity, "El evento on_equip de la entidad debe dispararse.");
	    assertTrue(global.crispy_test_flags.slot, "El evento on_equip del slot debería haberse disparado.");
	    assertTrue(global.crispy_test_flags.item, "El evento on_equip del item debería haberse disparado.");
	    assertTrue(global.crispy_test_flags.stat, "El evento on_equip de la estadística debería haberse disparado.");
	});
	suite_party.addTestCase(test_party_equip_events);

	var test_party_state_events = new TestCase("Test Eventos de Notificación de Estados", function() {
		global.crispy_test_flags.test = self;
		
		var hero = party_entity_create_instance("HERO_TEST", 1);
	    hero.EffectAdd("EFFECT_TEST_BUFF");
		
	    assertTrue(global.crispy_test_flags.effect, "El evento on_add_effect del estado debería haberse disparado.");
	    assertTrue(hero.StateIsActive("STATE_TEST_BUFF"), "El estado debería estar activo.");
	});
	suite_party.addTestCase(test_party_state_events);

	var test_party_state_validation = new TestCase("Test Eventos de Validación de Estados", function() {
		global.crispy_test_flags.test = self;
		var hero = party_entity_create_instance("HERO_TEST", 1);
		
	    // Act & Assert (Bloqueado)
		global.crispy_test_flags.can_add = false;
	    var result1 = hero.EffectAdd("EFFECT_TEST_BUFF");
	    assertFalse(result1.success, "La adición del efecto debería haber fallado.");
	    assertFalse(hero.StateIsActive("STATE_TEST_BUFF"), "El estado no debería estar activo si la validación falla.");
		
	    // Act & Assert (Permitido)
	    global.crispy_test_flags.can_add = true;
	    var result2 = hero.EffectAdd("EFFECT_TEST_BUFF");
	    assertTrue(result2.success, "La adición del efecto debería haber sido exitosa.");
	    assertTrue(hero.StateIsActive("STATE_TEST_BUFF"), "El estado debería estar activo si la validación es exitosa.");
	});
	suite_party.addTestCase(test_party_state_validation);

	var test_party_add_effect = new TestCase("Test Aplicación de Efectos y Estados", function() {
		global.crispy_test_flags.test = self;
		var hero = party_entity_create_instance("HERO_TEST", 1);
	    assertFalse(hero.StateIsActive("STATE_FUERZA_AUMENTADA"), "El estado no debería estar activo al inicio.");
	    hero.EffectAdd("EFFECT_BUFF_FUERZA");
	    assertTrue(hero.StateIsActive("STATE_FUERZA_AUMENTADA"), "El estado debería activarse al añadir un efecto.");
	});
	suite_party.addTestCase(test_party_add_effect);

	var test_party_state_stat_recalc = new TestCase("Test Recalcular Stats con Estados Activos", function() {
		global.crispy_test_flags.test = self;
		var hero = party_entity_create_instance("HERO_TEST", 1);
	    var fuerza_inicial = hero.StatGet("FUERZA").control_value;
	    hero.EffectAdd("EFFECT_BUFF_FUERZA");
	    var fuerza_final = hero.StatGet("FUERZA").control_value;
	    assertEqual(fuerza_final, fuerza_inicial + 5, "La Fuerza debería aumentar en 5 debido al estado.");
	});
	suite_party.addTestCase(test_party_state_stat_recalc);

	var test_party_remove_effect = new TestCase("Test Eliminación de Efectos y Estados", function() {
		global.crispy_test_flags.test = self;
		
		var hero = party_entity_create_instance("HERO_TEST", 1);
	    var efecto_inst = hero.EffectAdd("EFFECT_BUFF_FUERZA").added;
		hero.EffectRemove(efecto_inst.template.key, function(_value, _index) { 
			return template.key == _value.template.key;
		});
		
		
	    assertFalse(hero.StateIsActive("STATE_FUERZA_AUMENTADA"), "El estado debería desactivarse al eliminar su último efecto.");
	    assertEqual(hero.StatGet("FUERZA").control_value, 12, "La Fuerza debería volver a su valor original sin el estado.");
	});
	suite_party.addTestCase(test_party_remove_effect);
}

function __mall_test_party_entity_events(_runner)
{
	var suite_party_events = new TestSuite("Pruebas de Eventos de Entidad");
	_runner.addTestSuite(suite_party_events);

	// --- Configuración de la Suite ---
	suite_party_events.setUp(function() {
		// Limpiar Systemall
		mall_system_cleanup();
		
	    // Arrange: Crear un set de datos completo para probar los eventos
	    var master = {
	        "Stats": ["./test_e_stats.json"],
	        "Items": ["./test_e_items.json"],
	        "Slots": ["./test_e_slots.json"],
	        "States": ["./test_e_states.json"],
	        "Party": ["./test_e_entities.json"]
	    };
	    var file = file_text_open_write("test_master_events.json");
		file_text_write_string(file, json_stringify(master));
		file_text_close(file);
    
	    var stats = { "type": "Stats", 
			"STAT_TEST": {
				"max_value": 9999,
				"event_on_equip": "EVT_StatOnEquip",
				"event_on_turn_start": "EVT_StatOnTurnStart",
				"event_on_level_up": "EVT_GenericStatUp"
			}	
	    };
	    file = file_text_open_write("test_e_stats.json");
		file_text_write_string(file, json_stringify(stats));
		file_text_close(file);
    
	    var items = { 
			"type": "Items", 
			"ITEM_TEST": { 
				"item_type": "WEAPON", 
				"event_on_equip": "EVT_ItemOnEquip", 
				"event_on_turn_start": "EVT_ItemOnTurnStart" 
			} 
		};
	    file = file_text_open_write("test_e_items.json");
		file_text_write_string(file, json_stringify(items));
		file_text_close(file);
    
	    var slots = { "type": "Slots", "SLOT_TEST": { "permited": ["WEAPON"], "event_on_equip": "EVT_SlotOnEquip", "event_on_turn_start": "EVT_SlotOnTurnStart" } };
	    file = file_text_open_write("test_e_slots.json");
		file_text_write_string(file, json_stringify(slots));
		file_text_close(file);
    
	    var states = { "type": "States", "STATE_TEST": { "event_on_equip": "EVT_StateOnEquip", "event_on_turn_start": "EVT_StateOnTurnStart" } };
	    file = file_text_open_write("test_e_states.json");
		file_text_write_string(file, json_stringify(states));
		file_text_close(file);
    
	    var entities = { 
			"type": "Party", 
	        "HERO_TEST": {
	            "stats": { "STAT_TEST": 10 },
	            "learnset": [ { "level": 5, "command": "CMD_BOLA_FUEGO", "category": "MAGIC" } ]
	        }			
		};
	    file = file_text_open_write("test_e_entities.json");
		file_text_write_string(file, json_stringify(entities));
		file_text_close(file);
    
	    Systemall.__functions[$ "EVT_GenericStatUp"] = function(_stat) 
		{ 
			return _stat.base_value + (level * 2); 
		};
		
	    Systemall.__functions[$ "EVT_StatOnTurnStart"] = function() 
		{
			global.crispy_test_flags.stat = true; 
		};
	    
		Systemall.__functions[$ "EVT_SlotOnTurnStart"] = function() 
		{ 
			global.crispy_test_flags.slot = true; 
		};
		
	    Systemall.__functions[$ "EVT_StateOnTurnStart"] = function() 
		{ 
			global.crispy_test_flags.state = true; 
		};
		
	    Systemall.__functions[$ "EVT_ItemOnTurnStart"] = function() 
		{ 
			global.crispy_test_flags.item = true; 
		};
		
	    Systemall.__functions[$ "EVT_StatOnEquip"] = function() 
		{
			global.crispy_test_flags.stat = true; 
		};
		
	    Systemall.__functions[$ "EVT_SlotOnEquip"] = function() 
		{ 
			global.crispy_test_flags.slot = true; 
		};
	    
		Systemall.__functions[$ "EVT_StateOnEquip"] = function() 
		{
			global.crispy_test_flags.state = true; 
		};
	    
		Systemall.__functions[$ "EVT_ItemOnEquip"] = function() 
		{ 
			global.crispy_test_flags.item = true;
		};
		
	    mall_init("test_master_events.json");		
	});

	suite_party_events.onRunBegin(function() {
	    // Crear una instancia fresca del héroe para cada prueba
	    self.hero = party_entity_create_instance("HERO_TEST", 1);
    
	    // Usar una variable global para rastrear los eventos, ya que el contexto de 'parent' no está disponible en los callbacks
	    global.crispy_test_flags = {
	        entity: false,
	        stat: false,
	        slot: false,
	        state: false,
	        item: false
	    };
	});

	suite_party_events.tearDown(function() {
	    // Limpiar archivos
	    if (file_exists("test_master_events.json")) file_delete("test_master_events.json");
	    if (file_exists("test_e_stats.json")) file_delete("test_e_stats.json");
	    if (file_exists("test_e_items.json")) file_delete("test_e_items.json");
	    if (file_exists("test_e_slots.json")) file_delete("test_e_slots.json");
	    if (file_exists("test_e_states.json")) file_delete("test_e_states.json");
	    if (file_exists("test_e_entities.json")) file_delete("test_e_entities.json");
    
	    // Limpiar la variable global
	    global.crispy_test_flags = undefined;
	});

	// --- Casos de Prueba ---

	var test_equip_dispatch = new TestCase("Test Despacho de Eventos al Equipar", function() {
	    // Arrange: Sobrescribir las funciones de evento para que modifiquen el tracker global
	    parent.hero.event_on_equip = function() { global.crispy_test_flags.entity = true; };
    
	    // Act
	    parent.hero.SlotEquip("SLOT_TEST", "ITEM_TEST");
    
	    // Assert
	    assertTrue(global.crispy_test_flags.entity, "El evento on_equip de la entidad debe dispararse.");
	    assertTrue(global.crispy_test_flags.stat, "El evento on_equip de la estadística debe dispararse.");
	    assertTrue(global.crispy_test_flags.slot, "El evento on_equip del slot debe dispararse.");
	    assertTrue(global.crispy_test_flags.state, "El evento on_equip del estado debe dispararse.");
	    assertTrue(global.crispy_test_flags.item, "El evento on_equip del objeto debe dispararse.");
	});
	suite_party_events.addTestCase(test_equip_dispatch);

	var test_turn_start_dispatch = new TestCase("Test Despacho de Eventos al Iniciar Turno", function() {
	    // Arrange
	    parent.hero.SlotEquip("SLOT_TEST", "ITEM_TEST"); // Equipar el item para que su evento de turno se active

	    // Act
	    parent.hero.OnTurnStart();
    
	    // Assert
	    assertTrue(global.crispy_test_flags.stat, "El evento on_turn_start de la estadística debe dispararse.");
	    assertTrue(global.crispy_test_flags.slot, "El evento on_turn_start del slot debe dispararse.");
	    assertTrue(global.crispy_test_flags.state, "El evento on_turn_start del estado debe dispararse.");
	    assertTrue(global.crispy_test_flags.item, "El evento on_turn_start del objeto equipado debe dispararse.");
	});
	suite_party_events.addTestCase(test_turn_start_dispatch);	
}

function __mall_test_ai(_runner)
{
	var suite_ai = new TestSuite("Pruebas del Sistema de IA");
	_runner.addTestSuite(suite_ai);

	// --- Configuración de la Suite de IA ---
	suite_ai.setUp(function() {
		// Limpiar
		mall_system_cleanup();
		
	    // Arrange: Crear un set de datos completo para probar la IA
	    var master = {
	        "Stats": ["./test_ai_stats.json"],
	        "Commands": ["./test_ai_commands.json"],
	        "Party": ["./test_ai_entities.json"],
	        "AI": ["./test_ai_packages.json"]
	    };
	    var file = file_text_open_write("test_master_ai.json");
		file_text_write_string(file, json_stringify(master));
		file_text_close(file);
    
	    var stats = { 
			"type": "Stats", 
			"EN": {
			
			} 
		};
	    file = file_text_open_write("test_ai_stats.json");
		file_text_write_string(file, json_stringify(stats));
		file_text_close(file);
    
	    var commands = { "type": "Commands", "CMD_ATAQUE": {}, "CMD_CURAR": {} };
	    file = file_text_open_write("test_ai_commands.json");
		file_text_write_string(file, json_stringify(commands));
		file_text_close(file);
    
	    var entities = { 
			"type": "Party", 
			"ENEMY_TEST": {
				"ai_package": "AI_SIMPLE",
				"stats": { "EN": 10 }
			},
			
			"ALLY_TEST": {
			
			} 
		};
	    file = file_text_open_write("test_ai_entities.json");
		file_text_write_string(file, json_stringify(entities));
		file_text_close(file);
    
	    var ai_data = {
	        "type": "AI",
	        "rules": {
	            "RULE_ATTACK": { "priority": 0, "condition": "AI_COND_Always_True", "action": "AI_ACTION_Attack", "target": "AI_TARGET_Self" },
	            "RULE_HEAL": { "priority": 100, "condition": "AI_COND_HP_Below_50", "action": "AI_ACTION_Heal", "target": "AI_TARGET_Self" }
	        },
	        "packages": {
	            "AI_SIMPLE": { "rules": ["RULE_ATTACK"] },
	            "AI_HEALER": { "rules": ["RULE_HEAL", "RULE_ATTACK"] },
	            "AI_BOSS": { "rules": ["AI_HEALER"] } // Hereda de AI_HEALER
	        }
	    };
	    file = file_text_open_write("test_ai_packages.json");
		file_text_write_string(file, json_stringify(ai_data));
		file_text_close(file);
		
	    // Definir funciones de IA
	    Systemall.__functions[$ "AI_COND_Always_True"] = function(caster, context) { return true; };
	    Systemall.__functions[$ "AI_COND_HP_Below_50"] = function(caster, context) {
	        return (caster.StatGet("EN").current_value / caster.StatGet("EN").control_value) < 0.5;
	    };
	    Systemall.__functions[$ "AI_ACTION_Attack"] = function(caster, targets) { return "CMD_ATAQUE"; };
	    Systemall.__functions[$ "AI_ACTION_Heal"] = function(caster, targets) { return "CMD_CURAR"; };
	    Systemall.__functions[$ "AI_TARGET_Self"] = function(caster, context) { return [caster]; };
    
	    mall_init("test_master_ai.json");
	});

	suite_ai.onRunBegin(function() {
	    // Crear instancias para las pruebas
	    self.caster = party_entity_create_instance("ENEMY_TEST", 1);
	    self.ally = party_entity_create_instance("ALLY_TEST", 1);
	    self.context = { player_group: new PartyGroup("players"), enemy_group: new PartyGroup("enemies") };
	    self.context.enemy_group.Add(self.caster);
	    self.context.player_group.Add(self.ally);
	});

	suite_ai.tearDown(function() {
	    // Limpiar archivos
	    if (file_exists("test_master_ai.json")) file_delete("test_master_ai.json");
	    if (file_exists("test_ai_stats.json")) file_delete("test_ai_stats.json");
	    if (file_exists("test_ai_commands.json")) file_delete("test_ai_commands.json");
	    if (file_exists("test_ai_entities.json")) file_delete("test_ai_entities.json");
	    if (file_exists("test_ai_packages.json")) file_delete("test_ai_packages.json");
	});

	// --- Casos de Prueba ---

	var test_ai_simple_action = new TestCase("Test Selección de Acción Simple", function() {
	    // Arrange
	    parent.caster.ai_instance = new EntityAIInstance(parent.caster, "AI_SIMPLE");
    
	    // Act
	    var action = parent.caster.SelectAction(parent.context);
    
	    // Assert
	    assertIsNotUndefined(action, "La IA debería haber seleccionado una acción.");
	    assertEqual(action.source.key, "CMD_ATAQUE", "La acción seleccionada debe ser el ataque por defecto.");
	});
	suite_ai.addTestCase(test_ai_simple_action);

	var test_ai_priority = new TestCase("Test Prioridad de Reglas", function() {
	    // Arrange
	    parent.caster.ai_instance = new EntityAIInstance(parent.caster, "AI_HEALER");
	    parent.caster.StatSet("EN", 4); // Bajar la vida para activar la condición de curación
    
	    // Act
	    var action = parent.caster.SelectAction(parent.context);
    
	    // Assert
	    assertEqual(action.source.key, "CMD_CURAR", "La IA debería priorizar la curación sobre el ataque.");
	});
	suite_ai.addTestCase(test_ai_priority);

	var test_ai_inheritance = new TestCase("Test Herencia de Paquetes de IA", function() {
	    // Arrange
	    parent.caster.ai_instance = new EntityAIInstance(parent.caster, "AI_BOSS");
	    parent.caster.StatSet("EN", 4); // Bajar la vida para activar la condición de curación heredada
    
	    // Act
	    var action = parent.caster.SelectAction(parent.context);
    
	    // Assert
	    assertEqual(action.source.key, "CMD_CURAR", "La IA del jefe debería heredar y usar la regla de curación.");
	});
	suite_ai.addTestCase(test_ai_inheritance);	
}

function __mall_test_wate(_runner)
{
	var suite_wate = new TestSuite("Pruebas del Gestor de Combate");
	_runner.addTestSuite(suite_wate);

	// --- Configuración de la Suite de Combate ---
	suite_wate.setUp(function() {
	    // Arrange: Crear un set de datos completo para un escenario de batalla
	    var master = {
	        "Stats": ["./test_w_stats.json"],
	        "Commands": ["./test_w_commands.json"],
	        "Party": ["./test_w_entities.json"],
	        "Wate": ["./test_w_encounters.json"]
	    };
	    var file = file_text_open_write("test_master_wate.json");
	    file_text_write_string(file, json_stringify(master));
	    file_text_close(file);
    
	    var stats = { "type": "Stats", "EN": {}, "VELOCIDAD": {} };
	    file = file_text_open_write("test_w_stats.json");
	    file_text_write_string(file, json_stringify(stats));
	    file_text_close(file);
    
	    var commands = { "type": "Commands", "CMD_ATAQUE": { "event_execute": "EVT_WATE_BasicDamage" } };
	    file = file_text_open_write("test_w_commands.json");
	    file_text_write_string(file, json_stringify(commands));
	    file_text_close(file);
    
	    var entities = { 
	        "type": "Party", 
	        "HERO": { "stats": { "EN": 100, "VELOCIDAD": 20 }, "commands": { "default": ["CMD_ATAQUE"] } },
	        "ENEMY": { "stats": { "EN": 50, "VELOCIDAD": 10 }, "commands": { "default": ["CMD_ATAQUE"] } }
	    };
	    file = file_text_open_write("test_w_entities.json");
	    file_text_write_string(file, json_stringify(entities));
	    file_text_close(file);
    
	    var encounters = {
	        "type": "Wate",
	        "encounters": {
	            "ENCOUNTER_TEST": {
	                "event_on_turn_order_create": "EVT_WATE_OrderBySpeed",
	                "groups": [
	                    { "positions": [ { "template_key": "ENEMY", "level": 1 } ] }
	                ]
	            }
	        }
	    };
	    file = file_text_open_write("test_w_encounters.json");
	    file_text_write_string(file, json_stringify(encounters));
	    file_text_close(file);
    
	    mall_system_cleanup();
    
	    // Funciones de evento para el combate
	    Systemall.__functions[$ "EVT_WATE_OrderBySpeed"] = function(_entities) {
	        array_sort(_entities, function(a, b) { return b.StatGet("VELOCIDAD").control_value - a.StatGet("VELOCIDAD").control_value; });
	        return _entities;
	    };
	    Systemall.__functions[$ "EVT_WATE_BasicDamage"] = function(_caster, _target, _params) {
	        _target.StatAdd("EN", -10);
	        return new MallResult().Push(_target.StatGet("EN").current_value <= 0, 0, 10, 0, 0);
	    };
    
	    mall_init("test_master_wate.json");
	});

	suite_wate.onRunBegin(function() {
	    // Crear el grupo de jugadores y las instancias para cada prueba
	    self.player_group = new PartyGroup("PLAYER_GROUP");
	    var hero_inst = party_entity_create_instance("HERO", 1);
	    self.player_group.Add(hero_inst);
	});

	suite_wate.tearDown(function() {
	    // Limpiar archivos
	    if (file_exists("test_master_wate.json")) file_delete("test_master_wate.json");
	    if (file_exists("test_w_stats.json")) file_delete("test_w_stats.json");
	    if (file_exists("test_w_commands.json")) file_delete("test_w_commands.json");
	    if (file_exists("test_w_entities.json")) file_delete("test_w_entities.json");
	    if (file_exists("test_w_encounters.json")) file_delete("test_w_encounters.json");
	});

	// --- Casos de Prueba ---

	var test_wate_start = new TestCase("Test Inicio de Batalla y Creación de Instancias", function() {
	    // Act
	    wate_start_battle("ENCOUNTER_TEST", parent.player_group);
    
	    // Assert
	    var manager = wate_get_manager();
	    assertIsNotUndefined(manager, "El WateManager debería haber sido creado.");
	    assertEqual(array_length(manager.enemy_groups), 1, "Debe haber 1 grupo de enemigos.");
	    assertEqual(manager.enemy_groups[0].Size(), 1, "El grupo de enemigos debe contener 1 entidad.");
	    assertEqual(manager.enemy_groups[0].Get(0).template_key, "ENEMY", "La entidad creada debe ser del template correcto.");
	});
	suite_wate.addTestCase(test_wate_start);

	var test_wate_turn_order = new TestCase("Test Orden de Turno por Velocidad", function() {
	    // Act
	    wate_start_battle("ENCOUNTER_TEST", parent.player_group);
	    var manager = wate_get_manager();
	    var turn_queue = manager.turn_queue;
    
	    // Assert
	    assertEqual(array_length(turn_queue), 2, "La cola de turnos debe tener 2 entidades.");
	    assertEqual(turn_queue[0].template_key, "HERO", "El héroe (más rápido) debería actuar primero.");
	    assertEqual(turn_queue[1].template_key, "ENEMY", "El enemigo (más lento) debería actuar segundo.");
	});
	suite_wate.addTestCase(test_wate_turn_order);

	var test_wate_action_damage = new TestCase("Test Ejecución de Acción y Daño", function() {
	    // Arrange
	    wate_start_battle("ENCOUNTER_TEST", parent.player_group);
	    var manager = wate_get_manager();
	    var hero = manager.turn_queue[0];
	    var enemy = manager.turn_queue[1];
	    var enemy_hp_before = enemy.StatGet("EN").current_value;
    
	    var attack_command = hero.CommandGet("default", "CMD_ATAQUE");
	    var action = new WateAction(hero, attack_command, [enemy]);
    
	    // Act
	    manager.ExecuteAction(action);
    
	    // Assert
	    var enemy_hp_after = enemy.StatGet("EN").current_value;
	    assertEqual(enemy_hp_after, enemy_hp_before - 10, "El HP del enemigo debería haber disminuido en 10.");
	});
	suite_wate.addTestCase(test_wate_action_damage);

	var test_wate_victory_condition = new TestCase("Test Condición de Victoria", function() {
	    // Arrange
	    wate_start_battle("ENCOUNTER_TEST", parent.player_group);
	    var manager = wate_get_manager();
	    var hero = manager.turn_queue[0];
	    var enemy = manager.turn_queue[1];
	    enemy.StatSet("EN", 5); // Dejar al enemigo con 5 HP
    
	    var attack_command = hero.CommandGet("default", "CMD_ATAQUE");
	    var action = new WateAction(hero, attack_command, [enemy]);
    
	    // Act
	    manager.ExecuteAction(action);
    
	    // Assert
	    assertIsUndefined(wate_get_manager(), "La batalla debería haber terminado y el gestor debería ser undefined.");
	});
	suite_wate.addTestCase(test_wate_victory_condition);	
}

function __mall_test_broadcast(runner)
{
	var suite_broadcast = new TestSuite("Pruebas de Broadcast y Mensajes");
	runner.addTestSuite(suite_broadcast);
	
	// --- Configuración de la Suite ---
	suite_broadcast.setUp(function() {
	    // Limpiar y reiniciar Systemall antes de cada prueba
	    mall_system_cleanup();
	});

	suite_broadcast.onRunBegin(function() {
	    // Usar una variable global para rastrear los eventos
	    global.crispy_test_flags = {
	        broadcast_fired: false,
	        broadcast_data: undefined
	    };
	});

	suite_broadcast.tearDown(function() {
	    // Limpiar la variable global
	    global.crispy_test_flags = undefined;
	});

	// --- Casos de Prueba ---

	var test_broadcast_subscribe_post = new TestCase("Test Suscripción y Publicación de Broadcast", function() {
	    // Arrange: Crear una función de callback que modifique el tracker global
	    var _test_callback = function(_data) {
	        global.crispy_test_flags.broadcast_fired = true;
	        global.crispy_test_flags.broadcast_data = _data;
	    };
    
	    mall_broadcast_subscribe("TEST_EVENT", _test_callback);
    
	    // Act
	    var _event_data = { message: "hello world" };
	    mall_broadcast_post("TEST_EVENT", _event_data);
    
	    // Assert
	    assertTrue(global.crispy_test_flags.broadcast_fired, "El evento de broadcast debería haberse disparado.");
	    assertIsNotUndefined(global.crispy_test_flags.broadcast_data, "Los datos del evento no deberían ser undefined.");
	    assertEqual(global.crispy_test_flags.broadcast_data.message, "hello world", "Los datos del evento no coinciden.");
	});
	suite_broadcast.addTestCase(test_broadcast_subscribe_post);

	var test_message_queue = new TestCase("Test Cola de Mensajes (Añadir y Obtener)", function() {
	    // Arrange
	    mall_message_add("Mensaje 1");
	    mall_message_add("Mensaje 2", c_red);
    
	    // Act & Assert
	    assertFalse(mall_message_is_empty(), "La cola de mensajes no debería estar vacía.");
    
	    var msg1 = mall_message_get_next();
	    assertIsNotUndefined(msg1);
	    assertEqual(msg1.text, "Mensaje 1");
    
	    var msg2 = mall_message_get_next();
	    assertIsNotUndefined(msg2);
	    assertEqual(msg2.text, "Mensaje 2");
	    assertEqual(msg2.color, c_red);
    
	    assertTrue(mall_message_is_empty(), "La cola de mensajes debería estar vacía después de obtener todos los mensajes.");
	});
	suite_broadcast.addTestCase(test_message_queue);	
	
}