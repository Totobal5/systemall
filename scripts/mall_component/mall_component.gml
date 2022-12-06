// Feather disable GM2043

/// @desc Elemento basico de Mall
/// @param {String} componentKey
function Mall(_key="") constructor 
{
	/// @ignore
	is = instanceof(self);
	
	key   = _key;   // Llave con el cual se guardo en la base de datos
	index =   -1;   // Indice en donde esta (si esta en algun array)
	vars  =   {};

	/// @param {String}	varKey  Llave de la variable a crear
	/// @param {Any*}	value   Valor
	/// @return {Struct.MallComponent}	
	static setVar = function(_key, _value)
	{
		vars[$ _key] = _value;
		return self;
	}
	
	
	/// @param {String}	varkey  Llave de la variable
	static getVar = function(_key)
	{
		return (flags[$ _key] );
	}

	/// @desc Devuelve la llave del componente
	/// @return {String}
	static getKey = function()
	{
		return (key);
	}
	
	/// @desc Como guardar este componente
	static save = function()
	{
		var _this = self;
		return ({
			version:  MALL_VERSION,
			is :      _this.is,
			key:      _this.key,
			index:    _this.index
		});
	}

	/// @desc Como cargar este componente
	static load = function(_l)
	{
		if (_l.is != is) exit;
		switch (MALL_VERSION) {
			default:
				is    =    _l.is;
				key   =   _l.key;
				index = _l.index;
			break;
		}
	}
	
	/// @desc Crea un iterador
	static iteratorCreate  = function() constructor 
	{
		is = "MallIterator";
		active = false;
		type   =  true;	// true: toMin, false: toMax
		
		// Cuenta
		count = 0;
		countLimits = 1;
	
		// Resets
		reset = false;	 // Si tiene un reset o no
		resetCount  = 0; // Veces que se ha reseteado
		resetLimits = 1; // Limite de resets
	
		resetNumber =  0;
		resetMax	= -1;
		firtCall = false; // Se ha llamado 1 vez
		
		/// @desc -1 se ha desactivado, 0 aun no llega al limite de cuenta, 1 esta iterando para reiniciar, 2 se ha reiniciado
		/// @returns {real} Description
		static iterate = function()
		{
			// Si ya se cumplio el ciclo
			if (!active) {
				count = count + 1;
				if (count > countLimits)
				{
					return 0;
				}
				else
				{
					return (restart() );
				}
			} else {
				return -1;
			}
		}	
	
	
		/// @desc Reinicia el iterador si puede, si no lo desactiva
		/// @returns {Real} Description
		static restart = function()
		{
			#region Se el iterador reinicia
			if (reset)
			{	
				#region Cuenta para el reinicio
				if (resetCount < resetLimits) 
				{
					resetCount = resetCount + 1;
					return 1;
				}
				else
				{
					count  = 0;
					resetCount = 0;
					// Reinicio infinito
					if (resetMax == -1) return 2;
					// Veces que puede reiniciar
					if (resetNumber > resetMax) 
					{
						active = false; 
					} 
					else 
					{
						resetNumber = resetNumber + 1; 
					}

					return 2;
				}
				#endregion
			}
			#endregion
		
			active = false;
			count  = 0;
			return -1;
		}
	
	
		/// @desc Devuelve si es toMin (true) o toMax (false)
		/// @returns {bool} Description
		static getType = function()
		{
			return (type);
		}
	
	
		/// @desc Devuelve si esta activo
		/// @returns {bool} Description
		static isActive = function()
		{
			return (active);
		}
		
		
		/// @desc Guardar iterador
		static save = function() 
		{
			var _this = self;
			return ({
				version: MALL_VERSION,
				is: _this.is,
				active:     _this.active,
				type  :     _this.type  ,
				count :     _this.count ,
				countLimit: _this.countLimit,
				
				reset: _this.reset,
				resetCount : _this.resetCount ,
				resetLimits: _this.resetLimits,
	
				resetNumber: _this.resetNumber,
				resetMax   : _this.resetMax   ,
			});
		}
		
		/// @desc Cargar iterador
		/// @param {Struct} loadStruct
		static load = function(_l)
		{
			// Asegurarse de que sean el mismo
			if (_l.is != is) exit;
			var _names = variable_struct_get_names(_l);
			var i=0; repeat(array_length(_names) )
			{
				var _key =  _names[i];
				if (_key != "version") {
					var _val = _l[$ _key];
					// Copiar valores
					if (!is_method(_val) ) self[$ _key] = _val;
				}
				
				i = i + 1;
			}
		}
	}

	// -- Utils
	
	/// @desc Pasar numtype a string
	/// @param {Enum.MALL_NUMTYPE} numtype
	static toStringNumtype = function(_num)
	{
		switch (_num) {
			case MALL_NUMTYPE.REAL:     return "+-";      break;
			case MALL_NUMTYPE.PERCENT:  return "%";   break;
		}
	}
	
	/// @desc Para no crear demasiadas funciones
	/// @ignore
	static __dummy = function() {}
}


/// @desc Crea componente de Mall (sistema RPG)
/// @param {String} componentKey
/// @param {Bool} [use_iterator]
/// @return {Struct.MallComponent}
function MallComponent(_key="", _iterator=false) : Mall(_key) constructor 
{
	// Llave para usar en display
	displayKey = "";

	from = weak_ref_create(self);   // Referencia a otra estructura
	from = undefined;               // Eliminar referencia (feather)
	iterator = (_iterator) ? new iteratorCreate() : undefined;

	#region METHODS
	
	/// @desc Hereda ciertas propiedades de otro MallComponent
	/// @param {String} component_key Description
	/// @return {Struct.MallComponent}
	static inherit = function(_MALL)
	{
		return (self);
	}
	
	
	/// @param {Struct.MallComponent} reference
	/// @return {Struct.MallComponent}
	static setFrom = function(_ENTITY)
	{
		from = weak_ref_create(_ENTITY);
		return self;
	}
	
	
	/// @desc Devuelve la referencia
	static getFrom = function()
	{
		return (from.ref);
	}
	
	
	/// @desc Establece la llave propia
	/// @param {String} self_key
	/// @param {String} [display_key]
	/// @return {Struct.MallComponent}	
	static setKey = function(_key, _display)
	{
		key = _key ?? key;
		displayKey = _display ?? displayKey;
		return self;
	}


	/// @param {String} display_key
	/// @return {Struct.MallComponent}	
	static setDisplayKey = function(_key)
	{
		displayKey = _key;
		return self;
	}
	
	
	/// @desc Regresa el texto de display
	/// @return {String}
	static getDisplayKey = function()
	{
		return (displayKey);
	}
	
	// -- ITERATOR
	
	/// @param {Bool} iterator_type
	static iterActivate = function(_type)
	{
		iterator.active =  true;
		iterator.type   = _type;
		return (self);
	}
	
	
	static iterSet = function(_countMax=1, _repeat=true, _repeatsMax=-1)
	{
		iterator.iterator = true;
		iterator.count = 0;
		iterator.countLimits = _countMax;
		
		iterator.reset = _repeat;
		iterator.resetCount  = 0;
		iterator.resetLimits = _repeatsMax;
	}
	
	
	static iterSetMin = function(_countMax=1, _repeat=true, _repeatsMax=-1)
	{
		iterSet(_countMax, _repeat, _repeatsMax);
		iterator.type = false;
	}


	static iterSetMax = function(_countMax=1, _repeat=true, _repeatsMax=-1)
	{
		iterSet(_countMax, _repeat, _repeatsMax);
		iterator.type = true;
	}
	
	#endregion
}