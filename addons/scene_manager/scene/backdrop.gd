@tool
class_name SceneManagerBackdrop extends Control

## See [member close_modal_on_clicked].
signal close_modal_requested
## Emitted when modal is entered in the tree.
signal modal_added(control: Control)

## SceneManager modal backdrop.
## 
## This class has useful properties and methods to show its first control child
## with an adjustable position and opacity animation.[br]
## [b]Note:[/b] Position is not working yet. I get issues with hidden node and
## size udpate.
## @experimental

enum State {
	OPEN,
	CLOSE,
}

enum Unit {
	PIXEL,
	SCREEN,
}

var modal: Control

var _tween: Tween
## Initial modal position.
var _modal_position := Vector2.ZERO
## Current modal state.
var _modal_state := State.CLOSE
## Indicates if modal is loading.
var _loading := false:
	set(value):
		if _loading != value:
			_loading = value
			set_process(_loading)
			if not _loading:
				_loading_path = ""
var _loading_path := ""

## Modal position offset unit. See [member modal_offset].
## @experimental
@export var modal_offset_unit := Unit.PIXEL:
	set(value):
		if modal_offset_unit != value:
			modal_offset_unit = value
			
			if is_node_ready():
				if size.x == 0 or size.y == 0:
					push_warning("Node size has zero coordinate.")
					return
				
				if modal_offset_unit == Unit.PIXEL:
					modal_offset *= size
				else:
					modal_offset /= size
## Modal position offset to tween from offset to initial position.
## @experimental
@export var modal_offset := Vector2.ZERO

## Backdrop color.
@export_color_no_alpha var color := Color(0, 0, 0, 0.5):
	set(value):
		if color != value:
			color = value
			queue_redraw()
## Close modal when backdrop is clicked. When it is [code]false[/code],
## [signal close_requested] is emitted on backdrop click to customize
## behavior.
@export var close_modal_on_clicked := true
## Animation duration.
@export var tween_duration := 0.25
## Indicates if it must animate modal opacity. It is always animated backdrop
## color if [member tween_duration] is positive.
@export var tween_modal_opacity := true

#region Virtual Methods
func _ready() -> void:
	set_process(false)
	if not Engine.is_editor_hint():
		if not visible:
			_disable()
		
		if get_child_count() > 0:
			var child := get_child(0)
			if child is Control:
				modal = child
				_modal_position = modal.position / size
				modal.update_minimum_size()
			else:
				push_warning("First child must be Control.")


func _process(_delta: float) -> void:
	var progress := []
	var status := ResourceLoader.load_threaded_get_status(_loading_path, progress)
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		pass #TODO Add progress bar
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		var packed: PackedScene = ResourceLoader.load_threaded_get(_loading_path)
		_loading = false
		add_modal_from_packed(packed)
	elif status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		push_error("Modal thread load invalid resource.")
		_loading_path = ""
		_loading = false
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		push_error("Modal thread load failed.")
		_loading_path = ""
		_loading = false


func _draw() -> void:
	if color.a > 0:
		draw_rect(Rect2(Vector2.ZERO, size), color)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if close_modal_on_clicked:
				close_modal()
			else:
				close_modal_requested.emit()
#endregion


## Loads a modal from packed scene path. Uses background loading with a loading
## progress bar.
## @experimental
func load_modal_from_file(path: String) -> Error:
	if _loading:
		push_warning("A modal is already loading.")
		return FAILED
	
	var error := ResourceLoader.load_threaded_request(path, "PackedScene")
	if error:
		push_error(error_string(error))
	
	_loading = true
	_loading_path = path
	push_warning("Method is not implemented.")
	
	return error

## @experimental
func add_modal_from_packed(packed: PackedScene) -> void:
	if not packed:
		push_error("'packed' is null.")
		return
	add_modal(packed.instantiate())

## @experimental
func add_modal(control: Control) -> void:
	control.tree_entered.connect(_on_modal_added, CONNECT_ONE_SHOT)
	modal = control
	add_child(control)

## Emits [signal modal_added].
func _on_modal_added() -> void:
	modal_added.emit(modal)

## Open child modal. Returns a tween if [member tween_duration] is positive.
func open_modal() -> Tween:
	if _modal_state == State.OPEN:
		push_warning("Modal is already opening.")
		return null
	
	if _tween and _tween.is_running():
		push_warning("Animation is playing.")
		return _tween
	
	_modal_state = State.OPEN
	_tween = create_tween()
	
	_enable()
	
	#region Tween Color
	if tween_modal_opacity:
		modulate.a = 0.0
		_tween.tween_property(self, "modulate:a", 1.0, tween_duration)
	else:
		self_modulate.a = 0.0
		_tween.tween_property(self, "self_modulate:a", 1.0, tween_duration)
	
	if modal is Control:
		if modal_offset_unit == Unit.PIXEL:
			_set_child_pixel_offset(1.0)
			_tween.parallel().tween_method(_set_child_pixel_offset, 1.0, 0.0, tween_duration)
		else:
			_set_child_screen_offset(1.0)
			_tween.parallel().tween_method(_set_child_screen_offset, 1.0, 0.0, tween_duration)
	else:
		push_warning("'modal' property is null.")
	#endregion
	
	return _tween


func _set_child_screen_offset(offset: float) -> void:
	pass
	#modal.position = _modal_position + size * modal_offset * offset, true


func _set_child_pixel_offset(offset: float) -> void:
	pass
	#modal.set_position(_modal_position + modal_offset * offset, true)


## Close child modal.
func close_modal() -> Tween:
	if _modal_state == State.CLOSE:
		push_warning("Modal is already closing.")
		return null
	
	if _tween and _tween.is_running():
		_tween.kill()
	_modal_state = State.CLOSE
	_tween = create_tween()
	
	#region Tween Color
	if tween_modal_opacity:
		_tween.tween_property(self, "modulate:a", 0.0, tween_duration / modulate.a)
	else:
		_tween.tween_property(self, "self_modulate:a", 0.0, tween_duration / modulate.a)
	_tween.finished.connect(_disable)
	#endregion
	
	return _tween


func _enable() -> void:
	show()
	process_mode = Node.PROCESS_MODE_INHERIT


func _disable() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
