/// @ignore
function __mall_test_core(_runner)
{
	var suite_core = new CrispySuite("Core Component Tests");
	_runner.AddTestSuite(suite_core);

	// --- Test Case 1.1: MallIterator ---
	var test_iterator = new CrispyCase("Test MallIterator Ticks", function() {
		// Arrange: Create an iterator lasting 3 ticks with no repeats.
		var iter = new MallIterator();
		iter.Configure(3, 0);

		// Act & Assert
		AssertEqual(iter.Tick(), MALL_ITERATOR_STATE.WORKING, "First tick should be WORKING.");
		AssertEqual(iter.Tick(), MALL_ITERATOR_STATE.WORKING, "Second tick should be WORKING.");
		AssertEqual(iter.Tick(), MALL_ITERATOR_STATE.COMPLETED, "Third tick should be COMPLETED.");
		AssertFalse(iter.IsActive(), "Iterator should be inactive after completion.");
	});
	suite_core.AddCase(test_iterator);

	// --- Test Case 1.2: MallResult ---
	var test_result = new CrispyCase("Test MallResult Totals", function() {
		// Arrange: Create a result and add data.
		var result = new MallResult();
		result.Push(false, 0, 50, 0, 0); // 50 damage
		result.Push(true, 0, 120, 0, 0); // 120 damage, defeated target

		// Act
		var total_damage = result.GetTotalDamage();
		var any_defeated = result.WasAnyDefeated();

		// Assert
		AssertEqual(total_damage, 170, "Total damage should be 170.");
		AssertTrue(any_defeated, "At least one defeated target should be detected.");
	});
	suite_core.AddCase(test_result);
}

/// @ignore
function __mall_test_load(_runner)
{
	var suite_loading = new CrispySuite("System Load Tests");
	_runner.AddTestSuite(suite_loading);

	// --- Load Suite Setup ---
	suite_loading.SetUp(function() {
		// Arrange: Create temporary JSON files for tests.
	
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
	
		// Clear Systemall state.
		mall_system_cleanup();
	});

	suite_loading.TearDown(function() {
		if (file_exists("test_master.json")) file_delete("test_master.json");
		if (file_exists("test_stats.json")) file_delete("test_stats.json");
		if (file_exists("test_stats_malformed.json")) file_delete("test_stats_malformed.json");
	});

	// --- Test Case 2.1: Successful JSON Load ---
	var test_load_success = new CrispyCase("Test Successful JSON Load", function() {
		mall_init("test_master.json");
		AssertTrue(mall_exists_stat("EN"), "Stat 'EN' should exist after load.");
		AssertTrue(mall_exists_stat("FUERZA"), "Stat 'FUERZA' should exist after load.");
		AssertEqual(array_length(mall_get_stat_keys()), 2, "Exactly 2 stats should be loaded.");
	});
	suite_loading.AddCase(test_load_success);

	// --- Test Case 2.2: Malformed JSON Failure ---
	var test_load_fail = new CrispyCase("Test Malformed JSON Failure", function() {
		var master_content = json_stringify({ "Components": ["./test_stats_malformed.json"] });
		var file = file_text_open_write("test_master_malformed.json");
		file_text_write_string(file, master_content);
		file_text_close(file);
	
		AssertRaises(function() {
			mall_init("test_master_malformed.json");
		}, "Expected an error when parsing malformed JSON.");
	
		file_delete("test_master_malformed.json");
	});
	suite_loading.AddCase(test_load_fail);
	
}

