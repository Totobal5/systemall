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
	var suite_party = new TestSuite("Pruebas de Entidades");
	_runner.addTestSuite(suite_party);

	// --- Configuración de la Suite de Entidades ---
	suite_party.setUp(function() {
	    // Arrange: Crear un set de datos completo para probar una entidad
	    var master = {
	        "Stats":	["./test_p_stats.json"],
	        "Items":	["./test_p_items.json"],
	        "Slots":	["./test_p_slots.json"],
	        "Commands":	["./test_p_commands.json"],
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
    
	    mall_system_cleanup();

		/// @context entity
		/// @param stat_instance
	    Systemall.__functions[$ "EVT_EnStart"] = function(_stat) 
		{
			var _key = _stat.template.key;
			show_debug_message($"El stat {_key} debería existir: {struct_exists(args, _key)}");
		};
		
	    Systemall.__functions[$ "EVT_GenericStatUp"] = function(_stat) 
		{ 
			return _stat.base_value + (level * 2); 
		};

	    Systemall.__functions[$ "EVT_SLOT_OnEquip_Test"] = function(_slot, _item) {
	        if (!global.__test_vars.wait)
			{
				global.__test_vars.slot = true;
				global.__test_vars.test.assertEqual(_item.key, "ITEM_ESPADA_BASICA");
			}
	    };
		
	    Systemall.__functions[$ "EVT_ITEM_OnEquip_Test"] = function(_entity, _slot) {
	        if (!global.__test_vars.wait)
			{
				global.__test_vars.item = true;
		        global.__test_vars.test.assertEqual(key, "ITEM_ESPADA_BASICA");
			}
	    };
		
	    Systemall.__functions[$ "EVT_STAT_OnEquip_Test"] = function(_stat, _slot) {
	        if (!global.__test_vars.wait)
			{
		        global.__test_vars.stat = true;
		        global.__test_vars.test.assertEqual(_slot.template.key, "SLOT_ARMA");
			}
	    };
		
	    mall_init("test_master_party.json");
	});

	suite_party.onRunBegin(function() {
	    // Crear una instancia fresca del héroe para cada prueba
	    self.hero = party_entity_create_instance("HERO_TEST", 1, { "EN": 0, "FUERZA": 0 } );
		global.__test_vars = {
			wait: true,
	        slot: false,
	        item: false,
	        stat: false
	    };
	});

	suite_party.tearDown(function() {
	    // Limpiar archivos
	    if (file_exists("test_master_party.json") ) file_delete("test_master_party.json");
	    if (file_exists("test_p_stats.json") ) file_delete("test_p_stats.json");
	    if (file_exists("test_p_items.json") ) file_delete("test_p_items.json");
	    if (file_exists("test_p_slots.json") ) file_delete("test_p_slots.json");
	    if (file_exists("test_p_commands.json") ) file_delete("test_p_commands.json");
	    if (file_exists("test_p_entities.json") ) file_delete("test_p_entities.json");
	});

	// --- Casos de Prueba ---
	var test_party_stat_calc = new TestCase("Test Cálculo de Estadísticas", function() {
	    // Assert
	    assertEqual(parent.hero.StatGet("FUERZA").base_value, 10, "El valor base de Fuerza debe ser 10.");
	    assertEqual(parent.hero.StatGet("FUERZA").peak_value, 12, "El valor peak de Fuerza a nivel 1 debe ser 12.");
	});
	suite_party.addTestCase(test_party_stat_calc);

	var test_party_equip = new TestCase("Test Equipar y Recalcular Stats", function() {
	    // Act
	    parent.hero.SlotEquip("SLOT_ARMA", "ITEM_ESPADA_BASICA");
		
	    // Assert
	    assertEqual(parent.hero.StatGet("FUERZA").equipment_value, 22, "La Fuerza con equipo debe ser 22 (12 de base + 10 de la espada).");
	});
	suite_party.addTestCase(test_party_equip);

	var test_party_learnset = new TestCase("Test Aprendizaje de Habilidades por Nivel", function() {
	    // Assert (Pre-LevelUp)
	    assertFalse(parent.hero.CommandExists("MAGIC", "CMD_BOLA_FUEGO"), "No debería tener Bola de Fuego a nivel 1.");
    
	    // Act
	    parent.hero.LevelUp(4); // Subir a nivel 5
    
	    // Assert (Post-LevelUp)
	    assertTrue(parent.hero.CommandExists("MAGIC", "CMD_BOLA_FUEGO"), "Debería haber aprendido Bola de Fuego a nivel 5.");
	});
	suite_party.addTestCase(test_party_learnset);
	
	var test_party_equip_events = new TestCase("Test Eventos de Equipamiento (Slot, Item, Stat)", function() {
	    // Arrange
		var _test = self;
		global.__test_vars = {
			test: _test,
			wait: false,
	        slot: false,
	        item: false,
	        stat: false
	    };
		
	    // Act
	    parent.hero.SlotEquip("SLOT_ARMA", "ITEM_ESPADA_BASICA");
    
	    // Assert
	    assertTrue(global.__test_vars.slot, "El evento on_equip del slot debería haberse disparado.");
	    assertTrue(global.__test_vars.item, "El evento on_equip del item debería haberse disparado.");
	    assertTrue(global.__test_vars.stat, "El evento on_equip de la estadística debería haberse disparado.");
	});
	suite_party.addTestCase(test_party_equip_events);	

	var test_party_add_effect = new TestCase("Test Aplicación de Efectos y Estados", function() {
	    // Assert (Pre-Efecto)
	    assertFalse(parent.hero.StateIsActive("STATE_FUERZA_AUMENTADA"), "El estado no debería estar activo al inicio.");
    
	    // Act
	    parent.hero.EffectAdd("EFFECT_BUFF_FUERZA");
    
	    // Assert (Post-Efecto)
	    assertTrue(parent.hero.StateIsActive("STATE_FUERZA_AUMENTADA"), "El estado debería activarse al añadir un efecto.");
	});
	suite_party.addTestCase(test_party_add_effect);

	var test_party_state_stat_recalc = new TestCase("Test Recalcular Stats con Estados Activos", function() {
	    // Arrange
	    var fuerza_inicial = parent.hero.StatGet("FUERZA").control_value;
    
	    // Act
	    parent.hero.EffectAdd("EFFECT_BUFF_FUERZA");
    
	    // Assert
	    var fuerza_final = parent.hero.StatGet("FUERZA").control_value;
	    assertEqual(fuerza_final, fuerza_inicial + 5, "La Fuerza debería aumentar en 5 debido al estado.");
	});
	suite_party.addTestCase(test_party_state_stat_recalc);

	var test_party_remove_effect = new TestCase("Test Eliminación de Efectos y Estados", function() {
	    // Arrange
	    var efecto_inst = parent.hero.EffectAdd("EFFECT_BUFF_FUERZA");
    
	    // Act
	    parent.hero.EffectRemove(efecto_inst);
    
	    // Assert
	    assertFalse(parent.hero.StateIsActive("STATE_FUERZA_AUMENTADA"), "El estado debería desactivarse al eliminar su último efecto.");
	    assertEqual(parent.hero.StatGet("FUERZA").control_value, 12, "La Fuerza debería volver a su valor original sin el estado.");
	});
	suite_party.addTestCase(test_party_remove_effect);
}



