// -----------------------------------------------------------------------------
// SCRIPT DE PRUEBAS PARA SYSTEMALL USANDO CRISPY
// -----------------------------------------------------------------------------
// Este script debe ser ejecutado en el evento Create de un objeto de prueba.

// --- INICIALIZACIÓN DEL TEST RUNNER ---
var runner = new TestRunner("Systemall_Tests");

// =============================================================================
// SUITE 1: PRUEBAS DE COMPONENTES BASE (CORE)
// =============================================================================
__mall_test_core(runner);

// =============================================================================
// SUITE 2: PRUEBAS DEL SISTEMA DE CARGA
// =============================================================================
__mall_test_load(runner);

// =============================================================================
// SUITE 3: PRUEBAS DEL SISTEMA DE INVENTARIO (POCKET)
// =============================================================================
__mall_test_pocket_bag_simple(runner);

// =============================================================================
// SUITE 4: PRUEBAS DE MOCHILA COMPLEJA
// =============================================================================
__mall_test_pocket_bag_complex(runner);

// =============================================================================
// SUITE 5: PRUEBAS DE EVENTOS DE INVENTARIO
// =============================================================================
__mall_test_pocket_bag_events(runner);

// =============================================================================
// SUITE 6: PRUEBAS DE ENTIDADES (PARTY)
// =============================================================================
__mall_test_party_entity(runner);


// --- EJECUTAR TODAS LAS PRUEBAS ---
runner.run();
