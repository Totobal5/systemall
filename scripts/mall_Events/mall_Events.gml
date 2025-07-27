/// @desc Contenedor base para componentes que usan eventos.
/// @param {String} key
function MallEvents(_key) : Mall(_key) constructor
{
    // --- Llaves de Eventos ---
    // Estas variables guardan el NOMBRE de la función, no la función en sí.
    // La función real se buscará en Systemall.__functions.
    
    // Ciclo de vida del componente
    event_on_start = "";
    event_on_end = "";
    event_on_update = "";
    
    // Eventos de Turno
    event_on_turn_update = "";
    event_on_turn_start = "";
    event_on_turn_end = "";
    
    // Eventos de Equipamiento
    event_on_equip = "";
    event_on_desequip = "";
}