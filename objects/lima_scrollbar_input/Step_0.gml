/// @description [CUSTOM]
if (isActive) {
	if (canScroll) {
		#region Focus y seleccionado	
		if (lima_input_delay_possible(LIMA_INPUT.EXIT) ) {
			if (logicExitPress(keyUp) )		{pressExit  (number);	canScroll = false;} else 
			if (logicExitRelease(keyUp) )	{releaseExit(number);	}
			
			lima_input_delay_reset(LIMA_INPUT.EXIT);
		}
		
		#endregion
		
		#region Mover elementos
		// Arriba y abajo
		if (!dir) {
			#region ARRIBA
			if (lima_input_delay_possible(LIMA_INPUT.UP) && logicUpHold(keyUp) ) {
				scrollHold = min(stepsHoldMax, stepsHold + (stepsHold / stepsTime) );
				scrollY -= floor(scrollHold);
				stepsTime--;
				// Elements
				scroll(-1);
				
				lima_input_delay_reset(LIMA_INPUT.UP, stepsTime);						
			}
			else if (logicUpRelease(keyUp) ) {
				stepsTime = __stepsTime;
				scrollHold = 0;
			}
			#endregion
			
			#region ABAJO
			if (logicDownHold(keyDown) ) {
				scrollHold = min(stepsHoldMax, stepsHold + (stepsHold / stepsTime) );
				scrollY += floor(scrollHold);
				stepsTime--;
				// Elements				
				scroll(1);
				
				lima_input_delay_reset(LIMA_INPUT.DOWN, stepsTime);
			}
			else if (logicUpRelease(keyDown) ) {
				stepsTime = __stepsTime;
				scrollHold = 0;
			}
			#endregion
		}
		// Derecha e izquierda
		else {
			
		}
		
		#endregion
	}
	else {
		#region Control normal	
		if (isFocus) {
			#region UP
			if (instance_exists(selectUp) && lima_input_delay_possible(LIMA_INPUT.UP) ) {
				if (logicUpPress(keyUp) )	{pressUp(number);	} else 
				if (logicUpRelease(keyUp) ) {releaseUp(number);	}
			
				lima_input_delay_reset(LIMA_INPUT.UP);
			}
			#endregion		
	
			#region LEFT
			if (instance_exists(selectLeft) && lima_input_delay_possible(LIMA_INPUT.LEFT) ) {
				if (logicLeftPress(keyUp) )	  {pressLeft(number);	} else 
				if (logicLeftRelease(keyUp) ) {releaseLeft(number);	}
			
				lima_input_delay_reset(LIMA_INPUT.LEFT);				
			}
			#endregion	
	
			#region DOWN
			if (instance_exists(selectDown) && lima_input_delay_possible(LIMA_INPUT.DOWN) ) {
				if (logicDownPress(keyUp) )		{pressDown(number);		} else 
				if (logicDownRelease(keyUp) )	{releaseDown(number);	}
			
				lima_input_delay_reset(LIMA_INPUT.DOWN);
			}
			#endregion	
	
			#region RIGHT
			if (instance_exists(selectDown) && lima_input_delay_possible(LIMA_INPUT.RIGHT) ) {
				if (logicRightPress(keyUp) )	{pressRight(number);	} else 
				if (logicRightRelease(keyUp) )	{releaseRight(number);	}
			
				lima_input_delay_reset(LIMA_INPUT.RIGHT);
			}
			#endregion	
	
			#region ACTION
			if (lima_input_delay_possible(LIMA_INPUT.ACTION) ) {
				if (logicActionPress(keyUp) )	{pressAction(number);	lima_template_execute("Pressed"); canScroll = true; } else 
				if (logicActionRelease(keyUp) )	{releaseAction(number);	lima_template_execute("Release"); }
			
				lima_input_delay_reset(LIMA_INPUT.ACTION);			
			}
			#endregion			
		}
		#endregion
	}
}