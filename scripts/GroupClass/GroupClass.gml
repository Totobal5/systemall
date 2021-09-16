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
	    		var _len = array_length(_stat.children);

	    		if (is_undefined(_stat.master) ) {
	    			var in = Get(_name);	// Obtener valor
	    			
		    		if (_len > 0) { // Si posee hijos
		    			var j = 0; repeat(_len) {
		    				var _childname  = _stat.children[j], _childvalue = Get(_childname);
		    				
		    				_str += string(_childvalue) + " / ";
		    				
		    				j++;	
		    			}
		    			
		    			_str += string(in);
		    			_name = _childname;
	  			
		    		} else {	// Otras estadisticas
		    			_str = (is_data(in) ) ? in.str : string(in);
		    		}
		    		
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

function __group_class_elements() : __mall_class_parent("GROUP_ELEMENTS") constructor {
	elem = {};

	#region Metodos
	static Init = function() {
		var _names = mall_global_elements();
		
		var j = 0; repeat (array_length(_names) ) {
			var _name = _names[i];
			var _sub  = mall_element_get_sub(_name);
			
			var i = 0; repeat(array_length(_sub) ) {
				var two = _sub[i];

				variable_struct_set(elem, _name + two, 0);
				variable_struct_set(base, _name + two, 0);
				
				++i;
			}
			
			j++;
		}
	}
	
	/// @param element_name
	/// @param value
	static Set = function(_name, _val) {
		if (mall_element_exists(_name) ) variable_struct_set(elem, _name, _val);	

		return self;
	}
	
	/// @param element_name
	static Get = function(_name) {
		return (variable_struct_get(elem, _name) );
	}
	
	/// @param element_name
	/// @returns {bool}
	static Exists = function(_name) {
		return (variable_struct_exists(elem, _name) );
	}

	#endregion
	
	Init();
}

function __group_class_resistances() : __mall_class_parent("GROUP_RESISTANCES") constructor {
	rest = {};

	#region Metodos
	static Init = function() {
		var _names = mall_global_states();

		repeat (each(_names) ) {
			var in = this.value;
			
			variable_struct_set(rest, in, 0);
			variable_struct_set(base, in, 0);
		}		
	}
	
	/// @param state_name
	/// @param value
	static Set = function(_name, _val) {
		if (mall_state_exists(_name) ) {
			variable_struct_set(rest, _name, _val);	
		}
		
		return self;
	}
	
	/// @param state_name
	static Get = function(_name) {
		return (variable_struct_get(rest, _name) );
	}
	
	/// @param state_name
	/// @returns {bool}
	static Exists = function(_name) {
		return (variable_struct_exists(rest, _name) );
	}

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

function __group_class_control(_stateuniq = true, _statuniq = true,  _restuniq = true, _elemuniq = true) : __mall_class_parent("GROUP_CONTROL") constructor {
    state = {};	// Que valor posee un estado (generalmente booleano)
    
    stat = {}; // Bonus o sanción en las estadisticas
    elem = {}; // Bonus o sanción en los elementos  
    rest = {}; // Bonus o sanción en las resistencias    
    
    // Copiar estadisticas
    stats = {}
    
    // Control
    control = {state: {}, elem: {}, stat: {}, rest: {} };
    
    // Si puede haber 1 o más
    control_stateuniq = _stateuniq;
    
    control_statuniq = _statuniq; 
    control_restuniq = _restuniq;
    control_elemuniq = _elemuniq;
    
    __control = [];
    __control_count = 0;
    
    #region Metodos
    
    static Init = function() {
    	var _cstate = control.state;
		var _cstat = control.stat, _celem = control.elem, _crest = control.rest;

    	#region State and Resistances
    	var _names = mall_global_states();	// Obtiene todos los estados
    	
    	var i = 0; repeat(array_length(_names) ) {
    		var _name = _names[i];
    		
    		// States
    		if (!variable_struct_exists(state, _name) ) {
    			var _state = mall_get_state(_name);	// Obtener propiedades del estado 
    			
    			variable_struct_set(state  , _name, _state.init);
    			variable_struct_set(_cstate, _name, (control_stateuniq) ? noone : [] );
    		
    			variable_struct_set(rest  , _name, 1);
    			variable_struct_set(_crest, _name,  (control_stateuniq) ? noone : [] );
    		}
    		
    		++i;
    	}

    	#endregion
    	
    	#region Stat
    	var _names = mall_global_stats();
    	
    	var i = 0; repeat (array_length(_names) ) {
    		var _name = _names[i];
    		
    		if (!variable_struct_exists(stat, _name) ) {
    			variable_struct_set(stat  , _name, 1);
    			variable_struct_set(_cstat, _name, (control_statuniq) ?  noone : [] );	
    		}
    		
    		++i;
    	}    	
    	#endregion
 
   		#region Element
    	var _names = mall_global_elements();
    	
    	var i = 0; repeat (array_length(_names) ) {
    		var _name = _names[i];
    		
    		if (!variable_struct_exists(elem, _name) ) {
    			variable_struct_set(elem  , _name, 1);
    			variable_struct_set(_celem, _name, (control_elemuniq) ?  noone : [] );	
    		}
    		
    		++i;
    	}    
    	#endregion
    }
    
    	#region Resistencia
    /// @param resistance_name
    /// @param value
    static SetRest = function(_name, _value) {
    	if (mall_stat_exists(_name) ) variable_struct_set(rest, _name, _value);
    	
    	return self;
    }
    
    /// @param resistance_name
    static GetRest = function(_name) {
		return (variable_struct_get(rest, _name) );    	
    }
    
    /// @param resistance_name
    /// @returns {bool}
    static ExistsRest = function(_name) {
    	return (variable_struct_exists(rest, _name) );
    }
    
    #endregion
    
    	#region Elements
    /// @param element_name
    /// @param value
    static SetElemn = function(_name, _value) {
    	if (mall_element_exists(_name) )  variable_struct_set(elem, _name, _value);
		   
    	return self;
    }
    
    /// @param element_name
    static GetElemn = function(_name) {
		return (variable_struct_get(elem, _name) ); 	
    }
    
    /// @param element_name
    /// @returns {bool}
    static ExistsElemn = function(_name) {
    	return (variable_struct_exists(elem, _name) );
    }
    
    #endregion
    
    static SetState = function(_ste_name) {
        return self;
    }
    
    static GetState = function(_ste_name) {
        return state[$ _ste_name];
    }
    
    /// @param control_name
    static GetControl = function(_cont_name) {    
        return (control[$ _cont_name] );
    }
    
    /// @param dark_id
    static AddController = function(_dark_id) {
        var _afects = _dark_id;
        
        return self;
    }
    
    static Update = function() {
        
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
        var _sts   = (new __group_class_stats() ); /// @is {__group_class_stats}
        var _names = mall_states_get_names(); 
        
        var i = 0; repeat(array_length(_names) ) {
            var _name = _names[i];
            
            var _o1 = stats      .GetStat(_name);
            var _o2 = stats_final.GetStat(_name);
            
            _sts.SetStat(_name, _o2 - _o1);
            
            ++i;
        }
        
        return _sts;
    }
    
    /// @desc Comprueba si un objeto mantiene, aumenta o baja las caracteristicas
    static EquipGetComparacion = function(_slot, _key, _stsreturn, _resreturn, _elmreturn) {
        #region Comparacion default
        
        if (_stsreturn == undefined) _stsreturn = function(v1, v2) {
            var _inter = (!is_undefined(v2) ) ? string(v2 - v1) : v1;   
            
            if (_inter == 0) {return [""  + _inter, c_white]; } else
            if (_inter <  0) {return ["-" + _inter, c_red  ]; } else 
            if (_inter >  0) {return ["+" + _inter, c_green]; }
        }
        
        if (_resreturn == undefined) _resreturn = function(v1, v2) {
            var _inter = (!is_undefined(v2) ) ? string(v2 - v1) : v1;   
            
            if (_inter == 0) {return [""  + _inter, c_white]; } else
            if (_inter <  0) {return ["-" + _inter, c_red  ]; } else 
            if (_inter >  0) {return ["+" + _inter, c_green]; }                
        }
        
        if (_elmreturn == undefined) _elmreturn = function(v1, v2) {
            var _inter = (!is_undefined(v2) ) ? string(v2 - v1) : v1;   
            
            if (_inter == 0) {return [""  + _inter, c_white]; } else
            if (_inter <  0) {return ["-" + _inter, c_red  ]; } else 
            if (_inter >  0) {return ["+" + _inter, c_green]; }                
        }
        
        #endregion
        
        var i = 0;
        
        var _sts = (new __group_class_stats() );
        var _res = (new __group_class_resistances() );
        var _elm = (new __group_class_elements() );
        
        var _sts_names = mall_slots_get_names (), _res_names = mall_states_get_names(), _elm_names = mall_elements_get_names();
        
        var _item = bag_item_get(_key); /// @is {__bag_class_item}
        var _ists = _item.GetStats(), _ielm = _item.GetElements(), _ires = _item.GetResistances();
        
        if (equip.IsOcuppied(_slot) ) {
            #region Si esta ocupado
            var _oitem = bag_item_get(equip.GetSlot(_slot) );
            
            var _osts  = _oitem.GetStats();
            i = 0; repeat(array_length(_sts_names) ) {
                var _name = _sts_names[i];
                var in = _ists.GetStat(_name), out = _osts.GetStat(_name);
                
                _sts.SetStat(_name, _stsreturn(in, out) );
                
                ++i;
            }
            
            var _oelm = _oitem.GetElements();
            i = 0; repeat(array_length(_res_names) ) {
                var _name = _res_names[i];
                var in = _ists.GetRes(_name), out = _osts.GetRes(_name);
                
                _res.SetRes(_name, _resreturn(in, out) );
                
                ++i;
            }
            
            var _ores = _oitem.GetResistances();
            i = 0; repeat(array_length(_elm_names) ) {
                var _name = _elm_names[i];
                var in = _ists.GetElement(_name), out = _osts.GetElement(_name);
                
                _elm.SetElement(_name, _elmreturn(in, out) );
                
                ++i;
            }

            #endregion
        } else {
            #region Si no esta ocupado
            i = 0; repeat(array_length(_sts_names) ) {
                var _name = _sts_names[i], in = _ists.GetStat(_name);
                
                _sts.SetStat(_name, _stsreturn(in) );
                
                ++i;
            }
            
            i = 0; repeat(array_length(_res_names) ) {
                var _name = _res_names[i], in = _ists.GetRes(_name);

                _res.SetRes(_name, _resreturn(in) );
                
                ++i;
            }
            
            i = 0; repeat(array_length(_elm_names) ) {
                var _name = _elm_names[i], in = _ists.GetElement(_name);
                
                _elm.SetElement(_name, _elmreturn(in) );
                
                ++i;
            }
            
            #endregion
        }
        
        return [_sts, _res, _elm];
    }
    
    #endregion
    
        #region Stats
    
    /// @desc Recupera una estadistica sin pasarse de un limite. funciona para quienes tengan un sub_stat (hpmax / hp)
    static StatsRestore = function(_statname, _restore, _mode = true) {
        if (!_condition(__context) ) return false;

        _restore = StatAffect(_statname, _restore);
        
        var o = (_mode) ? _restore : (stats_final.GetStat(_statname) * _restore / 100);        
        var f = stats_final.GetStat(_statname) + o;
        
        stats_final.SetStat(_statname, f);
        
		return f;        
    }
    
    /// @desc Utiliza una estadistica
    static StatsUse = function(_statname, _use, _condition, _mode = true, _all = false) {
        
        if (!_condition(__context) ) return false;
        
        // Buscar si posee un estado que aumente el consumo
        _use  = StatAffect(_statname, _use);
        
        var o = (_mode) ? _use : (_use * stats_final.GetStat(_statname) / 100);
        var f = stats_final.GetStat(_statname) - o;
        
        if (!_all) f = max(1, f);
        
		stats_final.SetStat(_statname, f);

		return f;       
    }
    
    /// @desc Pasa un valor de un estado y revisa que estados activos lo afectan. Dando el resultado nuevo al final
    static StatAffect = function(_statname, _value) {
        var _deb = mall_states_get_affect_stat(_statname);
        
        var i = 0; repeat(array_length(_deb) ) {
            var _ste_name = _deb[i];
            
            // Solo si es afectado por este estado
            if (state.GetState(_ste_name) ) {
                var _mall = mall_states_get(_ste_name);
                
                    
                _value = _mall.form(_value, _mall.val);    
            }
            
            i++;
        } 
        
        return _value;
    }
    
    /// @param lvl*
    /// @desc Aumenta el nivel 1 en 1
    static LevelUp = function(_lvl = 1) {
    	_lvl += stats.lvl;
    	
    	stats.LevelUp(_lvl);
    	
    	return self;
    }
        
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




