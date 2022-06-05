/// @param {Array} array/// @desc Intercambia los valores en el array de forma aleatoria
function array_shuffle(_array) {
	var _len  = array_length(_array);
	var _seed = random_get_seed();	
	randomize();
	
	repeat (_len) {
		array_swap(_array, irandom(_len), irandom(_len - 1) ); 
	}
	
	random_set_seed(_seed);
}

