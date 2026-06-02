extends Control
## Logica del menu principal.
## Intro: la "camara" (un contenedor World con el fondo y las nubes) arranca
## mostrando la parte inferior del fondo y panea lentamente hacia arriba.
## Las nubes ya existen y se mueven en la parte alta del mundo desde el inicio,
## asi que cuando la camara llega arriba ya estan ahi desplazandose.
## Al terminar el paneo, el logo y los botones se materializan (fade in).

const CURSOR_NORMAL = preload("res://assets/Complete_UI_Book_Styles_Pack_Free_v1.0/01_TravelBookLite/Sprites/UI_TravelBook_Cursor01d.png")

const _CLICK_FRAMES = [
	preload("res://assets/Complete_UI_Book_Styles_Pack_Free_v1.0/01_TravelBookLite/Sprites Animated/UI_TravelBook_MouseCursorClick01a_1.png"),
	preload("res://assets/Complete_UI_Book_Styles_Pack_Free_v1.0/01_TravelBookLite/Sprites Animated/UI_TravelBook_MouseCursorClick01a_2.png"),
	preload("res://assets/Complete_UI_Book_Styles_Pack_Free_v1.0/01_TravelBookLite/Sprites Animated/UI_TravelBook_MouseCursorClick01a_3.png"),
	preload("res://assets/Complete_UI_Book_Styles_Pack_Free_v1.0/01_TravelBookLite/Sprites Animated/UI_TravelBook_MouseCursorClick01a_4.png"),
]
const CLICK_FRAME_DURATION := 1.0 / 12.0

var _click_frame_index: int = 0
var _click_timer: Timer

@onready var _world: Node2D = $World
@onready var _background: Sprite2D = $World/Background
@onready var _clouds: CloudLayer = $World/CloudLayer
@onready var _title: TextureRect = $TitleLogo
@onready var _buttons: VBoxContainer = $Buttons
@onready var _start_button: Button = %StartButton
@onready var _options_button: Button = %OptionsButton
@onready var _exit_button: Button = %ExitButton

@export_group("Intro")
@export var pan_duration: float = 5.0      ## segundos del paneo del fondo
@export var pan_start_delay: float = 0.3   ## espera inicial antes de panear
@export var fade_in_duration: float = 1.5  ## segundos para materializar logo/botones

@export_group("Nubes")
## Fraccion superior de la pantalla (en el encuadre final) donde viven las nubes.
@export_range(0.1, 1.0) var cloud_band: float = 0.45


func _ready() -> void:
	_click_timer = Timer.new()
	_click_timer.wait_time = CLICK_FRAME_DURATION
	_click_timer.one_shot = false
	_click_timer.timeout.connect(_on_click_timer_tick)
	add_child(_click_timer)

	Input.set_custom_mouse_cursor(CURSOR_NORMAL)

	_start_button.pressed.connect(_on_start_pressed)
	_options_button.pressed.connect(_on_options_pressed)
	_exit_button.pressed.connect(_on_exit_pressed)

	_play_intro()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_click_frame_index = 0
		Input.set_custom_mouse_cursor(_CLICK_FRAMES[0])
		_click_timer.start()


func _on_click_timer_tick() -> void:
	_click_frame_index += 1
	if _click_frame_index >= _CLICK_FRAMES.size():
		_click_timer.stop()
		Input.set_custom_mouse_cursor(CURSOR_NORMAL)
	else:
		Input.set_custom_mouse_cursor(_CLICK_FRAMES[_click_frame_index])


func _play_intro() -> void:
	var view_size: Vector2 = get_viewport_rect().size

	# Escalamos el fondo para que cubra el ancho de la pantalla.
	var tex_size: Vector2 = _background.texture.get_size()
	var scale_factor: float = view_size.x / tex_size.x
	_background.scale = Vector2(scale_factor, scale_factor)
	var bg_height: float = tex_size.y * scale_factor

	# Las nubes viven en la franja superior del mundo (coordenadas locales del
	# World, donde el fondo arranca en (0,0)). Asi, en el encuadre final
	# (World.y = 0) aparecen en la parte alta de la pantalla.
	_clouds.position = Vector2.ZERO
	_clouds.area_size = Vector2(view_size.x, view_size.y * cloud_band)
	_clouds.begin()

	# Posiciones del paneo (movemos el World entero: fondo + nubes).
	# Inicio: borde inferior del fondo pegado al fondo de la pantalla.
	# Fin: borde superior arriba (se ve la parte alta y las nubes).
	var y_start: float = view_size.y - bg_height
	var y_end: float = 0.0
	_world.position = Vector2(0.0, y_start)

	# El logo y los botones empiezan invisibles y no pulsables.
	_title.modulate.a = 0.0
	_buttons.modulate.a = 0.0
	_buttons.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(pan_start_delay)
	tween.tween_property(_world, "position:y", y_end, pan_duration)
	tween.tween_callback(_reveal_ui)


func _reveal_ui() -> void:
	_buttons.mouse_filter = Control.MOUSE_FILTER_STOP

	var tween := create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_title, "modulate:a", 1.0, fade_in_duration)
	tween.tween_property(_buttons, "modulate:a", 1.0, fade_in_duration)
	# Sin seleccion por defecto: el foco solo aparece al pasar el raton o
	# al navegar con teclado/mando.


func _unhandled_input(event: InputEvent) -> void:
	# Si todavia no hay nada seleccionado y se pulsa una tecla de movimiento,
	# seleccionamos el primer boton para arrancar la navegacion por teclado.
	if get_viewport().gui_get_focus_owner() != null:
		return
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") \
			or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		_start_button.grab_focus()
		get_viewport().set_input_as_handled()


func _on_start_pressed() -> void:
	# TODO: cargar la escena de juego / selector de nivel.
	print("[MainMenu] Start")


func _on_options_pressed() -> void:
	# TODO: abrir panel de opciones.
	print("[MainMenu] Options")


func _on_exit_pressed() -> void:
	get_tree().quit()