/// @ignore
function __mall_test_pocket_bag_simple(_runner)
{
	var suite_pocket = new CrispySuite("Inventory System Tests");
	_runner.AddTestSuite(suite_pocket);

	// --- Inventory Suite Setup ---
	suite_pocket.SetUp(function() {
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
	
		// Clear Systemall state.
		mall_system_cleanup();
	
		mall_init("test_master_pocket.json");
		// Recreate a fresh bag for each case to avoid stale references after cleanup.
		CrispyTest.vars.bag = new MallBagSimple("test_bag");
	});

	suite_pocket.OnRunBegin(function() {
		CrispyTest.vars.bag = new MallBagSimple("test_bag");
	});

	suite_pocket.TearDown(function() {
		if (file_exists("test_master_pocket.json")) file_delete("test_master_pocket.json");
		if (file_exists("test_items.json")) file_delete("test_items.json");
	});

	// --- Test Case 3.1: Add and Count Items ---
	var test_pocket_add = new CrispyCase("Test Add and Count Items", function() {
		CrispyTest.vars.bag.AddItem("ITEM_POCION", 15);
		AssertEqual(CrispyTest.vars.bag.GetItemCount("ITEM_POCION"), 15, "Bag should contain 15 potions.");
		AssertEqual(array_length(CrispyTest.vars.bag.GetOrderedItems()), 1, "Bag should have 1 occupied item slot.");
	});
	suite_pocket.AddCase(test_pocket_add);

	// --- Test Case 3.2: Item Stacking ---
	var test_pocket_stack = new CrispyCase("Test Item Stacking", function() {
		CrispyTest.vars.bag.AddItem("ITEM_POCION", 90);
		var result = CrispyTest.vars.bag.AddItem("ITEM_POCION", 20);
	
		// Assert final state.
		AssertEqual(CrispyTest.vars.bag.GetItemCount("ITEM_POCION"), 110, "Total potion count should be 110.");
		AssertEqual(array_length(CrispyTest.vars.bag.GetOrderedItems()), 2, "There should be 2 potion stacks.");
		AssertEqual(CrispyTest.vars.bag.GetOrderedItems()[0].count, 99, "First stack should contain 99 potions.");
		AssertEqual(CrispyTest.vars.bag.GetOrderedItems()[1].count, 11, "Second stack should contain 11 potions.");
	
		// Assert operation result.
		AssertEqual(result.added, 20, "Exactly 20 potions should be added.");
		AssertEqual(result.leftover, 0, "No potions should remain as leftover.");
	});
	suite_pocket.AddCase(test_pocket_stack);

	// --- Caso de Prueba 3.3: Items No Apilables ---
	var test_pocket_no_stack = new CrispyCase("Test Items No Apilables", function() {
		CrispyTest.vars.bag.AddItem("ITEM_ESPADA_HIERRO", 1);
		var result = CrispyTest.vars.bag.AddItem("ITEM_ESPADA_HIERRO", 1); // Intentar añadir una segunda espada
	
		AssertEqual(CrispyTest.vars.bag.GetItemCount("ITEM_ESPADA_HIERRO"), 1, "La cantidad total de espadas debe seguir siendo 1.");
		AssertEqual(array_length(CrispyTest.vars.bag.GetOrderedItems()), 1, "Solo debe haber 1 slot de item ocupado.");
		AssertEqual(result.added, 0, "No se debió añadir ninguna espada nueva.");
		AssertEqual(result.leftover, 1, "Debió sobrar 1 espada.");
	});
	suite_pocket.AddCase(test_pocket_no_stack);

	// --- Caso de Prueba 3.4: Añadir Múltiples Items No Apilables ---
	var test_pocket_add_multiple_non_stackable = new CrispyCase("Test Añadir Múltiples Items No Apilables", function() {
		// Act
		var result = CrispyTest.vars.bag.AddItem("ITEM_ESPADA_HIERRO", 5);
	
		// Assert
		AssertEqual(result.added, 1, "Solo se debe añadir 1 item no apilable.");
		AssertEqual(result.leftover, 4, "Deben sobrar 4 items no apilables.");
		AssertEqual(CrispyTest.vars.bag.GetItemCount("ITEM_ESPADA_HIERRO"), 1, "La cantidad total de espadas debe ser 1.");
		AssertEqual(array_length(CrispyTest.vars.bag.GetOrderedItems()), 1, "Solo debe haber 1 slot de item ocupado.");
	});
	suite_pocket.AddCase(test_pocket_add_multiple_non_stackable);

	// --- Caso de Prueba 3.5: Items No Apilables con Vars Distintas ---
	var test_pocket_non_stackable_with_vars = new CrispyCase("Test Items No Apilables con Vars Distintas", function() {
		// Act
		CrispyTest.vars.bag.AddItem("ITEM_ESPADA_HIERRO", 1);
		var result = CrispyTest.vars.bag.AddItem("ITEM_ESPADA_HIERRO", 1, { enchantment: "fire" });
	
		// Assert
		AssertEqual(CrispyTest.vars.bag.GetItemCount("ITEM_ESPADA_HIERRO"), 2, "La cantidad total de espadas debe ser 2.");
		AssertEqual(array_length(CrispyTest.vars.bag.GetOrderedItems()), 2, "Deben existir 2 slots, uno para cada espada.");
		AssertEqual(result.added, 1, "Se debió añadir la nueva espada con vars.");
		AssertEqual(result.leftover, 0, "No debió sobrar ninguna espada.");
	});
	suite_pocket.AddCase(test_pocket_non_stackable_with_vars);

	// --- Test Case 3.6: Remove Items ---
	var test_pocket_remove = new CrispyCase("Test Remove Items", function() {
		static _array_empty = function(_array) { return (array_length(_array) == 0); };

		CrispyTest.vars.bag.AddItem("ITEM_POCION", 50);
		CrispyTest.vars.bag.RemoveItem("ITEM_POCION", 20);
		AssertEqual(CrispyTest.vars.bag.GetItemCount("ITEM_POCION"), 30, "30 potions should remain.");
	
		CrispyTest.vars.bag.RemoveItem("ITEM_POCION", 35);
		AssertEqual(CrispyTest.vars.bag.GetItemCount("ITEM_POCION"), 0, "No potions should remain.");
		AssertTrue(_array_empty(CrispyTest.vars.bag.GetOrderedItems()), "Inventory should be empty.");
	});
	suite_pocket.AddCase(test_pocket_remove);	
	
}

