/// @description TEST CORE
// =============================================================================
// SUITE 1: PRUEBAS DE COMPONENTES BASE (CORE)
// =============================================================================
var suite_core = new TestSuite("Pruebas de Componentes Base");
runner.addTestSuite(suite_core);

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