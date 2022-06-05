/// @param {String} _key
/// @return {Struct.DarkEffect}
function DarkEffect(_key) : MallComponent(_key) constructor {
    id = "DE000"; // ID unica del efecto
    
    __init  = numtype(false, NUMTYPE.BOOLEAN); // Valor que coloca al inicio   
    __value = numtype(	  0, NUMTYPE.REAL);	// Valor que aumenta con cada update
	
    /* Ejemplo: 
        Veneno: start [true, MN.B, 0]
                value [15, MB.P, 0] 
    */
    
    __turns = new Counter(0, 0);
}