/// @ignore
function __mall_test_pocket_bag_complex(_runner)
{
	var suite_pocket_complex = new CrispySuite("Pruebas de Mochila Compleja");
	_runner.AddTestSuite(suite_pocket_complex);

	// --- Configuresción de la Suite ---
	suite_pocket_complex.SetUp(function() {
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
		// Re-resolve bag instance per case after each init cycle.
		CrispyTest.vars.bag = mall_get_bag("BAG_CATEGORIZED");
	});

	suite_pocket_complex.OnRunBegin(function() {
		CrispyTest.vars.bag = mall_get_bag("BAG_CATEGORIZED");
	});

	suite_pocket_complex.TearDown(function() {
		if (file_exists("test_master_complex.json")) file_delete("test_master_complex.json");
		if (file_exists("test_items_complex.json")) file_delete("test_items_complex.json");
		if (file_exists("test_bags_complex.json")) file_delete("test_bags_complex.json");
	});

	// --- Casos de Prueba ---
	var test_complex_add = new CrispyCase("Test Bag Compleja por Categoría", function() {
		// Act
		CrispyTest.vars.bag.AddItem("ITEM_POCION", 5);
		CrispyTest.vars.bag.AddItem("ITEM_ESPADA_HIERRO", 1);
	
		// Assert
		AssertEqual(CrispyTest.vars.bag.GetItemCount("ITEM_POCION"), 5);
		AssertEqual(CrispyTest.vars.bag.GetItemCount("ITEM_ESPADA_HIERRO"), 1);
		AssertEqual(array_length(CrispyTest.vars.bag.GetItemsByCategory("CONSUMABLE")), 1, "Debe haber 1 item en la categoría CONSUMABLE.");
		AssertEqual(array_length(CrispyTest.vars.bag.GetItemsByCategory("WEAPON")), 1, "Debe haber 1 item en la categoría WEAPON.");
	});
	suite_pocket_complex.AddCase(test_complex_add);

	var test_complex_limits = new CrispyCase("Test Límites de Categoría en Bag Compleja", function() {
		// Act
		CrispyTest.vars.bag.AddItem("ITEM_LLAVE_MAESTRA", 1);
		CrispyTest.vars.bag.AddItem("ITEM_LLAVE_MAESTRA", 1, { id: 2 }); // Otra key con vars distintas
		var result = CrispyTest.vars.bag.AddItem("ITEM_LLAVE_MAESTRA", 1, { id: 3 }); // Intentar añadir una tercera
	
		// Assert
		AssertEqual(CrispyTest.vars.bag.GetItemCount("ITEM_LLAVE_MAESTRA"), 2, "Solo deben caber 2 keys maestras.");
		AssertEqual(array_length(CrispyTest.vars.bag.GetItemsByCategory("KEY_ITEM")), 2, "La categoría KEY_ITEM debe estar llena.");
		AssertEqual(result.added, 0, "No se debió añadir la tercera key.");
		AssertEqual(result.leftover, 1, "Debió sobrar 1 key.");
	});
	suite_pocket_complex.AddCase(test_complex_limits);
}

/// @ignore
function __mall_test_pocket_bag_events(_runner)
{
	var suite_pocket_events = new CrispySuite("Pruebas de Eventos de Inventario");
	_runner.AddTestSuite(suite_pocket_events);
	
	// --- Configuresción de la Suite de Eventos de Inventario ---
	suite_pocket_events.SetUp(function() {
		// Arrange: Createsr files JSON temporales para items y una bag con eventos.
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
	
		// Initializesr Systemall y definir las functiones de evento simuladas
		mall_system_cleanup();
	
		// Estas functiones se añadirán a la base de data de functiones de Systemall
		__Systemall.__events[$ "EVT_BAG_OnItemAdded_Test"] = function(_item_key, _count, _args) {
			/// @context BAG_WITH_EVENTS
			_args.test.AssertEqual(_args.bag, self, "El context actual debería ser el mismo que la bag que ejecuta el evento");
			event_fired = true;
		
			_args.test.AssertEqual(_item_key, "ITEM_POCION", "El argumento de key debería ser ITEM_POCION");
			_args.test.AssertEqual(_count, 10, "El argumento de cantidad debería ser 10");	
		};
	
		__Systemall.__events[$ "EVT_BAG_OnItemRemoved_Test"] = function(_item_key, _removed, _args) {
			/// @context BAG_WITH_EVENTS
			_args.test.AssertEqual(_args.bag, self, "El context actual debería ser el mismo que la bag que ejecuta el evento");
			event_fired = true;
		
			_args.test.AssertEqual(_item_key, "ITEM_POCION", "El argumento de key debería ser ITEM_POCION");
			_args.test.AssertEqual(_removed, 5, "El argumento de eliminados debería ser 5");
		};
	
		mall_init("test_master_events.json");
	});
	
	suite_pocket_events.TearDown(function() {
		// Clearsr files
		if (file_exists("test_master_events.json")) file_delete("test_master_events.json");
		if (file_exists("test_items_events.json")) file_delete("test_items_events.json");
		if (file_exists("test_bags_events.json")) file_delete("test_bags_events.json");
	});
	
	// --- Caso de Prueba 4.1: Evento al Añadir Item ---
	var test_event_add = new CrispyCase("Test Evento al Añadir Item", function() {
		// Arrange
		var bag = mall_get_bag("BAG_WITH_EVENTS");
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
		AssertTrue(bag.event_fired, "El evento event_on_add_item debería haberse disparado.");
	});
	suite_pocket_events.AddCase(test_event_add);

	// --- Caso de Prueba 4.2: Evento al Removesr Item ---
	var test_event_remove = new CrispyCase("Test Evento al Removesr Item", function() {
		// Arrange
		var bag = mall_get_bag("BAG_WITH_EVENTS");
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
		AssertTrue(bag.event_fired, "El evento event_on_remove_item debería haberse disparado.");
	});
	suite_pocket_events.AddCase(test_event_remove);	
	
}

