/// @param lvl
function __group_class_stats(_lvl = 0) : __mall_class_parent("GROUP_STATS") constructor {
    // Copiar estadisticas del diccionario    
    lvl  = _lvl;
    
    base = {};
    stat = {};
    count = {};
    
    // Condiciones para subir de nivel
    lvl_init = undefined;   // function(self)
    lvl_end  = undefined;   // function(self)
    
    #region Metodos
	static Init = function() {
		var _names = mall_global_stats();
		
		var i = 0; repeat (array_length(_names) ) {
			var _name  = _names[i];
			var _start = (mall_get_stat(_name) ).start;
			
			variable_struct_set(base , _name, 0);
			variable_struct_set(stat , _name, (is_dataext(_start) ) ? Data(_start.num) : _start);
			variable_struct_set(count, _name, {c: 0, r: true} );
			
			++i;
		}
	}

    /// @param stat_name
    /// @param base_value
    static Set = function(_name, _val) {
        // Si existe la estadistica y no posee un valor base.
        if (mall_stat_exists(_name) ) { 
        	var _stat  = mall_get_stat(_name), _data;
        	var _range = _stat.GetRange();
        	
            if (is_dataext(_val) ) {
            	if (_val.num < _range[0] ) {_val.Set(_range[0]); }
            	if (_val.num > _range[1] ) {_val.Set(_range[1]); }
            } else {
            	if (_val < _range[0] ) {_val = _range[0]; }
            	if (_val > _range[1] ) {_val = _range[1]; }            	
            }
            
			// Establecer un valor
			variable_struct_set(stat, _name, _val);
        }
        
        return self;
    }

    /// @param stat_array
    static SetArray = function(_array) {
    	for (var i = 0, len = array_length(_array) - 1; i < len; i += 2) Set(_array[i], _array[i + 1] );	

        return self;
    }

    /// @param name
    /// @returns {bool}
    /// @desc Obtiene el valor del stat
    static Get = function(_name) {
    	return (variable_struct_get(stat, _name) ); 
    }
	
	/// @param name
	/// @returns {bool}
	static Exists = function(_name) {
		return (variable_struct_exists(stat, _name) );
	}
	
    /// @param stat_name
    /// @param base_value
    static SetBase  = function(_name, _base) {
    	if (mall_stat_exists(_name) && variable_struct_exists(base, _name) ) {
    		variable_struct_set(base, _name, _base);
    	}
        
        return self;
    }
    
    /// @param stat_array
    static SetBaseArray = function(_array) {
		for (var i = 0, len = array_length(_array) - 1; i < len; i += 2) SetBase(_array[i], _array[i + 1] );

        return self;        
    }    
    
    /// @param name
    static GetBase = function(_name) {
    	return (variable_struct_get(base, _name) ); 
    }
    
    /// @param level_init
    /// @param level_end
    static SetLevelFunctions = function(_init, _end) {
        SetLevelInit(_init);
        SetLevelEnd (_end);
        
        return self;
    }
        
    /// @param {function} level_init
    static SetLevelInit = function(_fun) {
        lvl_init = _fun;
        
        return self;
    }
    
    /// @param {function} level_end
    static SetLevelEnd  = function(_end) {
        lvl_end = _end;
        
        return self;
    }
    
    /// @param new_level
    /// @param force*
    static LevelUp = function(_lvl, _force = false) {
        if (!is_undefined(_lvl) ) lvl = _lvl;
        
        // Si no posee condiciones entonces
        if (is_undefined(lvl_init) || is_undefined(lvl_end) ) return self;
        
        var _names = mall_stat_get_names();
        
        // Si es forzado o cumple las condiciones que indica "lvl_init"
        if (_force || lvl_init(self) ) {
        	var i = 0; repeat (array_length(_names) ) {
        		var in = _names[i];

        		var _count = count[$ in]; 
        		var _stat  = mall_get_stat(in);

        		// Subir de nivel solo si es menor al nivel maximo de la estadistica
        		if (lvl < _stat.lvlmax) {
        			var _source = _stat.GetLvlUp(), _master = _stat.GetMaster();

        			var _min = _stat.tomin	  , _max   = _stat.tomax;
        			var _low = _stat.tomin_max, _upper = _stat.tomax_max;
        			
        			var _rep = _count.r;
			
        			if (!is_undefined(_master) ) { // Si posee maestro
        				#region Posee maestro
        				var _mname  = _master.GetName();
						
						if (_rep) {	// Solo hacerlo si es que puede repetir
	        				if (_min && !(_max) ) {
	        					if (_count.c >= _low) {
									Set(in, _stat.range_min); 
									_count.c = 0;
									
									if (!_stat.tomin_repeat) _count.r = false;
	        					}
	        				} else {
	        					if (_count.c >= _upper) {
	        						Set(in, Get(_mname) );
	        						_count.c = 0;
	        						
	        						if (!_stat.tomax_repeat) _count.r = false;
	        					}
	        				}
	        				// Aumentar cuenta si es que puede
	        				_count.c++;
						}
        				#endregion
        			} else if (!is_undefined(_source) ) {
        				if (_stat.tomin) {Set(in, _stat.range_min); } else		// Devolver al minimo 
        				if (_stat.tomax) {Set(in, _stat.range_max); } else	{	// Devolver al maximo
        					var _old = Get(in), _base = GetBase(in);
        				
        					Set(in, _source(_old, _base, lvl) );		
        				}
        			}
        		}
        		
        		++i;
        	}
        }
        
        // Ejecutar funcion para finalizar evento de subir de nivel
        lvl_end(self);
        
        return self;
    }
    
    #region Misq
    
    /// @returns {struct}
    /// @desc Convierte los stat en un string y los pasa en un struct
    static ToStringStruct = function() {
    	var _names = mall_global_stats(), _ret = {};
    	var _last = "";
    	
    	var i = 0; repeat(array_length(_names) ) {
    		var _name = _names[i], in, one, two, _str = "";
    		var _stat = mall_get_stat(_name); /// @is {__mall_class_stat}
    		
    		if (!_stat.ignore_txt) {
	    		var _len = _stat.GetChildrenCount();

	    		if (is_undefined(_stat.master) ) {
	    			var in = Get(_name);	// Obtener valor
	    			
	    			if (!is_array(in) ) {
			    		if (_len > 0) {
			    			#region Posee hijos
			    			var j = 0; repeat(_len) {
			    				var _childname  = _stat.GetChildren(j);
			    				var _childvalue = Get(_childname);
			    				
			    				_str += ( (is_data(_childvalue) ) ? _childvalue.str : string(_childvalue) ) + " / ";
			    				
			    				j++;	
			    			}
			    			
			    			_str += (is_data(in) ) ? in.str : string(in);
			    			_name = _childname;
			    			
		  					#endregion
			    		} else {	// Otras estadisticas
			    			_str = (is_data(in) ) ? in.str : string(in);
			    		}
	    			} else _str = in;
	    			
		    		// Agregar al struct
		    		var _structname = _stat.GetTxt();
		    		variable_struct_set(_ret, _structname, _str);
	    		}
    		}
    		
    		++i;
    	}
    	
    	return (_ret );
    }
    
    /// @returns {array}
    /// @desc Convierte los stat en un string y los pasa a un array
    static ToStringArray  = function() {
    	var _names = mall_global_stats(), _ret = [];
    	
    	var i = 0; repeat(array_length(_names) ) {
    		var _name = _names[i], in = stat[$ _name];
    		
    		array_push(_ret, (is_dataext(in) ) ? in.str : string(in) );
    		
    		++i;
    	}
    	
    	return (_ret );    	
    }
    
    #endregion
    
    #endregion
    
    Init();
}

