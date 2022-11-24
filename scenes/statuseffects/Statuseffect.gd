extends Node2D

func type() -> int:
	"""
	Virtual method. define the type of status effect
	"""
	assert(false, "type1 must be implented")
	return Global.StatusEffectType.NONE