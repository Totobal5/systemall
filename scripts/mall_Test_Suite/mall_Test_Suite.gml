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

		mall_system_cleanup();
		mall_init("test_master_malformed.json");

		AssertFalse(mall_exists_stat("EN"), "Malformed JSON file must not create any stat entries.");
		AssertEqual(array_length(mall_get_stat_keys()), 0, "No stats should be loaded when the only source file is malformed.");
	
		file_delete("test_master_malformed.json");
	});
	suite_loading.AddCase(test_load_fail);

	// --- Test Case 2.3: Real Datafiles Load ---
	var test_load_real_datafiles = new CrispyCase("Test Real Datafiles JSON Load", function() {
		var _master_candidates = [
			"datafiles/mall_database.json",
			"./datafiles/mall_database.json",
			"mall_database.json",
			"./mall_database.json"
		];
		var _master_path = "";
		var _candidate_count = array_length(_master_candidates);
		for (var i = 0; i < _candidate_count; i++)
		{
			var _candidate = _master_candidates[i];
			if (file_exists(_candidate))
			{
				_master_path = _candidate;
				break;
			}
		}

		AssertTrue(_master_path != "", "Could not resolve 'mall_database.json' in runtime working directory.");

		mall_system_cleanup();
		mall_init(_master_path);

		AssertTrue(mall_exists_stat("EN"), "Expected stat 'EN' from datafiles/components/stats.json.");
		AssertTrue(mall_exists_state("STATE_VENENO"), "Expected state 'STATE_VENENO' from datafiles/components/states.json.");
		AssertTrue(mall_exists_slot("SLOT_ARMA"), "Expected slot 'SLOT_ARMA' from datafiles/components/slots.json.");

		AssertTrue(mall_exists_item("POTION_01"), "Expected item 'POTION_01' from datafiles/pocket/general_items.json.");
		AssertTrue(mall_exists_bag("BAG_PLAYER_INVENTORY"), "Expected bag 'BAG_PLAYER_INVENTORY' from datafiles/pocket/bags.json.");
		AssertTrue(mall_exists_group("HEROES"), "Expected group 'HEROES' from datafiles/party/groups.json.");
	});
	suite_loading.AddCase(test_load_real_datafiles);

	// --- Test Case 2.4: Real Datafiles Create One Of Each ---
	var test_load_real_datafiles_create_one_each = new CrispyCase("Test Real Datafiles Create One Of Each", function() {
		var _master_candidates = [
			"datafiles/mall_database.json",
			"./datafiles/mall_database.json",
			"mall_database.json",
			"./mall_database.json"
		];
		var _master_path = "";
		var _candidate_count = array_length(_master_candidates);
		for (var i = 0; i < _candidate_count; i++)
		{
			var _candidate = _master_candidates[i];
			if (file_exists(_candidate) )
			{
				_master_path = _candidate;
				break;
			}
		}

		AssertTrue(_master_path != "", "Could not resolve 'mall_database.json' in runtime working directory.");

		mall_system_cleanup();
		mall_init(_master_path);

		var _stat_keys =		mall_get_stat_keys();
		var _slot_keys =		mall_get_slot_keys();
		var _state_keys =		mall_get_state_keys();
		var _item_keys =		mall_get_item_keys();
		var _bag_keys =			mall_get_bag_keys();
		var _group_keys =		mall_get_group_keys();
		var _entity_keys = 		mall_get_entity_keys();
		var _command_keys =		mall_get_command_keys();
		var _effect_keys =		mall_get_effect_keys();
		var _ai_package_keys =	struct_get_names(__Systemall.__ai_packages);
		var _ai_rule_keys =		struct_get_names(__Systemall.__ai_rules);

		AssertTrue(array_length(_stat_keys)    > 0, "Expected at least one stat key loaded from database.");
		AssertTrue(array_length(_slot_keys)    > 0, "Expected at least one slot key loaded from database.");
		AssertTrue(array_length(_state_keys)   > 0, "Expected at least one state key loaded from database.");
		AssertTrue(array_length(_item_keys)    > 0, "Expected at least one item key loaded from database.");
		AssertTrue(array_length(_bag_keys)     > 0, "Expected at least one bag key loaded from database.");
		AssertTrue(array_length(_group_keys)   > 0, "Expected at least one group key loaded from database.");
		AssertTrue(array_length(_entity_keys)  > 0, "Expected at least one entity template key loaded from database.");
		AssertTrue(array_length(_command_keys) > 0, "Expected at least one command key loaded from database.");
		AssertTrue(array_length(_effect_keys)  > 0, "Expected at least one effect key loaded from database.");
		
		// AI
		AssertTrue(array_length(_ai_package_keys) > 0, "Expected at least one AI package loaded from database.");
		AssertTrue(array_length(_ai_rule_keys)    > 0, "Expected at least one AI rule loaded from database.");

		var _stat_template = mall_get_stat(_stat_keys[0]);
		var _slot_template = mall_get_slot(_slot_keys[0]);
		var _state_template = mall_get_state(_state_keys[0]);
		var _item_template = mall_get_item(_item_keys[0]);
		var _command_template = mall_get_command(_command_keys[0]);
		var _effect_template = mall_get_effect(_effect_keys[0]);
		var _group_template = mall_get_group(_group_keys[0]);
		var _bag_template = mall_get_bag(_bag_keys[0]);
		var _ai_package_template = mall_get_ai_package(_ai_package_keys[0]);
		var _ai_rule_template = mall_get_ai_rule(_ai_rule_keys[0]);

		AssertTrue(is_struct(_stat_template), "Failed to fetch one loaded stat template.");
		AssertTrue(is_struct(_slot_template), "Failed to fetch one loaded slot template.");
		AssertTrue(is_struct(_state_template), "Failed to fetch one loaded state template.");
		AssertTrue(is_struct(_item_template), "Failed to fetch one loaded item template.");
		AssertTrue(is_struct(_command_template), "Failed to fetch one loaded command template.");
		AssertTrue(is_struct(_effect_template), "Failed to fetch one loaded effect template.");
		AssertTrue(is_struct(_group_template), "Failed to fetch one loaded group template.");
		AssertTrue(is_struct(_bag_template), "Failed to fetch one loaded bag template.");
		AssertTrue(is_struct(_ai_package_template), "Failed to fetch one loaded AI package template.");
		AssertTrue(is_struct(_ai_rule_template), "Failed to fetch one loaded AI rule template.");

		var _entity = mall_entity_create_instance(_entity_keys[0], 1, { source: "test_load_real_datafiles_create_one_each" });
		AssertTrue(is_struct(_entity), "Failed to create one entity instance from loaded templates.");

		AssertTrue(is_struct(_entity.StatGet(_stat_keys[0])), "Failed to create/get one stat instance on entity.");
		AssertTrue(is_struct(_entity.SlotGet(_slot_keys[0])), "Failed to create/get one slot instance on entity.");
		AssertTrue(is_struct(_entity.StateGet(_state_keys[0])), "Failed to create/get one state instance on entity.");

		var _bag_instance = _bag_template.CreateInstance("TEST_BAG_INSTANCE");
		AssertTrue(is_struct(_bag_instance), "Failed to create one bag instance from loaded bag template.");

		var _command_added = _entity.CommandAdd("__TEST", _command_keys[0]);
		AssertTrue(_command_added, "Failed to add one loaded command to entity.");
		AssertTrue(is_struct(_entity.CommandGet("__TEST", _command_keys[0])), "Failed to retrieve one loaded command from entity.");

		var _effect_add_result = _entity.EffectAdd(_effect_keys[0]);
		AssertTrue(is_struct(_effect_add_result), "Failed to invoke EffectAdd with one loaded effect.");

		var _ai_instance = new MallAIInstance(_entity, _ai_package_keys[0]);
		AssertTrue(is_struct(_ai_instance), "Failed to create one AI instance from loaded AI package.");

		var _group_add_result = mall_group_add(_group_keys[0], _entity);
		AssertTrue(_group_add_result, "Failed to add created entity instance to one loaded group.");
	});
	suite_loading.AddCase(test_load_real_datafiles_create_one_each);
	
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
			"ITEM_POCION": { "type": ["CONSUMABLE"], "is_stackable": true, "stack_limit": 99 },
			"ITEM_ESPADA_HIERRO": { "type": ["WEAPON"], "is_stackable": false }
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
		AssertEqual(result.GetVar("added"), 20, "Exactly 20 potions should be added.");
		AssertEqual(result.GetVar("leftover"), 0, "No potions should remain as leftover.");
	});
	suite_pocket.AddCase(test_pocket_stack);

	// --- Caso de Prueba 3.3: Items No Apilables ---
	var test_pocket_no_stack = new CrispyCase("Test Items No Apilables", function() {
		CrispyTest.vars.bag.AddItem("ITEM_ESPADA_HIERRO", 1);
		var result = CrispyTest.vars.bag.AddItem("ITEM_ESPADA_HIERRO", 1); // Intentar añadir una segunda espada
	
		AssertEqual(CrispyTest.vars.bag.GetItemCount("ITEM_ESPADA_HIERRO"), 1, "La cantidad total de espadas debe seguir siendo 1.");
		AssertEqual(array_length(CrispyTest.vars.bag.GetOrderedItems()), 1, "Solo debe haber 1 slot de item ocupado.");
		AssertEqual(result.GetVar("added"), 0, "No se debió añadir ninguna espada nueva.");
		AssertEqual(result.GetVar("leftover"), 1, "Debió sobrar 1 espada.");
	});
	suite_pocket.AddCase(test_pocket_no_stack);

	// --- Caso de Prueba 3.4: Añadir Múltiples Items No Apilables ---
	var test_pocket_add_multiple_non_stackable = new CrispyCase("Test Añadir Múltiples Items No Apilables", function() {
		// Act
		var result = CrispyTest.vars.bag.AddItem("ITEM_ESPADA_HIERRO", 5);
	
		// Assert
		AssertEqual(result.GetVar("added"), 1, "Solo se debe añadir 1 item no apilable.");
		AssertEqual(result.GetVar("leftover"), 4, "Deben sobrar 4 items no apilables.");
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
		AssertEqual(result.GetVar("added"), 1, "Se debió añadir la nueva espada con vars.");
		AssertEqual(result.GetVar("leftover"), 0, "No debió sobrar ninguna espada.");
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
			"ITEM_POCION": { "type": ["CONSUMABLE"], "is_stackable": true, "stack_limit": 20 },
			"ITEM_ESPADA_HIERRO": { "type": ["WEAPON"], "is_stackable": false },
			"ITEM_LLAVE_MAESTRA": { "type": ["KEY_ITEM"], "is_stackable": false }
		});
		file = file_text_open_write("test_items_complex.json");
		file_text_write_string(file, items_content);
		file_text_close(file);
	
		var bags_content = json_stringify({
			"type": "Bags",
			"BAG_CATEGORIZED": {
				"bag_type": "complex",
				"limit": 99,
				"overrides": {
					"KEY_ITEM": { "limit": 2 }
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
		AssertEqual(result.GetVar("added"), 0, "No se debió añadir la tercera key.");
		AssertEqual(result.GetVar("leftover"), 1, "Debió sobrar 1 key.");
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
			"ITEM_POCION": { "type": ["CONSUMABLE"], "is_stackable": true, "stack_limit": 99 }
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
				"type": ["WEAPON"], 
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
				"type": ["WEAPON"], 
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
function __mall_test_entity_api_full(_runner)
{
	var suite_entity_api = new CrispySuite("Entity Full API Consistency Tests");
	_runner.AddTestSuite(suite_entity_api);

	suite_entity_api.SetUp(function() {
		mall_system_cleanup();

		var _master = {
			"Stats": ["./test_api_stats.json"],
			"Items": ["./test_api_items.json"],
			"Slots": ["./test_api_slots.json"],
			"States": ["./test_api_states.json"],
			"Effects": ["./test_api_effects.json"],
			"Commands": ["./test_api_commands.json"],
			"Party": ["./test_api_entities.json"]
		};

		var _file = file_text_open_write("test_master_api.json");
		file_text_write_string(_file, json_stringify(_master));
		file_text_close(_file);

		var _stats = {
			"type": "Stats",
			"HP": {
				"max_value": 9999,
				"event_on_level_up": "EVT_API_StatLevel"
			},
			"ATK": {
				"max_value": 9999,
				"event_on_level_up": "EVT_API_StatLevel"
			}
		};

		_file = file_text_open_write("test_api_stats.json");
		file_text_write_string(_file, json_stringify(_stats));
		file_text_close(_file);

		var _items = {
			"type": "Items",
			"ITEM_SWORD": {
				"type": ["WEAPON"],
				"is_stackable": false,
				"stats": {
					"ATK+": 5
				}
			}
		};

		_file = file_text_open_write("test_api_items.json");
		file_text_write_string(_file, json_stringify(_items));
		file_text_close(_file);

		var _slots = {
			"type": "Slots",
			"SLOT_WEAPON": {
				"permitted": ["WEAPON"],
				"max_items": 1
			}
		};

		_file = file_text_open_write("test_api_slots.json");
		file_text_write_string(_file, json_stringify(_slots));
		file_text_close(_file);

		var _states = {
			"type": "States",
			"STATE_STUN": {
				"state_type": "AILMENT",
				"restricts_action": true
			},
			"STATE_BUFF_ATK": {
				"state_type": "BUFF",
				"stats": {
					"ATK+": 2
				}
			}
		};

		_file = file_text_open_write("test_api_states.json");
		file_text_write_string(_file, json_stringify(_states));
		file_text_close(_file);

		var _effects = {
			"type": "Effects",
			"EFFECT_STUN": {
				"state_key": "STATE_STUN"
			},
			"EFFECT_BUFF_ATK": {
				"state_key": "STATE_BUFF_ATK"
			}
		};

		_file = file_text_open_write("test_api_effects.json");
		file_text_write_string(_file, json_stringify(_effects));
		file_text_close(_file);

		var _commands = {
			"type": "Commands",
			"CMD_HIT": {},
			"CMD_SKILL": {}
		};

		_file = file_text_open_write("test_api_commands.json");
		file_text_write_string(_file, json_stringify(_commands));
		file_text_close(_file);

		var _entities = {
			"type": "ENTITIES",
			"HERO_API": {
				"stats": {
					"HP": 30,
					"ATK": 10
				},
				"commands": {
					"default": ["CMD_HIT"]
				},
				"learnset": [
					{ "level": 2, "command": "CMD_SKILL", "category": "skill" }
				],
				"flags": {
					"ELITE": true
				}
			}
		};

		_file = file_text_open_write("test_api_entities.json");
		file_text_write_string(_file, json_stringify(_entities));
		file_text_close(_file);

		__Systemall.__events[$ "EVT_API_StatLevel"] = function(_stat)
		{
			return _stat.base_value + level;
		};

		mall_init("test_master_api.json");
	});

	suite_entity_api.OnRunBegin(function() {
		CrispyTest.vars.hero = mall_entity_create_instance("HERO_API", 1);
	});

	suite_entity_api.TearDown(function() {
		if (file_exists("test_master_api.json")) file_delete("test_master_api.json");
		if (file_exists("test_api_stats.json")) file_delete("test_api_stats.json");
		if (file_exists("test_api_items.json")) file_delete("test_api_items.json");
		if (file_exists("test_api_slots.json")) file_delete("test_api_slots.json");
		if (file_exists("test_api_states.json")) file_delete("test_api_states.json");
		if (file_exists("test_api_effects.json")) file_delete("test_api_effects.json");
		if (file_exists("test_api_commands.json")) file_delete("test_api_commands.json");
		if (file_exists("test_api_entities.json")) file_delete("test_api_entities.json");
	});

	var test_entity_stats_api = new CrispyCase("Entity Stats API Methods", function() {
		var _hero = CrispyTest.vars.hero;

		AssertIsNotUndefined(_hero.StatGet("ATK"), "StatGet should return loaded stat instance.");
		AssertEqual(_hero.StatSet("ATK", 7), 7, "StatSet should set current value when within clamp bounds.");
		var _atk = _hero.StatGet("ATK");
		var _old_atk = _atk.current_value;
		var _expected_delta = clamp(_old_atk + 5, _atk.template.min_value, _atk.control_value) - _old_atk;
		AssertEqual(_hero.StatAdd("ATK", 5), _expected_delta, "StatAdd should return real applied delta after clamp.");

		var _stat_counter = { value: 0 };
		_hero.StatForeach(method(_stat_counter, function(_key, _stat) {
			value++;
		}));
		AssertEqual(_stat_counter.value, array_length(struct_get_names(_hero.stats)), "StatForeach should iterate all stats.");
	});
	suite_entity_api.AddCase(test_entity_stats_api);

	var test_entity_slots_api = new CrispyCase("Entity Slots API Methods", function() {
		var _hero = CrispyTest.vars.hero;

		AssertTrue(_hero.SlotIsPermitted("SLOT_WEAPON", "ITEM_SWORD"), "Slot should permit ITEM_SWORD.");
		AssertTrue(_hero.SlotIsEmpty("SLOT_WEAPON"), "Slot should start empty.");

		var _equip = _hero.SlotEquip("SLOT_WEAPON", "ITEM_SWORD");
		AssertTrue(_equip.success, "SlotEquip should succeed.");
		AssertEqual(array_length(_equip.previously_equipped), 0, "First equip should report empty previous equipment.");
		AssertFalse(_hero.SlotIsEmpty("SLOT_WEAPON"), "Slot should no longer be empty.");
		AssertEqual(array_length(_hero.SlotGetEquipped("SLOT_WEAPON")), 1, "Slot should contain one equipped item.");

		var _desequip = _hero.SlotDesequip("SLOT_WEAPON", "ITEM_SWORD");
		AssertTrue(_desequip.success, "SlotDesequip should succeed.");
		AssertEqual(_desequip.unequipped_item, "ITEM_SWORD", "Unequipped key should match requested item.");

		var _slot_counter = { value: 0 };
		_hero.SlotForeach(method(_slot_counter, function(_slot, _key) {
			value++;
		}));
		AssertEqual(_slot_counter.value, array_length(struct_get_names(_hero.slots)), "SlotForeach should iterate all slots.");
	});
	suite_entity_api.AddCase(test_entity_slots_api);

	var test_entity_states_effects_api = new CrispyCase("Entity States and Effects API Methods", function() {
		var _hero = CrispyTest.vars.hero;
		var _add = _hero.EffectAdd("EFFECT_BUFF_ATK");
		AssertTrue(_add.success, "EffectAdd should succeed for buff effect.");
		AssertTrue(_hero.StateIsActive("STATE_BUFF_ATK"), "State should be active after adding effect.");

		var _effect_counter = { value: 0 };
		_hero.EffectForeach("STATE_BUFF_ATK", method(_effect_counter, function(_effect, _index) {
			value++;
		}));
		AssertEqual(_effect_counter.value, 1, "EffectForeach should iterate active effects for the state.");

		var _active = _hero.StateGetAllActive();
		AssertTrue(array_contains(_active, "STATE_BUFF_ATK"), "StateGetAllActive should include the active buff.");

		var _buffs = _hero.StateGetAllByType("buff");
		AssertTrue(array_contains(_buffs, "STATE_BUFF_ATK"), "StateGetAllByType should be case-insensitive.");

		var _removed = _hero.StateRemoveAllEffects("STATE_BUFF_ATK");
		AssertTrue(is_struct(_removed), "StateRemoveAllEffects should return a result struct.");
		AssertFalse(_hero.StateIsActive("STATE_BUFF_ATK"), "State should deactivate after removing all effects.");

		var _state_counter = { value: 0 };
		_hero.StateForeach(method(_state_counter, function(_key, _state) {
			value++;
		}));
		AssertEqual(_state_counter.value, array_length(struct_get_names(_hero.states)), "StateForeach should iterate all states.");
	});
	suite_entity_api.AddCase(test_entity_states_effects_api);

	var test_entity_commands_api = new CrispyCase("Entity Commands API Methods", function() {
		var _hero = CrispyTest.vars.hero;

		AssertFalse(_hero.CommandExists("skill", "CMD_SKILL"), "Skill command should not exist before level up.");
		_hero.LevelUp(1);
		AssertTrue(_hero.CommandExists("skill", "CMD_SKILL"), "Skill command should be learned at level 2.");

		AssertIsNotUndefined(_hero.CommandGet("skill", "CMD_SKILL"), "CommandGet should return learned command template.");
		AssertEqual(array_length(_hero.CommandGetAll("skill")), 1, "CommandGetAll should return one learned skill.");
		AssertIsNotUndefined(_hero.CommandGetRandom("skill"), "CommandGetRandom should return one command key when category is not empty.");

		var _categories = _hero.CategoryGetAll();
		AssertTrue(array_contains(_categories, "default"), "CategoryGetAll should include default category.");
		AssertTrue(array_contains(_categories, "skill"), "CategoryGetAll should include learned category.");

		_hero.CommandRemove("skill", "CMD_SKILL");
		AssertFalse(_hero.CommandExists("skill", "CMD_SKILL"), "Removed command should no longer exist.");
	});
	suite_entity_api.AddCase(test_entity_commands_api);

	var test_entity_misc_flags_save = new CrispyCase("Entity Misc Flags and Save API Methods", function() {
		var _hero = CrispyTest.vars.hero;

		AssertTrue(_hero.FlagHas("ELITE"), "Entity template flags should be loaded.");
		_hero.FlagAdd("CANARY");
		AssertTrue(_hero.FlagHas("CANARY"), "FlagAdd should add runtime flag.");
		_hero.FlagRemove("CANARY");
		AssertFalse(_hero.FlagHas("CANARY"), "FlagRemove should remove runtime flag.");

		_hero.AggroAdd(7);
		AssertEqual(_hero.AggroGet(), 7, "AggroAdd should increase threat.");
		_hero.AggroReset();
		AssertEqual(_hero.AggroGet(), 0, "AggroReset should reset threat to zero.");

		AssertTrue(_hero.CanAct(), "Entity should be able to act before restrictive states.");
		_hero.EffectAdd("EFFECT_STUN");
		AssertFalse(_hero.CanAct(), "Entity should not act while restrictive state is active.");
		_hero.StateRemoveAllEffects("STATE_STUN");
		AssertTrue(_hero.CanAct(), "Entity should act again after removing restrictive state effects.");

		_hero.AddDrop("ITEM_SWORD", 2, 100);
		var _drops = _hero.GetDrops();
		AssertIsNotUndefined(_drops, "GetDrops should return a drop struct.");
		AssertTrue(array_length(_drops.items) > 0, "GetDrops should include guaranteed bonus drop.");

		_hero.SlotEquip("SLOT_WEAPON", "ITEM_SWORD");
		_hero.EffectAdd("EFFECT_BUFF_ATK");
		_hero.StatSet("HP", 12);

		var _saved = _hero.Export();
		var _clone = mall_entity_create_instance("HERO_API", 1);
		_clone.Import(_saved);

		AssertEqual(_clone.level, _saved.level, "Import should restore exported level.");
		AssertEqual(_clone.StatGet("HP").current_value, _hero.StatGet("HP").current_value, "Import should restore current stat values.");
		AssertEqual(array_length(_clone.SlotGetEquipped("SLOT_WEAPON")), array_length(_hero.SlotGetEquipped("SLOT_WEAPON")), "Import should restore equipped items.");
		AssertTrue(_clone.FlagHas("ELITE"), "Import should restore exported flags.");
	});
	suite_entity_api.AddCase(test_entity_misc_flags_save);

	var test_item_and_instance_consistency = new CrispyCase("MallItem and MallItemInstance Consistency", function() {
		var _item = (new MallItem("ITEM_TMP") ).FromData({
			"type": ["weapon"],
			"stats": {
				"ATK%": 10,
				"HP+": 3
			}
		});

		AssertTrue(struct_exists(_item.stats, "ATK"), "FromData should parse percentage suffix and store key without suffix.");
		AssertTrue(struct_exists(_item.stats, "HP"), "FromData should parse plus suffix and store key without suffix.");
		AssertEqual(_item.stats[$ "ATK"][1], MALL_NUMTYPE.PERCENT, "ATK modifier should be PERCENT.");
		AssertEqual(_item.stats[$ "HP"][1], MALL_NUMTYPE.REAL, "HP modifier should be REAL.");

		var _inst = new MallItemInstance("ITEM_TMP", 2, { roll: 1 });
		var _export = _inst.Export();
		_export.vars.roll = 99;
		AssertEqual(_inst.vars.roll, 1, "Export should clone vars and avoid mutating the source instance.");

		var _inst_2 = new MallItemInstance("DUMMY", 0, {});
		_inst_2.Import(_export);
		AssertEqual(_inst_2.key, "ITEM_TMP", "Import should restore key.");
		AssertEqual(_inst_2.count, 2, "Import should restore count.");
		AssertEqual(_inst_2.vars.roll, 99, "Import should restore vars payload.");
		_export.vars.roll = 7;
		AssertEqual(_inst_2.vars.roll, 99, "Import should clone vars and avoid shared references.");
	});
	suite_entity_api.AddCase(test_item_and_instance_consistency);
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
				"RULE_HEAL": { "priority": 100, "condition": "AI_COND_HP_Below_50", "action": "AI_ACTION_Heal", "target": "AI_TARGET_Self" },
				"RULE_SINGLE_TARGET": { "priority": 50, "condition": "AI_COND_Always_True", "action": "AI_ACTION_Attack", "target": "AI_TARGET_Single_Target" },
				"RULE_BAD_ACTION": { "priority": 100, "condition": "AI_COND_Always_True", "action": "AI_ACTION_Invalid_Command", "target": "AI_TARGET_Self" }
			},
			"packages": {
				"AI_SIMPLE": { "rules": ["RULE_ATTACK"] },
				"AI_HEALER": { "rules": ["RULE_HEAL", "RULE_ATTACK"] },
				"AI_BOSS": { "rules": ["AI_HEALER"] }, // Hereda de AI_HEALER
				"AI_SINGLE": { "rules": ["RULE_SINGLE_TARGET"] },
				"AI_BAD_ACTION": { "rules": ["RULE_BAD_ACTION", "RULE_ATTACK"] },
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
		__Systemall.__events[$ "AI_ACTION_Invalid_Command"] = function(caster, targets) { return "CMD_NO_EXISTE"; };
		__Systemall.__events[$ "AI_TARGET_Self"] = function(caster, context) { return [caster]; };
		__Systemall.__events[$ "AI_TARGET_Single_Target"] = function(caster, context) { return caster; };
	
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

	var test_ai_single_target_normalization = new CrispyCase("Test Target IA No-Array", function() {
		// Arrange
		CrispyTest.vars.caster.ai_instance = new MallAIInstance(CrispyTest.vars.caster, "AI_SINGLE");

		// Act
		var action = CrispyTest.vars.caster.SelectAction(CrispyTest.vars.context);

		// Assert
		AssertIsNotUndefined(action, "La IA debería normalizar target single a array y seleccionar acción.");
		AssertEqual(array_length(action.targets), 1, "La acción debe contener un solo objetivo normalizado.");
		AssertEqual(action.source.key, "CMD_ATAQUE", "La acción resultante debe usar ataque.");
	});
	suite_ai.AddCase(test_ai_single_target_normalization);

	var test_ai_missing_package_safe = new CrispyCase("Test IA con Paquete Inválido", function() {
		// Arrange
		CrispyTest.vars.caster.ai_instance = new MallAIInstance(CrispyTest.vars.caster, "AI_DOES_NOT_EXIST");

		// Act
		var action = CrispyTest.vars.caster.SelectAction(CrispyTest.vars.context);

		// Assert
		AssertIsUndefined(action, "Paquete inválido no debe romper flujo y debe devolver undefined.");
	});
	suite_ai.AddCase(test_ai_missing_package_safe);

	var test_ai_invalid_command_fallback = new CrispyCase("Test IA Comando No Registrado", function() {
		// Arrange
		CrispyTest.vars.caster.ai_instance = new MallAIInstance(CrispyTest.vars.caster, "AI_BAD_ACTION");

		// Act
		var action = CrispyTest.vars.caster.SelectAction(CrispyTest.vars.context);

		// Assert
		AssertIsNotUndefined(action, "Si una regla falla por comando inválido, debe intentar reglas siguientes válidas.");
		AssertEqual(action.source.key, "CMD_ATAQUE", "La IA debe caer a la regla válida posterior.");
	});
	suite_ai.AddCase(test_ai_invalid_command_fallback);
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
function __mall_test_types(_runner)
{
	var suite_types = new CrispySuite("Type System Refactor Tests");
	_runner.AddTestSuite(suite_types);

	suite_types.SetUp(function() {
		mall_system_cleanup();
	});

	var test_types_hybrid_index = new CrispyCase("Test Hybrid Struct+Array Index", function() {
		mall_create_type("MAGICO", ["ITEM_FIRE", "ITEM_ICE", "ITEM_FIRE"]);

		AssertTrue(struct_exists(__Systemall.__types, "MAGICO"), "Type bucket should exist in array registry.");
		AssertTrue(struct_exists(__Systemall.__types_fast, "MAGICO"), "Type bucket should exist in fast registry.");
		AssertEqual(array_length(__Systemall.__types[$ "MAGICO"]), 2, "Duplicated values should be deduplicated.");
		AssertTrue(struct_exists(__Systemall.__types_fast[$ "MAGICO"], "ITEM_FIRE"), "Fast bucket should contain ITEM_FIRE.");
		AssertTrue(struct_exists(__Systemall.__types_fast[$ "MAGICO"], "ITEM_ICE"), "Fast bucket should contain ITEM_ICE.");
	});
	suite_types.AddCase(test_types_hybrid_index);

	var test_types_hierarchy_and_lookup = new CrispyCase("Test Hierarchy Inheritance Lookup", function() {
		mall_create_type("FUEGO", "ITEM_FIRE");
		mall_create_type("HIELO", "ITEM_ICE");
		mall_types_set_hierarchy({
			"FUEGO": ["MAGICO"],
			"HIELO": ["MAGICO"]
		});

		AssertTrue(mall_exists_type("MAGICO"), "Parent tag should be considered as existing.");
		AssertTrue(mall_type_has_value("MAGICO", "ITEM_FIRE"), "MAGICO should include FIRE descendants.");
		AssertTrue(mall_type_has_value("MAGICO", "ITEM_ICE"), "MAGICO should include ICE descendants.");

		var _magical_values = mall_get_type("MAGICO");
		AssertTrue(is_array(_magical_values), "Parent query should return merged descendant values.");
		AssertTrue(array_contains(_magical_values, "ITEM_FIRE"), "Merged values should include ITEM_FIRE.");
		AssertTrue(array_contains(_magical_values, "ITEM_ICE"), "Merged values should include ITEM_ICE.");
	});
	suite_types.AddCase(test_types_hierarchy_and_lookup);

	var test_types_query_and_or_not = new CrispyCase("Test Logical Query AND OR NOT", function() {
		mall_types_set_hierarchy({ "FUEGO": ["MAGICO"] });

		var _index = mall_types_make_index(["FUEGO", "RANGO"]);
		var _q_and = { "and": ["MAGICO", "RANGO"] };
		var _q_or = { "or": ["DEFENSA", "MAGICO"] };
		var _q_not = { "not": ["MAGICO"] };
		var _q_combo = { "and": ["RANGO"], "not": ["PESADO"] };

		AssertTrue(mall_types_match_query(_index, _q_and), "AND should require all tags.");
		AssertTrue(mall_types_match_query(_index, _q_or), "OR should pass if any tag matches.");
		AssertFalse(mall_types_match_query(_index, _q_not), "NOT should fail when excluded tag exists.");
		AssertTrue(mall_types_match_query(_index, _q_combo), "Combined query should pass when constraints are met.");
	});
	suite_types.AddCase(test_types_query_and_or_not);

	var test_types_mutex = new CrispyCase("Test Mutex Compatibility Rules", function() {
		mall_types_set_hierarchy({ "NO_MUERTO": ["MUERTO"] });
		mall_types_set_mutex({
			"VIVO": ["NO_MUERTO"],
			"NO_MUERTO": ["VIVO"]
		});

		var _add_vivo = mall_types_try_add([], "VIVO");
		AssertTrue(_add_vivo.success, "Adding first tag should succeed.");

		var _add_undead = mall_types_try_add(_add_vivo.types, "NO_MUERTO");
		AssertFalse(_add_undead.success, "Conflicting mutex tag should be rejected.");
		AssertTrue(array_contains(_add_undead.conflicts, "VIVO"), "Conflict payload should include existing conflicting tag.");
		AssertTrue(array_contains(_add_undead.conflicts, "NO_MUERTO"), "Conflict payload should include incoming conflicting tag.");
	});
	suite_types.AddCase(test_types_mutex);

	var test_types_filter_components = new CrispyCase("Test Filtering Components By Query", function() {
		mall_types_set_hierarchy({ "FUEGO": ["MAGICO"] });

		var _items = [
			{ key: "A", type: ["FUEGO", "RANGO"] },
			{ key: "B", type: ["HIELO", "RANGO"] },
			{ key: "C", type: ["PESADO", "MELEE"] }
		];

		var _filter_query = {
			"and": ["RANGO"],
			"or": ["MAGICO", "HIELO"],
			"not": ["PESADO"]
		};

		var _filtered = mall_types_filter_components(_items, _filter_query);

		AssertEqual(array_length(_filtered), 2, "Two entries should satisfy the logical filter.");
		AssertEqual(_filtered[0].key, "A", "First filtered entry should be A.");
		AssertEqual(_filtered[1].key, "B", "Second filtered entry should be B.");
	});
	suite_types.AddCase(test_types_filter_components);

	var test_types_remove_api = new CrispyCase("Test Remove Type API", function() {
		mall_create_type("MAGICO", ["ITEM_FIRE", "ITEM_ICE"]);
		mall_create_type("FISICO", ["ITEM_AXE"]);

		AssertTrue(mall_remove_type_value("MAGICO", "ITEM_FIRE"), "Removing one value should return true.");
		AssertFalse(mall_type_has_value("MAGICO", "ITEM_FIRE"), "Removed value should not exist anymore.");
		AssertTrue(mall_type_has_value("MAGICO", "ITEM_ICE"), "Remaining value should still exist.");

		AssertTrue(mall_remove_type(["MAGICO", "FISICO"]), "Removing existing buckets should return true.");
		AssertFalse(mall_exists_type("MAGICO"), "MAGICO bucket should be removed.");
		AssertFalse(mall_exists_type("FISICO"), "FISICO bucket should be removed.");
	});
	suite_types.AddCase(test_types_remove_api);
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