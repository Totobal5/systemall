// Feather disable GM2043

/// @desc Elemento basico de Mall
/// @param {String} componentKey
function Mall(_key="") constructor 
{
	/// @ignore
	is = instanceof(self);
	
	key   = _key;   // Llave con el cual se guardo en la base de datos
	index =   -1;   // Indice en donde esta (si esta en algun array)

	/// @desc Devuelve la llave del componente
	/// @return {String}
	static getKey = function()
	{
		return (key);
	}

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
	
		/// @desc -1 se ha desactivado, 0 aun no llega al limite de cuenta, 1 esta iterando para reiniciar, 2 se ha reiniciado
		/// @returns {real} Description
		static iterate = function()
		{
			// Si ya se cumplio el ciclo
			if (!active) return -1;
		
			count = count + 1;
			if (count > countLimits)
			{
				return 0;
			}
			else
			{
				return (restart() );
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
	}

	// -- Utils
	static toStringNumtype = function()
	{
		
	}
	
	static __dummy = function() {}
}


/// @desc Crea componente de Mall (sistema RPG)
/// @param {String} component_key
/// @param {Bool} [use_iterator]
/// @return {Struct.MallComponent}
function MallComponent(_key="", _iterator=false) : Mall(_key) constructor 
{
	// Llave para usar en display
	displayKey = "";

	from = weak_ref_create(self);   // Referencia a otra estructura
	from = undefined;               // Eliminar referencia (feather)
	flags = {};                     // Propiedades unicas del componente
	
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
	
	
	/// @param {String}	flag_key
	/// @param {Any}	flag_value
	/// @return {Struct.MallComponent}	
	static setFlag = function(_KEY, _VALUE)
	{
		flags[$ _KEY] = _VALUE;
		return self;
	}
	
	
	/// @param {String}	flag_key
	static getFlag = function(_KEY)
	{
		return (flags[$ _KEY] );
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