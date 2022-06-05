/// @description [LOGIC]
event_inherited();

if (isActive && isFocus) {
	#region UP
	if (instance_exists(selectUp) && lima_input_delay_possible(LIMA_INPUT.UP) ) {
		if (logicUpPress(keyUp) )	{pressUp(number);	} else 
		if (logicUpRelease(keyUp) ) {releaseUp(number);	}
			
		lima_input_delay_reset(LIMA_INPUT.UP);
	}
	#endregion		
	
	#region LEFT
	if (instance_exists(selectLeft) && lima_input_delay_possible(LIMA_INPUT.LEFT) ) {
		if (logicLeftPress(keyLeft) )	{pressLeft(number);	} else 
		if (logicLeftRelease(keyLeft) ) {releaseLeft(number);	}
			
		lima_input_delay_reset(LIMA_INPUT.LEFT);				
	}
	#endregion	
	
	#region DOWN
	if (instance_exists(selectDown) && lima_input_delay_possible(LIMA_INPUT.DOWN) ) {
		if (logicDownPress(keyDown) )	{pressDown(number);		} else 
		if (logicDownRelease(keyDown) )	{releaseDown(number);	}
			
		lima_input_delay_reset(LIMA_INPUT.DOWN);
	}
	#endregion	
	
	#region RIGHT
	if (instance_exists(selectRight) && lima_input_delay_possible(LIMA_INPUT.RIGHT) ) {
		if (logicRightPress(keyRight) )		{pressRight(number);	} else 
		if (logicRightRelease(keyRight) )	{releaseRight(number);	}
			
		lima_input_delay_reset(LIMA_INPUT.RIGHT);
	}
	#endregion	
	
	#region ACTION
	if (lima_input_delay_possible(LIMA_INPUT.ACTION) ) {
		if (logicActionPress(keyAction) )	{pressAction(number);	lima_template_execute("Pressed"); } else 
		if (logicActionRelease(keyAction) )	{releaseAction(number);	lima_template_execute("Release"); }
			
		lima_input_delay_reset(LIMA_INPUT.ACTION);			
	}
	#endregion
}