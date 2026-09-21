extends Node

const PROJEKTIL_SZENE = preload("res://projektil.tscn")
const POOL_GROESSE    = 30

var _pool: Array = []

func _ready():
	for i in POOL_GROESSE:
		_erstellen()

func _erstellen() -> Node:
	var p = PROJEKTIL_SZENE.instantiate()
	add_child(p)
	p.set_physics_process(false)
	p.monitoring  = false
	p.visible     = false
	_pool.append(p)
	return p

func holen() -> Node:
	for p in _pool:
		if not p.aktiv:
			return p
	# Pool erschöpft – Fallback: dynamisch erweitern
	return _erstellen()

func alle_deaktivieren():
	for p in _pool:
		if p.aktiv:
			p.deaktivieren()
