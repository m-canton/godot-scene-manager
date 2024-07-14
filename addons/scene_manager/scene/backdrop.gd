@tool
class_name SceneManagerBackdrop extends Container

## See [member close_modal_on_clicked].
signal close_modal_requested

## SceneManager modal backdrop.
## 
## This class has useful properties and methods to show its first control child
## with an adjustable position and opacity animation.

enum State {
	OPEN,
	CLOSE,
}

enum Unit {
	PIXEL,
	BACKDROP,
	MODAL,
}

## Modal.
var modal: Control

## Backdrop initial process mode.
var _process_mode := Node.PROCESS_MODE_INHERIT
## Indicates if modal has seen drawn.
var _modal_is_drawn := false
## Current modal state.
var _modal_state := State.CLOSE
## Modal initial process mode.
var _modal_process_mode := Node.PROCESS_MODE_INHERIT
## Modal open progress.
var _modal_open_progress := 0.0

## Tween to animate modal opening and closing.
var _tween: Tween

## Indicates if modal is loading.
var _loading := false:
	set(value):
		if _loading != value:
			_loading = value
			set_process(_loading)
			if not _loading:
				_loading_path = ""
## Current modal loading path.
var _loading_path := ""

## Backdrop color.
@export var color := Color(0, 0, 0, 0.5):
	set(value):
		if color != value:
			color = value
			queue_redraw()
## Close modal when backdrop is clicked. When it is [code]false[/code],
## [signal close_modal_requested] is emitted on backdrop click to customize
## behavior.
@export var close_modal_on_clicked := true

@export_group("Animation")
## Modal position offset unit. See [member modal_offset].
@export var modal_offset_unit := Unit.PIXEL:
	set(value):
		if modal_offset_unit != value:
			if is_node_ready():
				if size.x == 0 or size.y == 0:
					#push_warning("Node size has zero coordinate.")
					return
				
				if value == Unit.PIXEL:
					modal_offset *= size
				elif modal_offset_unit == Unit.PIXEL:
					modal_offset /= size
			modal_offset_unit = value
## Modal position offset to tween from offset to initial position.
@export var modal_offset := Vector2.ZERO
## Opening transition duration.
@export var opening_duration := 0.25
## Closing transition duration.
@export var closing_duration := 0.25
## Indicates if it must animate modal opacity.
@export var tween_modal_opacity := true

#region Virtual Methods
func _ready() -> void:
	set_process(false)
	if not Engine.is_editor_hint():
		_process_mode = process_mode
		
		if get_child_count() > 0:
			var child := get_child(0)
			if child is Control:
				set_modal(child, State.OPEN if visible else State.CLOSE)
			else:
				push_warning("First child must be Control.")

## Loads a modal in the background. See [method open_modal_from_file].
func _process(_delta: float) -> void:
	var progress := []
	var status := ResourceLoader.load_threaded_get_status(_loading_path, progress)
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		pass #TODO Add progress bar
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		var packed: PackedScene = ResourceLoader.load_threaded_get(_loading_path)
		_loading = false
		set_modal_from_packed(packed)
		open_modal()
	elif status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		push_error("Modal thread load invalid resource.")
		_loading_path = ""
		_loading = false
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		push_error("Modal thread load failed.")
		_loading_path = ""
		_loading = false

## Fits children and draws background.
func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		if visible:
			for c in get_children():
				if c is Control:
					var c_pos := Vector2.ZERO
					if c == modal and _modal_open_progress < 1.0:
						c_pos = (1.0 - _modal_open_progress) * (modal_offset * size if modal_offset_unit == Unit.BACKDROP else modal_offset * modal.size if modal_offset_unit == Unit.MODAL else modal_offset)
					fit_child_in_rect(c, Rect2(c_pos, size))
	elif what == NOTIFICATION_DRAW:
		if color.a > 0:
			draw_rect(Rect2(Vector2.ZERO, size), color)

## Handles backdrop clicked. See [member close_modal_on_clicked].
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if close_modal_on_clicked:
				close_modal()
			else:
				close_modal_requested.emit()
#endregion

#region Set and load
## Adds a node as modal. It stores initial properties to tween them after.
func set_modal(control: Control, state := State.CLOSE) -> void:
	if not control:
		control = null
		return
	
	if not control in get_children():
		if control.is_inside_tree():
			push_error("'control' already has other parent. Ensures it is not tree entered or its parent is this backdrop.")
		add_child(control)
	
	modal = control
	modal.visible = true
	_modal_process_mode = control.process_mode
	
	_modal_state = state
	if _modal_state == State.OPEN:
		_on_modal_opening()
		_on_modal_opened()
	else:
		_on_modal_closed()

## Instantiates a packed scene to use it as modal.
func set_modal_from_packed(packed: PackedScene, state := State.CLOSE) -> void:
	if not packed:
		push_error("'packed' is null.")
		return
	set_modal(packed.instantiate(), state)

## Loads a modal from packed scene path and opens when is loaded. Uses
## background loading with a loading progress bar.
## [b]Note:[/b] Progress bar is not added yet.
## @experimental
func open_modal_from_file(path: String) -> Error:
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
#endregion

#region Open and close
## Open child modal. Returns a tween if [member tween_duration] is positive.
func open_modal() -> Tween:
	if not modal:
		push_error("'modal' property is null.")
		return null
	
	if _modal_state == State.OPEN:
		push_warning("Modal is already opening.")
		return null
	
	if _tween and _tween.is_running():
		push_warning("Animation is playing.")
		return _tween
	
	_on_modal_opening()
	
	_tween = create_tween()
	_tween.parallel().tween_method(_set_open_progress, 0.0, 1.0, opening_duration)
	_tween.finished.connect(_on_modal_opened)
	
	return _tween

## Closes child modal.
func close_modal() -> Tween:
	if not modal:
		push_error("'modal' property is null.")
		return null
	
	if _modal_state == State.CLOSE:
		#push_warning("Modal is already closing.")
		return null
	
	if _tween and _tween.is_running():
		_tween.kill()
	
	_on_modal_closing()
	
	_tween = create_tween()
	_tween.tween_method(_set_open_progress, 1.0, 0.0, closing_duration / _modal_open_progress)
	_tween.finished.connect(_on_modal_closed)
	
	return _tween

## Sets open progress and properties.
func _set_open_progress(value: float) -> void:
	_modal_open_progress = value
	
	if tween_modal_opacity:
		modulate.a = value
	else:
		self_modulate.a = value
	
	if modal_offset != Vector2.ZERO:
		queue_sort()

## Called when modal is opening.
func _on_modal_opening() -> void:
	show()
	process_mode = _process_mode
	_modal_state = State.OPEN
	_set_open_progress(0)

## Called when modal is closing.
func _on_modal_closing() -> void:
	_modal_state = State.CLOSE

## Called when modal is opened.
func _on_modal_opened() -> void:
	_set_open_progress(1)

## Called when modal is closed.
func _on_modal_closed() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED if _process_mode != Node.PROCESS_MODE_ALWAYS else _process_mode
#endregion
