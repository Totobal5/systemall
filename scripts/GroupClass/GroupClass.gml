/// @param lvl
function __group_class_stats(_lvl) : __mall_class_parent("GROUP_STATS") constructor {
    // Copiar estadisticas del diccionario    
    lvl  = _lvl;
    
    bases = {};
    stats = {};
    count = {};
    
    // Condiciones para subir de nivel
    lvl_init = undefined;   // function(self)
    lvl_end  = undefined;   // function(self)
    
    #region Metodos
	static Init = function() {
		var _names = mall_global_stats();
		
		repeat (each(_names) ) {
			var in = this.value;
			
			variable_struct_set(bases, in, 0);
			variable_struct_set(stats, in, 0);
			variable_struct_set(count, in, {c: 0, r: true} );
		}
	}

    /// @param stat_name
    /// @param base_value
    static Set = function(_name, _val) {
        // Si existe la estadistica y no posee un valor base.
        if (mall_stat_exists(_name) ) { 
            // Comprobar que no sea un substat
            var _stat  = mall_get_stat(_name); /// @is {__mall_class_stat}
            var _range = _stat.GetRange();
			
			if (_val < _range[0]) {_val = _range[0]; }
			if (_val > _range[1]) {_val = _range[1]; }
			
			// Establecer un valor
			variable_struct_set(stats, _name, _val);
        }
        
        return self;
    }

    /// @param stat_array
    static SetArray = function(_array) {
        var i = 0; repeat(array_length(_array) ) {
            Set(_array[i], _array[i + 1] );
            ++i;
        }
        
        return self;
    }

    /// @param name
    /// @returns {bool}
    /// @desc Obtiene el valor del stat
    static Get = function(_name) {
    	return (variable_struct_get(stats, _name) ); 
    }
	
	/// @param name
	/// @returns {bool}
	static Exists = function(_name) {
		return (variable_struct_exists(stats, _name) );
	}
	
    /// @param stat_name
    /// @param base_value
    static SetBase  = function(_name, _base) {
    	if (mall_stat_exists(_name) && variable_struct_exists(bases, _name) ) {
    		variable_struct_set(bases, _name, _base);
    	}
        
        return self;
    }
    
    /// @param stat_array
    static SetBases = function(_array) {
        var i = 0; repeat(array_length(_array) - 1) {
            SetBase(_array[i], _array[i + 1] );
            ++i;
        }
        
        return self;        
    }    
    
    static GetBase = function(_name) {
    	return (variable_struct_get(bases, _name) ); 
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
    
    #endregion
    
    Init();
}

function __group_class_elements() : __mall_class_parent("GROUP_ELEMENTS") constructor {
	elmn = {};
	
	#region Metodos
	static Init = function() {
		var _names = mall_global_elements();
		
		repeat (each(_names) ) {
			var in = this.value;
			
			variable_struct_set(elmn, in, 1);
		}
	}
	
	static Set = function(_name, _val) {
		if (mall_element_exists(_name) ) {
			variable_struct_set(elmn, _name, _val);	
		}
		
		return self;
	}
	
	static Get = function(_name, _val) {
		return (variable_struct_get(_name, _val) );
	}
	
	/// @param name
	/// @returns {bool}
	static Exists = function(_name) {
		return (variable_struct_exists(elmn, _name) );
	}
	
	#endregion
	
	Init();
}

function __group_class_resistances() : __mall_class_parent("GROUP_RESISTANCES") constructor {
	state = {}
	
	#region Metodos
	static Init = function() {
		var _names = mall_global_states();

		repeat (each(_names) ) {
			var in = this.value;
			
			variable_struct_set(state, in, 1);
		}		
	}
	
	static Set = function(_name, _val) {
		if (mall_state_exists(_name) ) {
			variable_struct_set(state, _name, _val);	
		}
		
		return self;
	}
	
	static Get = function(_name, _val) {
		return (variable_struct_get(_name, _val) );
	}
	
	/// @param name
	static Exists = function(_name) {
		return (variable_struct_exists(state, _name) );
	}
	
	#endregion
	
	Init();
}

function __group_class_equip(_defaults = true) : __mall_class_parent("GROUP_EQUIP") constructor {
    parts   = {};
    previus = {};	// Que equipo habia antes en la parte
    
	capable = {};
	
    #region Metodos
    
    static Init = function() {
    	var _names = mall_part_get_names();
    	
    	repeat (each(_names) ) {
    		var _names  = this.value;
    		var _noitem = (mall_get_part(_names) ).noitem;
    		
    		variable_struct_set(parts  , _names, _noitem);
    		variable_struct_set(previus, _names, _noitem);
    		
    		variable_struct_set(capable, _names, [] );
    	}
    }
	
	/// @param {string} part_name
	/// @param value
	static Set = function(_name, _value) {
		if (mall_part_exists(_name) ) {
			if (_value == undefined) _value = (mall_get_part(_name) ).noitem;
			
			variable_struct_set(parts, _name, _value);
		}
		
		return self;
	}
	
	/// @param {string} part_name
	static Get = function(_name) {
		return (variable_struct_get(parts, _name) );	
	}
	
	/// @param {string} part_name
	/// @returns {bool}
	static Exists = function(_name) {
		return (variable_struct_exists(parts, _name) );
	}
	
	/// @param part_name
	/// @param itemsubtypes
	/// @desc Selecciona que subtipos puede usar
	static SetCapable = function(_name, _array) {
		var _capable = capable[$ _name];
		
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
		return (variable_struct_get(capable, _name) );
	}
	
	/// @param name
	/// @param value
	static SetPrevius = function(_name, _value) {
		if (mall_part_exists(_name) ) variable_struct_set(previus, _name, _value);

		return self;
	}
	
	/// @param name
	static GetPrevius = function(_name) {
		return (variable_struct_get(previus, _name) );
	}
	
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
		var _noitem = (mall_get_part(_name) ).noitem;
		
		return (Get(_name) != _noitem);
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
    /// @param state_name
    /// @param value
    static SetRest = function(_name, _value) {
    	if (mall_stat_exists(_name) ) {
    		rest[$ _name] = _value;
    	}
    	
    	return self;
    }
    
    /// @param state_name
    static GetRest = function(_name) {
		return (rest[$ _name] );    	
    }
    
    /// @param name
    static ExistsRest = function(_name) {
    	return (variable_struct_exists(rest, _name) );
    }
    
    #endregion
    
    	#region Elements
    /// @param element_name
    /// @param value
    static SetElemn = function(_name, _value) {
    	if (mall_element_exists(_name) ) elem[$ _name] = _value;
		   
    	return self;
    }
    
    /// @param element_name
    static GetElemn = function(_name) {
		return (variable_struct_get(elem, _name) ); 	
    }
    
    /// @param element_name
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

/// @param {string} name
/// @param {__group_class_stats} stats
/// @param {__group_class_control} state_control
/// @param {__group_class_equip} equip
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
    static EquipPut = function(_part, _key) {
        var _item = bag_item_get(_key);
        
        if (equip.IsCapable(_part, _item.subtype) ) {
            // Si esta ocupado sacar el objeto
            if (equip.IsOccupied(_part) )  EquipTake(_part);
            
            equip.Set(_part, _key);
            bag_storage_add(_key, -1);
            
            EquipGetUpgrades();
            
            return true;
        }
        
        return false;
    }    
    
    /// @param part_name
    static EquipTake = function(_name) {
    	var _part = mall_get_part(_name);
		var _key = equip.Get(_name);
		
		// Si no posee objeto salir
		if (_key == _part.noitem) return false;

		// Recuperar el objeto
		bag_storage_add(_key, 1);
		
		equip.Set(_name);	// Poner nada en la posicion
		equip.SetPrevius(_name, _key);

		EquipGetUpgrades(); // Obtener los buffos
		
		return true;    
    }
    
    /// @param slot_name
    /// @desc Obtiene las mejoras de un slot en especifico
    static EquipGetUpgrade  = function(_name) {
        if (!equip.Exists(_name) ) return self; // Si no existe la parte entonces salir.
         
        var _part = mall_get_part(_name);
        var _key  = equip.GetSlot(_name);    
		
		var _stat, _rest, _elem;
		
		if (_key == _part.noitem) {
			#region No hay objeto
			var _ant = equip.GetPrevius();
			
			_stat = (new __group_class_stats() ).Override("stats", 0);
			
			/// comprobar que anteriormente habia o no un objeto
			if (_ant == _part.noitem) {
				_rest = (new __group_class_resistances() )	.Override("state", 0);
				_elem = (new __group_class_elements() )		.Override("elmn" , 0);
			} else {
				var _previus = bag_item_get(_ant);
				
				_rest = _previus.GetResistances().Turn("state");
				_elem = _previus.GetElements   ().Turn("elmn" );
			}
			#endregion
		} else {
			#region Hay objeto
			var _item = (bag_item_get(_key) ); /// @is {__bag_class_item}
			
			_stat = _item.GetStats();
			_rest = _item.GetResistances();
			_elem = _item.GetElements();
			
			#endregion
		}
		
		var _statnames = mall_global_stats(), _restnames = mall_global_states(), _elemnames = mall_global_elements();
    
        #region Estadisticas
        var i = 0; repeat(array_length(_statnames) ) {
            var _name = _names[i];
            
            if (stats.Exists(_name) && _stat.Exists(_name) ) {
            	// Obtener valores
            	var in  = stats.Get(_name), out = _stat.Get(_name);
            	
            	stats_final.Set(_name, in + out); 
            }
			
            ++i;
        }
        
        #endregion
        
        #region Resistencias
        var i = 0; repeat(array_length(_restnames) ) {
            var _name = _names[i];
            
            if (state.ExistsRest(_name) && _rest.Exists(_name) ) {
            	// Obtener valores
            	var in  = state.GetRest(_name), out = _rest.Get(_name);
            	
            	state.SetRest(_name, in + out); 
            }
            
            ++i;
        }  
        
        #endregion
        
        #region Elementos
        var i = 0; repeat(array_length(_elemnames) ) {
            var _name = _names[i];
			
			if (state.ExistsElemn(_name) && _elem.Exists(_name) ) {
            	// Obtener valores
            	var in  = state.GetElemn(_name), out = _rest.Get(_name);
            	
            	state.SetElemn(_name, in + out); 					
			}
			
            ++i;
        }          
        
        #endregion
    
        return self;
    }
    
    /// @desc Obtiene las mejoras del equipamiento
    static EquipGetUpgrades = function() {
        var _slots = mall_part_get_names();  // Por si no usa los defaults
        
        var i = 0; repeat (array_length(_slots) ) {EquipGetUpgrade(_slot[i] ); ++i; }
        
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
    
    stats = _stats; /// @is {__group_class_stats}
    stats_final = (new __group_class_stats(_stats.lvl) ); /// @is {__group_class_stats}
    
    state = _control;	/// @is {__group_class_control}
    
    equip = _equip; /// @is {__group_class_equip}
    
    comands = tree_create();    /// @is {__tree_class}
}




