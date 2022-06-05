/// @param {String} _group_key
function PartyParts(_group_key) : MallComponent(_group_key) constructor {

    #region Metodos 
	/// @desc Iniciar control de partes
    static initialize = function() {
        var _keys  = mall_get_parts();    
        var _group = mall_get_group(__key);   // Obtener estadistica
        
        var i=0; repeat(array_length(_keys) ) {
            var _key  = _keys[i++]; // Llave
            var _part = _group.getPart(_key);    // obtener configuracion de parte
            
            if (!is_undefined(_part) ) {
                #region Crear Parte
                var _active = _part.__active;   // Es un array
                var _number = max(1, _part.__numbers);  // Repeticiones de este objeto no puede ser 0                
                var _itemtype   = _part.__items;         
				var _inParticle = new __PartyPartsParticle(_key, _number, _itemtype);                
                // Crear control de parte
                variable_struct_set(self, _key, _inParticle);
                
				var _max   = _part.__itemMax;	// Cuantos objetos puede llevar
                var _atoms = _inParticle.atoms;                
                var j=0; repeat(_number) {
					var _inAtom = new __PartyPartsAtom(_active[j], j++, _max);
                    array_push(_atoms, _inAtom);
                }
                #endregion
            }
        }    
    }
	
    /// @param {String} _key
	/// @return {Struct.__PartyPartsParticle}
    static get = function(_key) {
        return (self[$ _key] );
    } 

    /// @param {String} _key
    /// @param {String} _item_key
    /// @param {Real} _number
    /// @param {Real} _index
	/// @desc False: no se logro equipar el objeto True: objeto equipado esperando aplicar subida de estadisticas
    /// @return {Bool}
    static equip = function(_key, _item_key, _number=0, _index=0) {
        var _item = pocket_item_get(_item_key);
		var _particle = get(_key);
		
		if (is_undefined(_particle.itemtype[$ _item.__subtype] ) ) {
			return false;	
		}
		
		_number = clamp(_number, 0, _particle.__number);
		var _atom = _particle.get(_number);
		if (_atom.usable) {
			_index = clamp(_index, 0, _atom.__max);	
			_atom.previous[_index] = _atom.equipped[_index];
			_atom.equipped[_index] = _item_key;
			
			return true;
		}
		
		return false;
    } 
    
    /// @param {String} _key
    /// @param {Real} _number
    /// @param {Real} _index
	/// @return {Bool}
    static desequip = function(_key, _number=0, _index=0) {
        var _particle = get(_key);        
        
		if (is_undefined(_particle) ) return false;
		
        // Si existe el objeto
		_number = clamp(_number, 0, _particle.__number);
		var _atom = _particle.get(_number);
		
		_index = clamp(_index, 0, _atom.__max);
		// Guardar equipado
		var _equipped = _atom.equipped[_index];
		
		_atom.equipped[_index] = undefined;
		_atom.previous[_index] = _equipped;
		
		return true;
    } 
    
    /// @param {String} _key
    /// @param {Real} _number
    /// @param {Real} _index
    /// @returns {Bool}
    static isEquipped = function(_key, _number=0, _index=0) {
        var _particle = get(_key);
        
        _number = clamp(_number, 0, _particle.__number);
        var _atom = _particle.atoms[_number];
        
        _index = clamp(_index, 0, _atom.__max);
        return (_atom.equipped[_index] == _key);
    }
    
    /// @param part_key
    /// @returns {struct}
    static ApplyStat = function(_key) {
        // Poder pasar la parte sin tener que buscarlo
        var _part = is_string(_key) ? Get(_key) : _key; 
     
        #region Errores
        if (is_undefined(_part) || weak_ref_alive(__weakStats) ) {
            __mall_trace("(ApplyStat) No existe la parte o no hay referencia a las estadisticas");
            
            return undefined;
        }
        
        #endregion
        
        var _item, _stats;
        
        var _myStats = __weakStats.ref;
        var _bonus = 1;
        
        // Obtener cuantas mismas partes existen.
        var _components = _part.comp;
        var _returnStat = {};
        
        var i = 0; repeat(array_length(_components) ) {
            var _inPart = _components[i++];
            var _inEquipped = _inPart.equipped;
            var _inPrevious = _inPart.previous;
            
            var j = 0; repeat(array_length(_inEquipped) ) {
                var _equipped = _inEquipped[j];
                var _previous = _inPrevious[j++];
                
                #region Revisar si hay equipo
                if (!is_undefined(_equipped) ) {
                    _item = pocket_data_get(_equipped); 
                    
                } else if (!is_undefined(_previous) ) {
                    _item = pocket_data_get(_previous); 
                    _item.__returnInv = true; 
                    
                } else {
                    _item = pocket_data_get(POCKET_DATABASE_DUMMY); 
                }
                
                #endregion
                
                _bonus = _part.item[$ _item.__subtype] ?? mall_data(0, MN.R);  // Obtener bono
                
                var _bValue = _bonus[MDATA.VALUE];
                var _bType  = _bonus[MDATA .TYPE];
                
                _stats = _item.GetStats(); // Referencia a las estadisticas.
                
                // Sumar o restar
                var _statsNames = variable_struct_get_names(_stats);
                var _inBonus;
                
                var i = 0; repeat(array_length(_statsNames) ) {
                    var _statName = _statsNames[i++];
                    
                    var _mData  = _myStats[$ _statName];  // Obtener propiedades de esta stat
                    var _uValue = _mData.upper;  // Valor upper
                    var _uType  = _mData.type ;  // Tipo de numero                    
                    
                    var _isData = _stats[$ _statName];  // Obtener data del objeto
                    var _isValue = _isData[MDATA.VALUE], _inItem = _isValue;
                    var _isType  = _isData[MDATA .TYPE]; 

                    #region Math
                    var _temp = 0;
                    
                    if (_isType == MN.R) {
                        if (_bType == MN.R) {
                            _inItem += _bValue; 
                        } else {
                            _inItem += (_bValue * _isValue) / MALL_NUMBER_DIV; 
                        }
                    } else if (_isType == MN.P) {
                        _inItem = (_uValue * _isValue) / MALL_NUMBER_DIV;   
                        
                        if (_bType == MN.P) {
                            _inItem += (_inItem * _uValue) / MALL_NUMBER_DIV;
                        } else {
                            if (_uType == MN.R) {_temp = _bValue; } else {_temp = (_uValue * _bValue) / MALL_NUMBER_DIV; }
                        }
                    }
                    
                    #endregion
                    
                    // Realizar suma final
                    if (_uType == MN.R) {
                        _mData.final += __mall_stat_rounding(_inItem);
                    } else if (_uType == MN.P) {
                        _mData.final += __mall_stat_rounding( (_inItem * _uValue) / MALL_NUMBER_DIV);
                    }
                    
                    // Pequeño extra.
                    _mData.final += __mall_stat_rounding(_temp);
                }
            }
        }
        
        return (_returnStat);
    } 

    /// @returns {array}
    static ApplyStatAll = function() {
        var _keys  = mall_get_parts();
        var _array = [];
        
        var i = 0; repeat(array_length(_keys) ) {
            var _key  = _keys[i++]; // Llave
            array_push(_array, ApplyStat(_key) );
        }
        
        return (_array);
    }
   
    /// @param part_key/part_array
    /// @param item_key
    /// @param filter*
    /// @returns {struct}
    /// Compara las estadisticas del objeto actual con otro objeto obteniendo la diferencia en estadisticas
    static CompareItem = function(_key, _itemKey, _filter) {
        // Filtro
        /// @returns {array}
        if (_filter == undefined) _filter = function(_x, _y, name, i) {    
            var in  = string(_x[MDATA.VALUE] - _y[MDATA.VALUE] );
            var str = "";
            
    		if (in > 0) {str = ["+" + in, c_green]; } else 
    		if (in < 0) {str = ["-" + in, c_red  ]; } else {
    		    str = ["=" + in, c_white]; }
    		
    		// Si ambos son porcentajes agregar
    		if (_x[MDATA.TYPE] == MN.P && _y[MDATA.TYPE] ) {
    		    str[0] += "%"; 
    		}
    		
    		return str;
        }
        
        var _part, _partNumber, _partIndex;
        var _item1, _item2;
        var _stat1, _stat2;
        
        var _bon1, _bon2;
        
        #region Soporte number y index
        if (is_array(_key) ) {
            _partNumber = _key[1];
            _partIndex  = _key[2];
            _key = _key[0];
        } else {
            _partNumber = 0;
            _partIndex  = 0;
        }

        #endregion

        _part = Get(_key);
        
        // Si existe la referencia a las estadisticas y existe la parte
        if (weak_ref_alive(__weakStats) && !is_undefined(_part) ) {
            // Referencia
            var _myStat = __weakStats.ref;
            
            var _comp = _part.comp[_partNumber];
            var _inComp = _comp.equipped[_partIndex] ?? POCKET_DATABASE_DUMMY;  // Obtener el objeto equipado si posee uno
            
            // Obtener objeto equipado y objeto a comparar.
            _item1 = pocket_data_get(_inComp);
            _bon1  = _part.item[$ _item1.__subtype] ?? 0;   // Obtener bono 1
            _stat1 = _item1.GetStats();
            
            var _b1Val  = _bon1[MDATA.VALUE];
            var _b1Type = _bon1[MDATA .TYPE];
        
            _item2 = pocket_data_get(_itemKey);
            _bon2  = _part.item[$ _item2.__subtype] ?? 0;   // Obtener bono 2
            _stat2 = _item2.GetStats();
            
            var _b2Val  = _bon2[MDATA.VALUE];
            var _b2Type = _bon2[MDATA .TYPE];
                        
            var _difference = {};
            var _statsNames = mall_get_stats();

            var i = 0; repeat(array_length(_statsNames) ) {
                #region Diferencia entre 2 objetos
                var _statKey = _statsNames[i++];      
                
                var _iData1 = _stat1[$ _statKey] ?? mall_data(0, MN.R);
                var _iData2 = _stat2[$ _statKey] ?? mall_data(0, MN.R);
                
                var _iType1 = _iData1[MDATA.TYPE];
                var _iType2 = _iData1[MDATA.TYPE];
                
                var _iVal1 = _iData2[MDATA.VALUE];
                var _iVal2 = _iData2[MDATA.VALUE];
                
                #region Porcentual
                
                    #region 1° Item
                switch (_iType1) {  
                    case MN.R:
                        if (_b1Type == MN.R) {
                            _iVal1 += _b1Val;
                        } else if (_b1Type == MN.P) {
                            _iVal1 += (_iVal1 * _b1Val) / MALL_NUMBER_DIV;    
                        }
                    
                        break;
                        
                    case MN.P:
                        var _myVal  = _myStat[$ _statKey].upper[MDATA.VALUE];
                        var _myType = _myStat[$ _statKey].upper[MDATA. TYPE];
                    
                        _iVal1 = (_myVal * _iVal1) / MALL_NUMBER_DIV;
                        
                        if (_b1Type == MN.P) {
                            _iVal1 += (_iVal1 * _myVal) / MALL_NUMBER_DIV; 
                                
                        } else {
                            if (_myType == MN.R) {_iVal1 += _b1Val; } else {_iVal1 += (_myVal * _b1Val) / MALL_NUMBER_DIV; }
                        }

                        break;
                }
                    #endregion

                    #region 2° Item
                switch (_iType2) {  
                    case MN.R:
                        if (_b2Type == MN.R) {
                            _iVal2 += _b2Val;
                        } else if (_b1Type == MN.P) {
                            _iVal2 += (_iVal2 * _b2Val) / MALL_NUMBER_DIV;    
                        }
                    
                        break;
                        
                    case MN.P:
                        var _myVal  = _myStat[$ _statKey].upper[MDATA.VALUE];
                        var _myType = _myStat[$ _statKey].upper[MDATA. TYPE];
                    
                        _iVal2 = (_myVal * _iVal2) / MALL_NUMBER_DIV;
                        
                        if (_b2Type == MN.P) {
                            _iVal2 += (_iVal2 * _myVal) / MALL_NUMBER_DIV; 
                                
                        } else {
                            if (_myType == MN.R) {_iVal2 += _b2Val; } else {_iVal2 += (_myVal * _b2Val) / MALL_NUMBER_DIV; }
                        }

                        break;
                }
                    #endregion

                #endregion
                
                // Realizar diferencia entre valores
                _difference[$ _statKey] = _filter([__mall_stat_rounding(_iVal1), _iType1], [__mall_stat_rounding(_iVal2), _iType2], _statKey, i);
                
                #endregion
            } 
    
            return (_difference );
        }
        
        return undefined;
    }
    
    /// @param part_key/part_array
    /// @returns {struct}
    /// Regresa las estadisticas sin este objeto equipado.
    static CompareNoItem = function(_key, _number = 0, _index = 0) {
        // Desequipar objeto
        var _part = Get(_key);        
        
        if (is_undefined(_part) ) return undefined;
        
        var _comp = _part.comp[_number];
        var _eqp  = _comp.equipped[_index] ?? POCKET_DATABASE_DUMMY;

        var _item = pocket_data_get(_eqp);
        
        var _bonus = _part.item[$ _item.__subtype] ?? mall_data(0, MN.R);
        
        var _bVal = _bonus[MDATA.VALUE];
        var _bTyp = _bonus[MDATA .TYPE];
        
        var _itemStats = _item.GetStats();
        
        var _difference = {};
        var _statsNames = mall_get_stats();
    
        var _myStats = __weakStats.ref;
        
        var i = 0; repeat(array_length(_statsNames) ) {
            var _statKey = _statsNames[i++]; 
            
            // obtener estadistica
            var _mData = _myStats[$ _statKey];
            var _mTyp  = _mData.type;
            
            var _iData = _itemStats[$ _statKey];
            
            // Del objeto
            var _iVal = _iData[MDATA.VALUE];
            var _iTyp = _iData[MDATA .TYPE];
            
            #region Math
            switch (_iTyp) {
                case MN.R:
                    if (_bTyp == MN.R) {
                        _iVal += _bVal;
                    } else if (_bTyp == MN.P) {
                        _iVal += (_iVal * _bVal) / MALL_NUMBER_DIV;
                    }
                    
                    break;
                
                case MN.P:
                    var _val = _mData.upper;
                
                    _iVal = (_iVal * _val) / MALL_NUMBER_DIV;
                    
                    if (_bTyp == MN.P) {
                        _iVal += (_iVal * _val) / MALL_NUMBER_DIV; 
                            
                    } else {
                        if (_mTyp == MN.R) {_iVal += _bVal; } else 
                        if (_mTyp == MN.P) {_iVal += (_bVal * _val) / MALL_NUMBER_DIV; }
                    }
                    
                    break;
            }
            #endregion
            
            // obtener final para restar valores
            var _temp = _mData.final;
            
            if (_mTyp == MN.R) {
                _temp -= __mall_stat_rounding(_iVal);
            } else if (_mTyp == MN.P) {
                _temp -= __mall_stat_rounding((_iVal * _temp) / MALL_NUMBER_DIV);
            }
            
            _difference[$ _statKey] = _temp;
        }
        
        return (_difference);
    }
    
    #endregion
    
    
    initialize();
}