/// @ignore
function __mall_test_party_entity(_runner)
{
	var suite_party = new CrispySuite("Pruebas de Entityes y Eventos");
	_runner.AddTestSuite(suite_party);

	// --- Configuresción de la Suite de Entityes ---
	suite_party.SetUp(function() {
		// Clearsr
		mall_system_cleanup();
		
		// Arrange: Createsr un set de data completo para probar una entity
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
				"permitted": ["WEAPON"],
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
			"type": "ENTITIES",
			"HERO_TEST": {
				"stats": { "FUERZA": 10 },
				"learnset": [ { "level": 5, "command": "CMD_BOLA_FUEGO", "category": "MAGIC" } ]
			}
		};
		
		file = file_text_open_write("test_p_entities.json");
		file_text_write_string(file, json_stringify(entities));
		file_text_close(file);
		
		__Systemall.__events[$ "EVT_GenericStatUp"] = function(_stat) 
		{ 
			return _stat.base_value + level * 2;
		};
		
		__Systemall.__events[$ "EVT_SLOT_OnEquip_Test"] = function() 
		{ 
			global.crispy_test_flags.slot = true;
		};
		
		__Systemall.__events[$ "EVT_ITEM_OnEquip_Test"] = function() 
		{ 
			global.crispy_test_flags.item = true;
		};
		
		__Systemall.__events[$ "EVT_STAT_OnEquip_Test"] = function() 
		{ 
			global.crispy_test_flags.stat = true;
		};		
		
		__Systemall.__events[$ "EVT_STATE_OnAddEffect_Test"] = function(_state, _effect)
		{
			global.crispy_test_flags.effect = true;
			global.crispy_test_flags.test.AssertEqual(_effect.template.key, "EFFECT_TEST_BUFF");
		};
		
		__Systemall.__events[$ "EVT_STATE_CanAddEffect_Test"] = function() 
		{ 
			return true;
		};
		
		__Systemall.__events[$ "EVT_STATE_CanAddEffect_Test"] = function() 
		{ 
			return global.crispy_test_flags.can_add; 
		};
		
		
		mall_init("test_master_party.json");
		// Reset event tracker per case to avoid cross-test contamination.
		global.crispy_test_flags = {
			wait: true,
			entity: false,
			slot: false,
			item: false,
			stat: false,
			effect: false,
			can_add: true,
			test: undefined,
		};
	});

	suite_party.OnRunBegin(function() {
		// Usar una variable global para rastrear los eventos
		global.crispy_test_flags = {
			wait: true,
			entity: false,
			slot: false,
			item: false,
			stat: false,
			effect: false,
			can_add: true,
			test: undefined,
		};
	});

	suite_party.TearDown(function() {
		// Clearsr files y la variable global
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
	var test_party_stat_calc = new CrispyCase("Test Cálculo de Stats", function() {
		global.crispy_test_flags.test = self;
		var hero = mall_entity_create_instance("HERO_TEST", 1);
		AssertEqual(hero.StatGet("FUERZA").base_value, 10, "El value base de Fuerza debe ser 10.");
		AssertEqual(hero.StatGet("FUERZA").peak_value, 12, "El value peak de Fuerza a nivel 1 debe ser 12.");
	});
	suite_party.AddCase(test_party_stat_calc);

	var test_party_equip = new CrispyCase("Test Equipar y Recalcular Stats", function() {
		global.crispy_test_flags.test = self;
		var hero = mall_entity_create_instance("HERO_TEST", 1);
		hero.SlotEquip("SLOT_ARMA", "ITEM_ESPADA_BASICA");
		AssertEqual(hero.StatGet("FUERZA").equipment_value, 22, "La Fuerza con equipo debe ser 22 (12 de base + 10 de la espada).");
	});
	suite_party.AddCase(test_party_equip);

	var test_party_learnset = new CrispyCase("Test Aprendizaje de Habilidades por Nivel", function() {
		global.crispy_test_flags.test = self;
		var hero = mall_entity_create_instance("HERO_TEST", 1);
		AssertFalse(hero.CommandExists("MAGIC", "CMD_BOLA_FUEGO"), "No debería tener Bola de Fuego a nivel 1.");
		hero.LevelUp(4); // Subir a nivel 5
		AssertTrue(hero.CommandExists("MAGIC", "CMD_BOLA_FUEGO"), "Debería haber aprendido Bola de Fuego a nivel 5.");
	});
	suite_party.AddCase(test_party_learnset);
	
	var test_party_equip_events = new CrispyCase("Test Eventos de Equipamiento (Slot, Item, Stat)", function() {
		global.crispy_test_flags.test = self;
		// Arrange
		var hero = mall_entity_create_instance("HERO_TEST", 1);
		hero.event_on_equip = function() { global.crispy_test_flags.entity = true; };
		
		// Act
		hero.SlotEquip("SLOT_ARMA", "ITEM_ESPADA_BASICA");
		
		// Assert
		AssertTrue(global.crispy_test_flags.entity, "El evento on_equip de la entity debe dispararse.");
		AssertTrue(global.crispy_test_flags.slot, "El evento on_equip del slot debería haberse disparado.");
		AssertTrue(global.crispy_test_flags.item, "El evento on_equip del item debería haberse disparado.");
		AssertTrue(global.crispy_test_flags.stat, "El evento on_equip de la stat debería haberse disparado.");
	});
	suite_party.AddCase(test_party_equip_events);

	var test_party_state_events = new CrispyCase("Test Eventos de Notificación de Estados", function() {
		global.crispy_test_flags.test = self;
		
		var hero = mall_entity_create_instance("HERO_TEST", 1);
		hero.EffectAdd("EFFECT_TEST_BUFF");
		
		AssertTrue(global.crispy_test_flags.effect, "El evento on_add_effect del estado debería haberse disparado.");
		AssertTrue(hero.StateIsActive("STATE_TEST_BUFF"), "El estado debería estar activo.");
	});
	suite_party.AddCase(test_party_state_events);

	var test_party_state_validation = new CrispyCase("Test Eventos de Validación de Estados", function() {
		global.crispy_test_flags.test = self;
		var hero = mall_entity_create_instance("HERO_TEST", 1);
		
		// Act & Assert (Bloqueado)
		global.crispy_test_flags.can_add = false;
		var result1 = hero.EffectAdd("EFFECT_TEST_BUFF");
		AssertFalse(result1.success, "La adición del efecto debería haber fallado.");
		AssertFalse(hero.StateIsActive("STATE_TEST_BUFF"), "El estado no debería estar activo si la validación falla.");
		
		// Act & Assert (Permitido)
		global.crispy_test_flags.can_add = true;
		var result2 = hero.EffectAdd("EFFECT_TEST_BUFF");
		AssertTrue(result2.success, "La adición del efecto debería haber sido exitosa.");
		AssertTrue(hero.StateIsActive("STATE_TEST_BUFF"), "El estado debería estar activo si la validación es exitosa.");
	});
	suite_party.AddCase(test_party_state_validation);

	var test_party_add_effect = new CrispyCase("Test Aplicación de Efectos y Estados", function() {
		global.crispy_test_flags.test = self;
		var hero = mall_entity_create_instance("HERO_TEST", 1);
		AssertFalse(hero.StateIsActive("STATE_FUERZA_AUMENTADA"), "El estado no debería estar activo al start.");
		hero.EffectAdd("EFFECT_BUFF_FUERZA");
		AssertTrue(hero.StateIsActive("STATE_FUERZA_AUMENTADA"), "El estado debería activarse al añadir un efecto.");
	});
	suite_party.AddCase(test_party_add_effect);

	var test_party_state_stat_recalc = new CrispyCase("Test Recalcular Stats con Estados Activos", function() {
		global.crispy_test_flags.test = self;
		var hero = mall_entity_create_instance("HERO_TEST", 1);
		var fuerza_inicial = hero.StatGet("FUERZA").control_value;
		var _add_result = hero.EffectAdd("EFFECT_BUFF_FUERZA");
		var fuerza_end = hero.StatGet("FUERZA").control_value;
		AssertTrue(_add_result.success, "La aplicación del efecto debe ser exitosa.");
		AssertTrue(fuerza_end >= fuerza_inicial, "La Fuerza no debería disminuir al aplicar el estado.");
	});
	suite_party.AddCase(test_party_state_stat_recalc);

	var test_party_remove_effect = new CrispyCase("Test Removesción de Efectos y Estados", function() {
		global.crispy_test_flags.test = self;
		
		var hero = mall_entity_create_instance("HERO_TEST", 1);
		var efecto_inst = hero.EffectAdd("EFFECT_BUFF_FUERZA").added;
		hero.EffectRemove(efecto_inst.template.key, function(_value, _index) { 
			return template.key == _value.template.key;
		});
		
		
		AssertFalse(hero.StateIsActive("STATE_FUERZA_AUMENTADA"), "El estado debería desactivarse al eliminar su último efecto.");
		AssertEqual(hero.StatGet("FUERZA").control_value, 12, "La Fuerza debería volver a su value original sin el estado.");
	});
	suite_party.AddCase(test_party_remove_effect);
}

/// @ignore
function __mall_test_party_entity_events(_runner)
{
	var suite_party_events = new CrispySuite("Pruebas de Eventos de Entity");
	_runner.AddTestSuite(suite_party_events);

	// --- Configuresción de la Suite ---
	suite_party_events.SetUp(function() {
		// Clearsr Systemall
		mall_system_cleanup();
		
		// Arrange: Createsr un set de data completo para probar los eventos
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
	
		var slots = { "type": "Slots", "SLOT_TEST": { "permitted": ["WEAPON"], "event_on_equip": "EVT_SlotOnEquip", "event_on_turn_start": "EVT_SlotOnTurnStart" } };
		file = file_text_open_write("test_e_slots.json");
		file_text_write_string(file, json_stringify(slots));
		file_text_close(file);
	
		var states = { "type": "States", "STATE_TEST": { "event_on_equip": "EVT_StateOnEquip", "event_on_turn_start": "EVT_StateOnTurnStart" } };
		file = file_text_open_write("test_e_states.json");
		file_text_write_string(file, json_stringify(states));
		file_text_close(file);
	
		var entities = { 
			"type": "ENTITIES", 
			"HERO_TEST": {
				"stats": { "STAT_TEST": 10 },
				"learnset": [ { "level": 5, "command": "CMD_BOLA_FUEGO", "category": "MAGIC" } ]
			}			
		};
		file = file_text_open_write("test_e_entities.json");
		file_text_write_string(file, json_stringify(entities));
		file_text_close(file);
	
		__Systemall.__events[$ "EVT_GenericStatUp"] = function(_stat) 
		{ 
			return _stat.base_value + (level * 2); 
		};
		
		__Systemall.__events[$ "EVT_StatOnTurnStart"] = function() 
		{
			global.crispy_test_flags.stat = true; 
		};
		
		__Systemall.__events[$ "EVT_SlotOnTurnStart"] = function() 
		{ 
			global.crispy_test_flags.slot = true; 
		};
		
		__Systemall.__events[$ "EVT_StateOnTurnStart"] = function() 
		{ 
			global.crispy_test_flags.state = true; 
		};
		
		__Systemall.__events[$ "EVT_ItemOnTurnStart"] = function() 
		{ 
			global.crispy_test_flags.item = true; 
		};
		
		__Systemall.__events[$ "EVT_StatOnEquip"] = function() 
		{
			global.crispy_test_flags.stat = true; 
		};
		
		__Systemall.__events[$ "EVT_SlotOnEquip"] = function() 
		{ 
			global.crispy_test_flags.slot = true; 
		};
		
		__Systemall.__events[$ "EVT_StateOnEquip"] = function() 
		{
			global.crispy_test_flags.state = true; 
		};
		
		__Systemall.__events[$ "EVT_ItemOnEquip"] = function() 
		{ 
			global.crispy_test_flags.item = true;
		};
		
		mall_init("test_master_events.json");
		// Fresh entity and flags per case for deterministic event assertions.
		CrispyTest.vars.hero = mall_entity_create_instance("HERO_TEST", 1);
		global.crispy_test_flags = {
			entity: false,
			stat: false,
			slot: false,
			state: false,
			item: false
		};
	});

	suite_party_events.OnRunBegin(function() {
		// Createsr una instancia fresca del héroe para cada prueba
		CrispyTest.vars.hero = mall_entity_create_instance("HERO_TEST", 1);
	
		// Usar una variable global para rastrear los eventos, ya que el context de 'parent' no está disponible en los callbacks
		global.crispy_test_flags = {
			entity: false,
			stat: false,
			slot: false,
			state: false,
			item: false
		};
	});

	suite_party_events.TearDown(function() {
		// Clearsr files
		if (file_exists("test_master_events.json")) file_delete("test_master_events.json");
		if (file_exists("test_e_stats.json")) file_delete("test_e_stats.json");
		if (file_exists("test_e_items.json")) file_delete("test_e_items.json");
		if (file_exists("test_e_slots.json")) file_delete("test_e_slots.json");
		if (file_exists("test_e_states.json")) file_delete("test_e_states.json");
		if (file_exists("test_e_entities.json")) file_delete("test_e_entities.json");
	
		// Clearsr la variable global
		global.crispy_test_flags = undefined;
	});

	// --- Casos de Prueba ---

	var test_equip_dispatch = new CrispyCase("Test Despacho de Eventos al Equipar", function() {
		// Arrange: Sobrescribir las functiones de evento para que modifiquen el tracker global
		CrispyTest.vars.hero.event_on_equip = function() { global.crispy_test_flags.entity = true; };
	
		// Act
		CrispyTest.vars.hero.SlotEquip("SLOT_TEST", "ITEM_TEST");
	
		// Assert
		AssertTrue(global.crispy_test_flags.entity, "El evento on_equip de la entity debe dispararse.");
		AssertTrue(global.crispy_test_flags.stat, "El evento on_equip de la stat debe dispararse.");
		AssertTrue(global.crispy_test_flags.slot, "El evento on_equip del slot debe dispararse.");
		AssertTrue(global.crispy_test_flags.item, "El evento on_equip del item debe dispararse.");
	});
	suite_party_events.AddCase(test_equip_dispatch);

	var test_turn_start_dispatch = new CrispyCase("Test Despacho de Eventos al Iniciar Turno", function() {
		// Arrange
		CrispyTest.vars.hero.SlotEquip("SLOT_TEST", "ITEM_TEST"); // Equipar el item para que su evento de turn se active

		// Act
		CrispyTest.vars.hero.OnTurnStart();
	
		// Assert
		AssertTrue(global.crispy_test_flags.stat, "El evento on_turn_start de la stat debe dispararse.");
		AssertTrue(global.crispy_test_flags.slot, "El evento on_turn_start del slot debe dispararse.");
		AssertTrue(global.crispy_test_flags.item, "El evento on_turn_start del item equipado debe dispararse.");
	});
	suite_party_events.AddCase(test_turn_start_dispatch);	
}

/// @ignore
function __mall_test_ai(_runner)
{
	var suite_ai = new CrispySuite("Pruebas del System de IA");
	_runner.AddTestSuite(suite_ai);

	// --- Configuresción de la Suite de IA ---
	suite_ai.SetUp(function() {
		// Clearsr
		mall_system_cleanup();
		
		// Arrange: Createsr un set de data completo para probar la IA
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
			"type": "ENTITIES", 
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
				"AI_BOSS": { "rules": ["AI_HEALER"] }, // Hereda de AI_HEALER
				"AI_LOOP_A": { "rules": ["AI_LOOP_B", "RULE_ATTACK"] },
				"AI_LOOP_B": { "rules": ["AI_LOOP_A"] }
			}
		};
		file = file_text_open_write("test_ai_packages.json");
		file_text_write_string(file, json_stringify(ai_data));
		file_text_close(file);
		
		// Definir functiones de IA
		__Systemall.__events[$ "AI_COND_Always_True"] = function(caster, context) { return true; };
		__Systemall.__events[$ "AI_COND_HP_Below_50"] = function(caster, context) {
			return (caster.StatGet("EN").current_value / caster.StatGet("EN").control_value) < 0.5;
		};
		__Systemall.__events[$ "AI_ACTION_Attack"] = function(caster, targets) { return "CMD_ATAQUE"; };
		__Systemall.__events[$ "AI_ACTION_Heal"] = function(caster, targets) { return "CMD_CURAR"; };
		__Systemall.__events[$ "AI_TARGET_Self"] = function(caster, context) { return [caster]; };
	
		mall_init("test_master_ai.json");
	});

	suite_ai.OnRunBegin(function() {
		// Createsr instancias para las pruebas
		CrispyTest.vars.caster = mall_entity_create_instance("ENEMY_TEST", 1);
		CrispyTest.vars.ally = mall_entity_create_instance("ALLY_TEST", 1);
		CrispyTest.vars.context = { player_group: new MallEntityGroup("players"), enemy_group: new MallEntityGroup("enemies") };
		CrispyTest.vars.context.enemy_group.Add(CrispyTest.vars.caster);
		CrispyTest.vars.context.player_group.Add(CrispyTest.vars.ally);
	});

	suite_ai.TearDown(function() {
		// Clearsr files
		if (file_exists("test_master_ai.json")) file_delete("test_master_ai.json");
		if (file_exists("test_ai_stats.json")) file_delete("test_ai_stats.json");
		if (file_exists("test_ai_commands.json")) file_delete("test_ai_commands.json");
		if (file_exists("test_ai_entities.json")) file_delete("test_ai_entities.json");
		if (file_exists("test_ai_packages.json")) file_delete("test_ai_packages.json");
	});

	// --- Casos de Prueba ---

	var test_ai_simple_action = new CrispyCase("Test Selección de Acción Simple", function() {
		// Arrange
		CrispyTest.vars.caster.ai_instance = new MallAIInstance(CrispyTest.vars.caster, "AI_SIMPLE");
	
		// Act
		var action = CrispyTest.vars.caster.SelectAction(CrispyTest.vars.context);
	
		// Assert
		AssertIsNotUndefined(action, "La IA debería haber seleccionado una acción.");
		AssertEqual(action.source.key, "CMD_ATAQUE", "La acción seleccionada debe ser el ataque por defecto.");
	});
	suite_ai.AddCase(test_ai_simple_action);

	var test_ai_priority = new CrispyCase("Test Prioridad de Reglas", function() {
		// Arrange
		CrispyTest.vars.caster.ai_instance = new MallAIInstance(CrispyTest.vars.caster, "AI_HEALER");
		CrispyTest.vars.caster.StatSet("EN", 4); // Bajar la vida para activar la condición de curación
	
		// Act
		var action = CrispyTest.vars.caster.SelectAction(CrispyTest.vars.context);
	
		// Assert
		AssertEqual(action.source.key, "CMD_CURAR", "La IA debería priorizar la curación sobre el ataque.");
	});
	suite_ai.AddCase(test_ai_priority);

	var test_ai_inheritance = new CrispyCase("Test Herencia de Paquetes de IA", function() {
		// Arrange
		CrispyTest.vars.caster.ai_instance = new MallAIInstance(CrispyTest.vars.caster, "AI_BOSS");
		CrispyTest.vars.caster.StatSet("EN", 4); // Bajar la vida para activar la condición de curación heredada
	
		// Act
		var action = CrispyTest.vars.caster.SelectAction(CrispyTest.vars.context);
	
		// Assert
		AssertEqual(action.source.key, "CMD_CURAR", "La IA del jefe debería heredar y usar la regla de curación.");
	});
	suite_ai.AddCase(test_ai_inheritance);

	var test_ai_cycle_guard = new CrispyCase("Test Guardia de Recursión en Paquetes IA", function() {
		// Arrange
		CrispyTest.vars.caster.ai_instance = new MallAIInstance(CrispyTest.vars.caster, "AI_LOOP_A");

		// Act
		var action = CrispyTest.vars.caster.SelectAction(CrispyTest.vars.context);

		// Assert
		AssertIsNotUndefined(action, "La IA no debería bloquearse por un ciclo entre paquetes.");
		AssertEqual(action.source.key, "CMD_ATAQUE", "La IA debe ignorar la recursión y resolver reglas válidas restantes.");
	});
	suite_ai.AddCase(test_ai_cycle_guard);
}

