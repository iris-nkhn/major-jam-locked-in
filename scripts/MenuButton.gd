extends Button
## Boton de menu translucido. El "seleccionado" se rige por el FOCO, asi que
## solo puede haber uno activo a la vez: al pasar el raton sobre un boton, este
## toma el foco y los demas se deseleccionan automaticamente. La navegacion con
## teclado/mando usa el mismo mecanismo.

@export_range(0.0, 1.0) var idle_alpha: float = 0.5
@export_range(0.0, 1.0) var active_alpha: float = 1.0
@export var fade_time: float = 0.15

var _tween: Tween


func _ready() -> void:
	modulate.a = idle_alpha
	# El raton al pasar por encima selecciona este boton (quitando el foco a los
	# demas). Al salir NO se deselecciona: el ultimo seleccionado se mantiene.
	mouse_entered.connect(grab_focus)
	# El estado visual depende unicamente del foco -> solo uno activo a la vez.
	focus_entered.connect(_to_active)
	focus_exited.connect(_to_idle)


func _to_active() -> void:
	_fade_to(active_alpha)


func _to_idle() -> void:
	_fade_to(idle_alpha)


func _fade_to(target: float) -> void:
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", target, fade_time)