function __group_class_equip(_defaults = true) : __mall_class_parent("GROUP_EQUIP") constructor {
    #region Interno
    static __ClassPart = function(_noitem, _deterstart = 0) constructor {
    	noitem = _noitem;	// Acceso rapido al noitem
    	
    	equipped = noitem; // Objeto equipado actualmente
    	previous = noitem; // Objeto anterior
    	
    	damage = _deterstart;  	// Daño de la parte. Al llegar al minimo de la parte global entonces no se podrá usar.
    	use  = true;	// Se se puede usar o no esta parte
    	
    	link	 = [];		// Links a otras partes
    	fromlink = false;	// Si es equipado por algun link
    	__link	 = {};		// Busqueda	
    	
    	capable = [];
    	
    	#region Metodos
    	static set = function(_value, _fromlink = false) {
    		previous = equipped;
    		equipped = _value;
    		
    		fromlink = _fromlink;
    	}
    	
    	static get = function() {
    		return (equipped);
    	}
    	#endregion
    }
    
    #endregion
    
    parts   = {};	// Diccionario de partes
	
    #region Metodos
    
    static Init = function() {
    	var _names = mall_part_get_names();
    	
    	var i = 0; repeat (array_length(_names) ) {
    		var _name = _names[i], _globalpart = (mall_get_part(_name) );
    		
    		var _noitem = _globalpart.GetNoItem() ;
    		var _damage = _globalpart.damage_start;

    		variable_struct_set(parts, _name, (new __ClassPart(_noitem, _damage) ) );
    		Link(_name); // Linkear así mismo
    		
    		++i;
    	}
    	
    	// Limpiar!
    	gc_collect();
    }
	
	/// @param {string} part_name
	/// @param value
	/// @param linked?
	static Set = function(_name, _value, _linked = false) {
		var _part = Get(_name);
		
		if (_value == undefined) _value = _part.noitem;
		
		if (mall_part_exists(_name) ) _part.set(_value, _linked);
		
		return self;
	}

	/// @param {string} part_name
	/// @returns {__ClassPart}
	static Get = function(_name) {
		return (variable_struct_get(parts, _name) );	
	}
	
	/// @param {string} part_name
	/// @returns {bool}
	static Exists = function(_name) {
		return (variable_struct_exists(parts, _name) );
	}
	
	static GetEquipped = function(_name) {
		return (Get(_name).equipped);
	}
	
	static GetPrevious = function(_name) {
		return (Get(_name).previous);	
	}
	
	/// @param part_name
	/// @param itemsubtypes
	/// @desc Selecciona que subtipos puede usar
	static SetCapable = function(_name, _array) {
		var _capable = GetCapable(_name);
		
		var i = 0; repeat(array_length(_array) ) {
			var in = _array[i];
			
			if (mall_itemtypes_exists_subtype(in) ) {
				array_push(_capable, in);
				
			} else {show_debug_message("MALL GROUP - CLASS EQUIP: NO EXISTE EL SUBTIPO"); }

			++i;
		}

		return self;
	}
	
	/// @param name
	static GetCapable = function(_name) {
		return (Get(_name).capable);
	}
	
	#region Misq
	
	/// @param part_name
	static UpdateDamage = function(_name) {	
		var _gpart = mall_get_part(_name);
		var _part  = Get(_name);
		
		if (_part.damage <= _gpart.damage_min) {
			_part.use	 = false;
			_part.damage = _gpart.damage_min;
		} else {
			_part.use = true;
		}
		
		return self;
	}
	
	/// @param part_name
	/// @desc Linkea otras partes con esta (0 mayor prioridad)
	static Link = function(_name) {
		static _1_linkcount = 0;
		
		var _part = Get(_name);
		var _link = _part.link, _search = _part.__link;
		
		if (!ExistsLink(_name) ) {
			array_push(_link, _name);
			variable_struct_set(_search, _name, _1_linkcount);
			
			_1_linkcount++;
		}
		
		return self;
	}
	
	/// @param part_name
	static ExistsLink = function(_name) {
		return (variable_struct_exists(Get(_name).__link, _name) );
	}
	
	/// @param part_name
	static GetLink = function(_name, _access) {
		var _part = Get(_name), _ret = _access;

		if (is_string(_access) ) _ret = _part.__link[$ _access]; 
		
		return (_part.link[_ret] );
	}
	
	static IsLinked = function(_name) {
		return (Get(_name).fromlink);
	}
	
	#endregion
	
	/// @param part_name
	/// @param subtype
	static IsCapable  = function(_name, _subtype) {
		var _capable = GetCapable(_name);
		
		var i = 0; repeat(array_length(_capable) ) {
			if (_capable[i] == _subtype) return true;
			
			++i;	
		}
		
		return false;
	}
	
	/// @param part_name
	static IsOccupied = function(_name) {
		var _part = Get(_name);
		
		return !(_part.equipped == _part.noitem);
	}
	
    #endregion
    
    Init();
}

