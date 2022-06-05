/// @description [UPDATE TEMPLATE & SAME]
event_inherited();

if (sameAsParent) {
	isActive = parent.isActive;
	isFocus  =  parent.isFocus;
}

if (!isOutside) updateTemplate();