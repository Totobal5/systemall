#macro this (each()).next()

function each () {

	static interface = (function interface () {
		state = {
   			iterable: undefined,
   			variable: {item: undefined, value: 0},
   			tokens: undefined,
   			index: 0,
   			completed: true
   		};
		
   		function next () {
			var result = (state.variable).item;
   			state.index++;
   		
   			if (state.index < array_length(state.tokens)) {
   				var iterable = state.iterable;
   				var index = state.index;
   			
   				var token = state.tokens[index];
   				var value = undefined;
   			
   				if (is_struct(iterable)) value = variable_struct_get(iterable, token);
   				else if (is_string(iterable)) value = string_char_at(iterable, (index + 1));
   				else if (is_array(iterable)) value = iterable[index];
   				else if (is_real(iterable) || ds_exists(iterable, ds_type_list)) value = ds_list_find_value(iterable, index);
   	
   				var item = {key: token, value: value, index : index}
   				if (is_string((state.variable).value)) variable_struct_set(item, (state.variable).value, value);
   				(state.variable).item = item;
   			
   			}
				
			else state.completed = true;
   			return result;
    		
   		}
    	
   	});

   	var each_instance = (function () : interface () constructor {
   		if (argument_count == 0) exit;

   		state.completed = false;
   		state.index = -1;
   		(state.variable).value = 0;
   		var count = 0;

   		if (argument_count > 1 && is_string(argument[0]) && !is_method(argument[1])) {
   			if (string_length(argument[0]) > 0) {
   				if (string_count(argument[0], " ")) throw "repeat each: invalid variable name";
   				(state.variable).value = argument[0];
   			}
    		
   			else throw "repeat each: variable name is empty";
   			count++;
   		}
    	
   		if (argument_count < count) throw "repeat each: no data error";
   		var iterable = argument[count];
    	
   		state.iterable = iterable;
    	
   		if (is_struct(iterable)) state.tokens = variable_struct_get_names(iterable);
    	
   		else if (is_string(iterable)) {
   			var tokens = array_create(string_length(iterable));
    		
   			for(var index = 1; index <= string_length(iterable); index++) tokens[index - 1] = index;
   			state.tokens = tokens;
   		}
    	
   		else if (is_array(iterable)) {
   			var tokens = array_create(array_length(iterable));
				
   			for(var index = 0; index < array_length(iterable); index++) tokens[index] = index;				
   			state.tokens = tokens;
   		}
    	
   		else if (is_real(iterable) && ds_exists(iterable, ds_type_list)) {
   			var tokens = array_create(ds_list_size(iterable));
   			
			for(var index = 0; index < array_length(tokens); index++) tokens[index] = index;
   			state.tokens = tokens;
   		}
    	
   		else throw "repeat each: invalid type of numerable object, type: " + string(typeof(iterable));
   		self.next();
    	
   		if (argument_count > (count + 1)) {
   			var container = argument[count + 1];
			var result = 0;

   			if (is_method(container)) {
   				var context = {};
					
   				if (argument_count > count + 2) {
   					context = argument[count + 2];
   					container = method(context, container);
   				}
					
   				repeat (array_length(state.tokens)) {
   					var struct = self.next();
   					result = container(struct.value);
   					if (!is_undefined(result)) return result;
   				}
    			
   				return result;
   			}

   		}

   		return array_length(state.tokens);

   	});


   	static instances = ds_list_create();
   	static instance = undefined;
    	
   	if (argument_count == 0) {
   		if ((instance.state).completed) {
   			if (ds_list_size(instances) == 0) throw "Each error: 'this' calls number error";
   			instance = instances[| 0];
   			ds_list_delete(instances, 0);
   		}
		
   		return instance;
   	}
    	
   	if (instance != undefined) {
   		if (!(instance.state).completed) ds_list_insert(instances, 0, instance);
   	}
    	
   	if (argument_count == 1) instance = new each_instance(argument[0]);
   	else if (argument_count == 2) instance = new each_instance(argument[0], argument[1]);
   	else if (argument_count == 3) instance = new each_instance(argument[0], argument[1], argument[2]);
   	return array_length((instance.state).tokens);
}