function __group_class_control(_statsuniq = false, _stateuniq = true) : __mall_class_parent("GROUP_CONTROL") constructor {
	
	// Valores 
	stats = {};
	state = {};
		
    // Control
    control = {
    	state: {},
    	stats: {}
    };
    
    // Cantidades
    stats_uniq = _statsuniq;
    state_uniq = _stateuniq;
    
    #region Metodos
    static Init = function() {
    	#region Estadisticas
		var _mall	 = mall_global_stats(), _name, i = 0;
		var _control = control.stats;
		
		var inside = (stats_uniq) ? undefined : [];
			
		repeat(array_length(_mall) ) {
			_name = _mall[i];
			
			variable_struct_set(stats   , _name, mall_get_stat(_name).start);
			variable_struct_set(_control, _name, inside);	
			
			++i;
		}
		
		#endregion
		
		#region States
		_mall	 = mall_global_states();
		_control = control.state;
		i = 0;
		
		var inside = (state_uniq) ? undefined : [];
		
		repeat(array_length(_mall) ) {
			_name = _mall[i];
			
			variable_struct_set(state	, _name, mall_get_state(_name).init);
			variable_struct_set(_control, _name, inside);	
			
			++i;
		}
		
		#endregion
    }
    
    /// @param state_name
    static GetState = function(_name) {
    	return (variable_struct_get(state, _name) );
    }
	
	static SetState = function(_name, _value) {
		variable_struct_set(stats, _name, _value);
		
		return self;
	}
	
	#endregion
	 
    Init();
}

