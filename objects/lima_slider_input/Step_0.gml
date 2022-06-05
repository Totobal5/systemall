/// @description [LOGIC]
if (isActive && isFocus) {
	// Derecha e izquierda
	if (isAxis) {
		#region SLIDE	
		if (alarm[1] == -1) {
			if (logicLeftPress(keyLeft) )	{pressLeft(number);		} else 
			if (logicLeftRelease(keyLeft) )	{releaseLeft(number);	}	
		}

		if (alarm[2] == -1) {
			if (logicRightPress(keyRight) )		{pressRight(number);	} else 
			if (logicRightRelease(keyRight) )	{releaseRight(number);	}	
		}

		#endregion

		#region Up
		if (!is_undefined(selectUp) && instance_exists(selectUp) ) {
			if (alarm[0] == -1) {
				if (logicUpPress(keyUp) ) {
					pressUp(number);
				}
				else if (logicUpRelease(keyUp) ) {
					releaseUp(number);	
				}
			}
		}
		#endregion
		
		#region Down
		if (!is_undefined(selectDown) && instance_exists(selectDown) ) {
			if (alarm[3] == -1) {
				if (logicDownPress(keyDown) ) {
					pressDown(number);
				}
				else if (logicDownRelease(keyDown) ) {
					releaseDown(number);	
				}	
			}
		}
		#endregion				
	}
	// Arriba y abajo
	else {
		#region SLIDE
		if (alarm[0] == -1) {
			if (logicUpPress(keyUp) )	{pressUp(number);	} else 
			if (logicUpRelease(keyUp) ) {releaseUp(number);	}
		}

		if (alarm[3] == -1) {
			if (logicDownPress(keyDown) )	{pressDown(number);		} else 
			if (logicDownRelease(keyDown) ) {releaseDown(number);	}	
		}
		#endregion						
		
		#region Left
		if (!is_undefined(selectLeft) && instance_exists(selectLeft) ) {
			if (alarm[1] == -1) {
				if (logicLeftPress(keyLeft) ) {
					pressLeft(number);
				}
				else if (logicLeftRelease(keyLeft) ) {
					releaseLeft(number);	
				}	
			}
		}
	
		#endregion
	
		#region Right
		if (!is_undefined(selectRight) && instance_exists(selectRight) ) {
			if (alarm[2] == -1) {
				if (logicRightPress(keyRight) ) {
					pressRight(number);
				}
				else if (logicRightRelease(keyRight) ) {
					releaseRight(number);	
				}	
			}
		}
		#endregion	
	}
}

updateTemplate();