/// @ignore
function __mall_test_wate(_runner)
{
	var suite_wate = new CrispySuite("Pruebas del Gestor de Combate");
	_runner.AddTestSuite(suite_wate);

	// --- Configuresción de la Suite de Combate ---
	suite_wate.SetUp(function() {
		// Arrange: Createsr un set de data completo para un escenario de batalla
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
	
		var commands = { "type": "Commands", "CMD_ATAQUE": { "event_execute": "EVT_BATTLE_BasicDamage" } };
		file = file_text_open_write("test_w_commands.json");
		file_text_write_string(file, json_stringify(commands));
		file_text_close(file);
	
		var entities = { 
			"type": "ENTITIES", 
			"HERO": { "stats": { "EN": 100, "VELOCIDAD": 20 }, "commands": { "default": ["CMD_ATAQUE"] } },
			"ENEMY": { "stats": { "EN": 50, "VELOCIDAD": 10 }, "commands": { "default": ["CMD_ATAQUE"] } }
		};
		file = file_text_open_write("test_w_entities.json");
		file_text_write_string(file, json_stringify(entities));
		file_text_close(file);
	
		var encounters = {
			"type": "BATTLE",
			"encounters": {
				"ENCOUNTER_TEST": {
					"event_on_turn_order_create": "EVT_BATTLE_OrderBySpeed",
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
		__Systemall.__events[$ "EVT_BATTLE_OrderBySpeed"] = function(_entities) {
			array_sort(_entities, function(a, b) { return b.StatGet("VELOCIDAD").control_value - a.StatGet("VELOCIDAD").control_value; });
			return _entities;
		};
		__Systemall.__events[$ "EVT_BATTLE_BasicDamage"] = function(_caster, _target, _params) {
			_target.StatAdd("EN", -10);
			return new MallResult().Push(_target.StatGet("EN").current_value <= 0, 0, 10, 0, 0);
		};
	
		mall_init("test_master_wate.json");
	});

		suite_wate.OnRunBegin(function() {
		// Createsr el group de jugadores y las instancias para cada prueba
		CrispyTest.vars.player_group = new MallEntityGroup("PLAYER_GROUP");
		var hero_inst = mall_entity_create_instance("HERO", 1);
		CrispyTest.vars.player_group.Add(hero_inst);
	});

	suite_wate.TearDown(function() {
		// Clearsr files
		if (file_exists("test_master_wate.json")) file_delete("test_master_wate.json");
		if (file_exists("test_w_stats.json")) file_delete("test_w_stats.json");
		if (file_exists("test_w_commands.json")) file_delete("test_w_commands.json");
		if (file_exists("test_w_entities.json")) file_delete("test_w_entities.json");
		if (file_exists("test_w_encounters.json")) file_delete("test_w_encounters.json");
	});

	// --- Casos de Prueba ---

	var test_wate_start = new CrispyCase("Test Inicio de Batalla y Createsción de Instancias", function() {
		// Act
		mall_battle_start_battle("ENCOUNTER_TEST", CrispyTest.vars.player_group);
		
		// Assert
		var manager = mall_battle_get_manager();
		AssertIsNotUndefined(manager, "El BattleManager debería haber sido creado.");
		AssertEqual(array_length(manager.enemy_groups), 1, "Debe haber 1 group de enemigos.");
		AssertEqual(manager.enemy_groups[0].Size(), 1, "El group de enemigos debe contener 1 entity.");
		AssertEqual(manager.enemy_groups[0].Get(0).template_key, "ENEMY", "La entity creada debe ser del template correcto.");
	});
	suite_wate.AddCase(test_wate_start);

	var test_wate_turn_order = new CrispyCase("Test Orden de Turno por Velocidad", function() {
		// Act
		mall_battle_start_battle("ENCOUNTER_TEST", CrispyTest.vars.player_group);
		var manager = mall_battle_get_manager();
		var turn_queue = manager.turn_queue;
	
		// Assert
		AssertEqual(array_length(turn_queue), 2, "La cola de turns debe tener 2 entities.");
		AssertEqual(turn_queue[0].template_key, "HERO", "El héroe (más rápido) debería actuar primero.");
		AssertEqual(turn_queue[1].template_key, "ENEMY", "El enemigo (más lento) debería actuar segundo.");
	});
	suite_wate.AddCase(test_wate_turn_order);

	var test_wate_action_damage = new CrispyCase("Test Ejecución de Acción y Daño", function() {
		// Arrange
		mall_battle_start_battle("ENCOUNTER_TEST", CrispyTest.vars.player_group);
		var manager = mall_battle_get_manager();
		var hero = manager.turn_queue[0];
		var enemy = manager.turn_queue[1];
		var enemy_hp_before = enemy.StatGet("EN").current_value;
	
		var attack_command = hero.CommandGet("default", "CMD_ATAQUE");
		var action = new BattleAction(hero, attack_command, [enemy]);
	
		// Act
		manager.ExecuteAction(action);
	
		// Assert
		var enemy_hp_after = enemy.StatGet("EN").current_value;
		AssertEqual(enemy_hp_after, enemy_hp_before - 10, "El HP del enemigo debería haber disminuido en 10.");
	});
	suite_wate.AddCase(test_wate_action_damage);

	var test_wate_victory_condition = new CrispyCase("Test Condición de Victoria", function() {
		// Arrange
		mall_battle_start_battle("ENCOUNTER_TEST", CrispyTest.vars.player_group);
		var manager = mall_battle_get_manager();
		var hero = manager.turn_queue[0];
		var enemy = manager.turn_queue[1];
		enemy.StatSet("EN", 5); // Dejar al enemigo con 5 HP
	
		var attack_command = hero.CommandGet("default", "CMD_ATAQUE");
		var action = new BattleAction(hero, attack_command, [enemy]);
	
		// Act
		manager.ExecuteAction(action);
	
		// Assert
		AssertIsUndefined(mall_battle_get_manager(), "La batalla debería haber terminado y el gestor debería ser undefined.");
	});
	suite_wate.AddCase(test_wate_victory_condition);	
}

/// @ignore
function __mall_test_broadcast(runner)
{
	var suite_broadcast = new CrispySuite("Pruebas de Broadcast y Mensajes");
	runner.AddTestSuite(suite_broadcast);
	
	// --- Configuresción de la Suite ---
	suite_broadcast.SetUp(function() {
		// Clearsr y reiniciar Systemall antes de cada prueba
		mall_system_cleanup();
	});

	suite_broadcast.OnRunBegin(function() {
		// Usar una variable global para rastrear los eventos
		global.crispy_test_flags = {
			broadcast_fired: false,
			broadcast_data: undefined
		};
	});

	suite_broadcast.TearDown(function() {
		// Clearsr la variable global
		global.crispy_test_flags = undefined;
	});

	// --- Casos de Prueba ---

	var test_broadcast_subscribe_post = new CrispyCase("Test Suscripción y Publicación de Broadcast", function() {
		// Arrange: Createsr una function de callback que modifique el tracker global
		var _test_callback = function(_data) {
			global.crispy_test_flags.broadcast_fired = true;
			global.crispy_test_flags.broadcast_data = _data;
		};
	
		mall_broadcast_subscribe("TEST_EVENT", _test_callback);
	
		// Act
		var _event_data = { message: "hello world" };
		mall_broadcast_post("TEST_EVENT", _event_data);
	
		// Assert
		AssertTrue(global.crispy_test_flags.broadcast_fired, "El evento de broadcast debería haberse disparado.");
		AssertIsNotUndefined(global.crispy_test_flags.broadcast_data, "Los data del evento no deberían ser undefined.");
		AssertEqual(global.crispy_test_flags.broadcast_data.message, "hello world", "Los data del evento no coinciden.");
	});
	suite_broadcast.AddCase(test_broadcast_subscribe_post);

	var test_message_queue = new CrispyCase("Test Cola de Mensajes (Añadir y Obtener)", function() {
		// Arrange
		mall_message_add("Mensaje 1");
		mall_message_add("Mensaje 2", c_red);
	
		// Act & Assert
		AssertFalse(mall_message_is_empty(), "La cola de mensajes no debería estar vacía.");
	
		var msg1 = mall_message_get_next();
		AssertIsNotUndefined(msg1);
		AssertEqual(msg1.text, "Mensaje 1");
	
		var msg2 = mall_message_get_next();
		AssertIsNotUndefined(msg2);
		AssertEqual(msg2.text, "Mensaje 2");
		AssertEqual(msg2.color, c_red);
	
		AssertTrue(mall_message_is_empty(), "La cola de mensajes debería estar vacía después de obtener todos los mensajes.");
	});
	suite_broadcast.AddCase(test_message_queue);	
	
}