/// @param {string} 				name
/// @param {__group_class_stats}	stats
/// @param {__group_class_control}	control
/// @param {__group_class_equip}	equip
function group_create(_name, _stats, _control, _equip) : __mall_class_parent("GROUP_ID") constructor {
    #region Metodos
        #region Setter´s
    static SetName = function(_name, _desc) {
        name = _name;
        desc = _desc;
        
        return self;
    }
    
    static SetPortrait = function(_spr, _spr_index) {
        if (sprite_exists(_spr) ) {
            portrait = _spr;
            portrait_index = _spr_index;
        }
        
        return self;
    }
    
    #endregion
    
        #region Getter´s
    /// @returns {array}
    static GetName = function() {
        return [name, desc];
    }
    
    /// @returns {sprite}
    static GetPortrait = function() {
        return portrait;
    }
    
    static GetState = function() {
        return state_text;
    }
    
    /// @returns {__group_class_stats}
    static GetStats = function() {
        return stats;
    }
    
    /// @returns {__group_class_control}
    static GetState = function() {
        return state;
    }
    
    /// @returns {__group_class_equip}
    static GetEquip = function() {
        return equip;
    }
    
    /// @returns {__tree_class}
    static GetCommands = function() {
        return comands;
    }
    
    #endregion
    
        #region Comandos
    static AddCommand = function(_command_name, _dark_key) {
        comands.add(_command_name, _dark_key);
        
        return self;
    }
    
    #endregion
        
        #region Equipamiento
    /// @param part_name
    /// @param item_key
    static EquipPut  = function(_name, _key) {
        var _item = bag_item_get(_key), _subtype = _item.subtype;
        
        var _gpart = mall_get_part(_name);
        var _part  = equip.Get(_name);
		var _link  = _part.link;
		
		// Si el objeto necesita muchas partes para usarse
		if (array_length(_link) + 1 <= _item.use) return false;
		
		// 0 es siempre el.
		var i = 0; repeat(_item.use) {
			var _linked = _link[i];
			
			// Comprobar si es posible
			if (equip.IsCapable(_linked, _subtype) ) {
				if (equip.IsOccupied(_linked) ) EquipTake(_linked);

				// Si el objeto no fue equipado por los links regresar el objeto al almacenamiento
				if (!equip.IsLinked(_linked) ) bag_storage_add(_key, -1);
				
				equip.Set(_linked, _key, !(i == 0) );
			}
			
			++i;
		}
		
		EquipGetUpgrade(_name); // Obtener los buffos
		
		return true;	
    }    
    
    /// @param part_name
    static EquipTake = function(_name) {
		// Si no posee objeto salir
		if (!equip.IsOccupied(_name) ) return false;

		var _key  = equip.GetEquipped(_name);

		// Desequipar
		equip.Set(_name);

		// Recuperar el objeto
		if (!equip.IsLinked(_name) ) {
			bag_storage_add(_key, 1);
			EquipGetUpgrade(_name); // Obtener los buffos
		}
		
		return true;    
    }
    
    /// @param part_name
    /// @desc Obtiene las mejoras de un slot en especifico
    static EquipGetUpgrade  = function(_slot) {
        if (!equip.Exists(_slot) ) return self; // Si no existe la parte entonces salir.
         
        var _mallpart = mall_get_part(_slot), _part = equip.Get(_slot);

		var _to = stats;	// referencia
		var _stat, _item, _subtype = ".", bonus = 0;
		
		#region Objetos
		if (_part.equipped != _part.noitem) {
			#region Hay objeto
			_item	 = (bag_item_get(_part.equipped) );
			_subtype = _item.subtype;
			
			// Bonus al equipar cierto tipo de objeto
			if (_mallpart.ExistsProperty(_subtype) ) bonus = _mallpart.GetProperty(_subtype);
			
			_stat = _item.GetStats();

			#endregion
		} else if (_part.previous != _part.noitem) {
			#region Hubo un objeto antes
			_item    = (bag_item_get(_part.previous) );
			_subtype = _item.subtype;
			
			// Bonus al equipar cierto tipo de objeto
			if (_mallpart.ExistsProperty(_subtype) ) bonus = _mallpart.GetProperty(_subtype);			
			
			_to   = stats_final;
			_stat = _item.GetStats().Turn("stat");
			
			#endregion
		} else {
			#region No hay de donde sacar estadisticas así que se crea una nueva!
			_stat = (new __group_class_stats() );
			
			#endregion
		}
		
		#endregion
		
		var _statnames = mall_global_stats();
    
        var i = 0; repeat(array_length(_statnames) ) {
            var _name = _statnames[i];
            
            if (_to.Exists(_name) && _stat.Exists(_name) ) {
            	var old  = _to.Get(_name), item = _stat.Get(_name);
				
            	if (is_data(item) ) item = item.num;
            	
            	item += (is_dataext(bonus) ) ? (bonus.num * item) / 100 : bonus;
				
				if (is_dataext(old) ) {
					stats_final.Set(_name, old.Operate(item) );
				} else {
					stats_final.Set(_name, round(old + item) ); 
				}
            }
			
            ++i;
        }

    	gc_collect();
    	
        return self;
    }
    
    /// @desc Obtiene las mejoras del equipamiento
    static EquipGetUpgrades = function() {
    	var _names = mall_part_get_names(), i = 0;
    	repeat (array_length(_names) ) {
    		EquipGetUpgrade(_names[i] );
    	
    		++i;
    	}

        return self;
    }
    
    /// @desc Obtiene las estadisticas que posee sin el objeto equipado
    static EquipGetDifference  = function(_slot) {
		var _ret  = (new __group_class_stats() ); /// @is {__group_class_stats}
        
        // Si no posee objetos salir
        if (!equip.IsOccupied(_slot) ) return (_ret);

        var _key  = equip.Get(_slot);
        var _part = mall_get_part(_slot);	// Obtener parte
        var _item = bag_item_get(_key);		// Obtener objeto
        
        var _subt = _item.GetSubtype();
        var bonus = (_part.ExistsProperty(_subt) ) ? _part.GetProperty(_subt) : 0;	// Obtener bonus!
		
		var _stat = _item.GetStats();	// Obtener estadisticas del objeto
		
        var _names = mall_global_stats(); 
        
        var i = 0; repeat(array_length(_names) ) {
            var _name = _names[i];
			var in  = _ret.Get(_name); 
			var one = stats_final.Get(_name), two = _stat.Get(_name);
			
			if (is_data(one) ) one = one.num;
			if (is_data(two) ) two = two.num;
			
			two += (is_dataext(bonus) ) ? (bonus.num * two) / 100 : bonus;
			
			_ret.Set(_name, one - two);
        }
        
        return _ret;
    }
    
    /// @desc Comprueba si un objeto mantiene, aumenta o baja las caracteristicas
    static EquipGetComparacion = function(_slot, _key, _form) {
		if (_form == undefined) _form = function(in, name, i) {
			if (in > 0) {return ["+" + in, c_green]; } else 
			if (in < 0) {return ["-" +in, c_red  ]; } else 
			
			return ["=" + in, c_white];
		}
		
		var _ret = (new __group_class_stats() ); /// @is {__group_class_stats}
		
		var part = mall_get_part(_slot);
		var prop = part.ExistsProperty;
		
		var item1 , item2 ;
		var stat1 , stat2 ;
		var bonus1 = 0, bonus2 = 0;
		
		var val1, val2, org;
		
		if (equip.IsOccupied(_slot) ) {
			item1 = bag_item_get(equip.Get(_slot) ); 
			stat1 = item1.GetStats();
			
			if (prop(item1.subtype) ) bonus1 = part.GetProperty(item1.subtype);			

		} else stat1 = (new __group_class_stats() );
		
		// Objeto a comparar
		item2 = bag_item_get(_key);
		stat2 = item2.GetStats();
		
		if (prop(item2.subtype) ) bonus2 = part.GetProperty(item2.subtype);
	
        var _names = mall_global_stats();
        
        var i = 0; repeat(array_length(_names) ) {
        	_name = _names[i];
        	
        	org = _ret.Get(_name);
        	
        	val1 = stat1.Get(_name);
        	val2 = stat2.Get(_name);
        	
			if (is_data(val1) ) val1 = val1.num;
			if (is_data(val2) ) val2 = val2.num;

			val1 += (is_dataext(bonus1) ) ? (bonus1.num * val1) / 100 : bonus1;
			val2 += (is_dataext(bonus2) ) ? (bonus2.num * val2) / 100 : bonus2;
			 
			if (val1 == 0) val2 *= -1;			 
			
			_ret.Set(_name, _form(val1 - val2) );	
        }
        
        return _ret;
    }
    
    #endregion
    
        #region Stats
    
    /// @param stat_name
    /// @param restore
    /// @desc Recupera una estadistica sin pasarse de un limite. funciona para quienes tengan un sub_stat (hpmax / hp)
    static StatRestore = function(_name, _val)	{
		var _master = (mall_get_stat(_name) ).GetMaster(), _restore;
		var _stat   = stats_final.Get(_name);

		_restore = StatAffect(_name, (is_dataext(_val) ) ? (_val.num * _stat) + _stat : _val);
		
		if (is_undefined(_master[0] ) ) { //  Si posee maestro
			var _mstat = stats_final.Get(_master[1] );	// Obtener estadistica maestra.
			
			if (_restore > _mstat) _restore = _mstat;
		}
		
		// Si un estado afecta a esta estadistica.
		stats_final.Set(_name, _stat + _restore);

		return _restore;     
    }
    
    /// @param stat_name
    /// @param pass_value
    /// @desc Pasa un valor de un estado y revisa que estados activos lo afectan. Dando el resultado nuevo al final
    static StatAffect  = function(_name, _val)	{
		var _watch = (mall_get_stat(_name) ).GetWatch(), _watchnames = variable_struct_get_names(_watch);

		var i = 0; repeat(array_length(_watchnames) ) {
			var _watchname = _watchnames[i];
			
			if (control.GetState(_watchname) ) {
				var in = _watch[$ _watchname];
				
				_val += (is_data(in) ) ? (in.num * _val) + _val : _val;
			} 
			
			++i;
		}
		
		return _val;
    }
    
    /// @param stat_name
    /// @param use
    /// @desc Utiliza una estadistica
    static StatUse = function(_name, _val)	{
		var _master = (mall_get_stat(_name) ).GetMaster(), _use;
		var _stat	= stats_final.Get(_name);
    	
    	_use = StatAffect(_name, (is_dataext(_val) ) ? (_val.num + _stat) + _stat : _val);
    	
		// Si un estado afecta a esta estadistica.
		stats_final.Set(_name, _stat - _use);

		return _use;    	
    }

    /// @param {number} lvl*
    /// @desc Aumenta el nivel 1 en 1
    static LevelUp = function(_lvl = 1)	{
    	_lvl += stats.lvl;
    	
    	stats.LevelUp(_lvl);
    	
    	return self;
    }
        
    #endregion

		#region Batallas
	
	/// @param target
	/// @param dark_key
	/// @param base_damage
	/// @param use_slot
	static BattleTarget = function(_target, _dark_key, _base = 90, _slot = "Mano der.") {
		var _dark = dark_get(_dark_key).spell;
		
		return ( _dark(self, _target, {base: _base, slot: _slot} ) );
	}
		#endregion
		
	#endregion

    name = _name;
    desc = "";
    
    portrait = -1;
    portrait_index = 0;
    
    state_text = "";
    
    stats		= _stats; 									/// @is {__group_class_stats}
    stats_final = (new __group_class_stats(_stats.lvl) );	/// @is {__group_class_stats}

	control = _control;	/// @is {__group_class_control}
    equip   = _equip; 	/// @is {__group_class_equip}
    
    comands = tree_create();    /// @is {__tree_class}
    tree_add(comands, "Pasive");
    
    EquipGetUpgrades();
}




