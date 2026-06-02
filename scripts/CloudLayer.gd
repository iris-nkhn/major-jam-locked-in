class_name CloudLayer
extends Node2D
## Capa de nubes decorativa. Las nubes viven en el espacio LOCAL de este nodo
## (no dependen del viewport), dentro de un area configurable. Se mueven
## lentamente en horizontal y se reciclan al salir del area por la derecha.
##
## Pensado para colocarse dentro de un "mundo" que la camara panea: las nubes
## ya existen y se mueven aunque todavia no esten dentro de la camara.

@export_dir var cloud_folder: String = "res://assets/cloud_single"
@export var cloud_count: int = 6

## Area (en coordenadas locales) donde viven las nubes.
## x = recorrido horizontal antes de reciclar; y = banda vertical de aparicion.
@export var area_size: Vector2 = Vector2(1152, 300)

@export_group("Movimiento")
@export var min_speed: float = 6.0   ## px/seg (lento, ambiente calmado)
@export var max_speed: float = 22.0

@export_group("Aspecto")
@export var min_scale: float = 1.0
@export var max_scale: float = 2.0
## Distancia horizontal minima entre nubes al aparecer (px).
@export var min_h_distance: float = 180.0

## Si es true, las nubes aparecen al instante repartidas por el area.
## Si es false, hay que llamar a begin() (util si la configura otro script).
@export var auto_start: bool = true

var _textures: Array[Texture2D] = []
var _clouds: Array[Dictionary] = []
var _started: bool = false


func _ready() -> void:
	_load_textures()
	if _textures.is_empty():
		push_warning("CloudLayer: no se encontraron texturas de nubes en %s" % cloud_folder)
		return

	if auto_start:
		begin()


## Crea las nubes repartidas por el area, ya en movimiento.
func begin() -> void:
	if _started or _textures.is_empty():
		return
	_started = true
	for i in cloud_count:
		_spawn_cloud(true)


func _process(delta: float) -> void:
	for c in _clouds:
		var spr: Sprite2D = c.sprite
		spr.position.x += c.speed * delta
		var half_w: float = spr.texture.get_width() * spr.scale.x * 0.5
		# Cuando sale del area por la derecha, reaparece por la izquierda.
		if spr.position.x - half_w > area_size.x:
			_reset_cloud(c, false)


func _load_textures() -> void:
	# Cargamos por ruta explicita (robusto en builds exportados, a diferencia de
	# enumerar archivos fuente .png con DirAccess).
	# Solo las nubes blancas: 1, 4, 7, 10... (paso de 3).
	for i in range(1, 31, 3):
		var path: String = "%s/cloud%d.png" % [cloud_folder, i]
		if ResourceLoader.exists(path):
			var tex := load(path) as Texture2D
			if tex:
				_textures.append(tex)


func _spawn_cloud(initial_spread: bool) -> void:
	var spr := Sprite2D.new()
	spr.texture = _textures.pick_random()
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST  # mantiene el pixel art nitido
	spr.centered = true
	add_child(spr)

	var c := {"sprite": spr, "speed": 0.0}
	_clouds.append(c)
	_reset_cloud(c, initial_spread)


func _reset_cloud(c: Dictionary, initial_spread: bool) -> void:
	var spr: Sprite2D = c.sprite
	var s := randf_range(min_scale, max_scale)
	spr.scale = Vector2(s, s)
	spr.modulate.a = 1.0

	# Posicion vertical libre dentro de la banda (pueden solaparse entre si).
	var half_h: float = spr.texture.get_height() * s * 0.5
	var half_w: float = spr.texture.get_width() * s * 0.5
	var y := randf_range(half_h, max(half_h, area_size.y))

	var x: float
	if initial_spread:
		# Reparto inicial por todo el ancho del area, respetando la distancia minima.
		x = _pick_initial_x(c)
	else:
		# Reaparece por la izquierda, dejando hueco respecto a la nube mas a la izquierda.
		x = min(-half_w, _leftmost_x(c) - min_h_distance)

	spr.position = Vector2(x, y)
	c.speed = randf_range(min_speed, max_speed)


func _pick_initial_x(c: Dictionary) -> float:
	# Muestreo con rechazo: probamos posiciones hasta encontrar una
	# suficientemente separada del resto de nubes ya colocadas.
	var best_x := randf_range(0.0, area_size.x)
	for attempt in 30:
		var candidate := randf_range(0.0, area_size.x)
		if _is_x_free(candidate, c):
			return candidate
		best_x = candidate
	return best_x


func _is_x_free(x: float, c: Dictionary) -> bool:
	for other in _clouds:
		if other == c:
			continue
		if absf(other.sprite.position.x - x) < min_h_distance:
			return false
	return true


func _leftmost_x(c: Dictionary) -> float:
	var left := area_size.x
	for other in _clouds:
		if other == c:
			continue
		left = min(left, other.sprite.position.x)
	return left
