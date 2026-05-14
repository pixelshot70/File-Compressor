extends Control

# Змінні для збереження шляху до обраного файлу
var selected_file_path = ""

# Посилання на вузли інтерфейсу (відповідно до твого дерева сцени)
@onready var add_button = $AddFileButton
@onready var download_button = $DownLoadButton
@onready var file_label = $FileLabel2 
@onready var option_target = $Option2 

func _ready():
	# Підключаємо сигнали кнопок
	add_button.pressed.connect(_on_add_file_pressed)
	download_button.pressed.connect(_on_download_pressed)
	
	# Початковий текст для мітки файлу
	file_label.text = "File not selected"

# Функція вибору файлу
func _on_add_file_pressed():
	var file_dialog = FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.use_native_dialog = true # Використовуємо вікно Windows 11
	
	file_dialog.file_selected.connect(func(path):
		selected_file_path = path
		file_label.text = path.get_file()
	)
	
	add_child(file_dialog)
	file_dialog.popup_centered(Vector2i(800, 600))

# Логіка натискання на кнопку завантаження
func _on_download_pressed():
	if selected_file_path == "":
		print("Error: Please select a file first!")
		return
	
	# Отримуємо розширення, яке вибрав користувач (png, jpg, mp3 тощо)
	# Беремо текст із вибраного пункту в OptionButton
	var target_ext = option_target.get_item_text(option_target.selected).to_lower()
	
	# Формуємо пропозицію імені файлу
	var suggested_name = selected_file_path.get_file().get_basename() + "." + target_ext
	
	var save_dialog = FileDialog.new()
	save_dialog.access = FileDialog.ACCESS_FILESYSTEM
	save_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	save_dialog.current_file = suggested_name
	save_dialog.use_native_dialog = true
	
	save_dialog.file_selected.connect(func(path):
		_process_and_save(selected_file_path, path, target_ext)
	)
	
	add_child(save_dialog)
	save_dialog.popup_centered(Vector2i(800, 600))

# Головна функція обробки файлу
func _process_and_save(old_path, new_path, extension):
	var error = OK
	
	# Якщо це зображення, робимо реальну конвертацію через Image
	if extension in ["png", "jpg", "jpeg"]:
		var img = Image.load_from_file(old_path)
		if img:
			if extension == "png":
				error = img.save_png(new_path)
			else:
				error = img.save_jpg(new_path)
		else:
			error = ERR_FILE_CANT_OPEN
			
	# Для інших форматів (mp3, mp4, svg, ico) робимо копіювання з перейменуванням
	# Справжня конвертація відео/аудіо в Godot потребує зовнішніх бібліотек (FFmpeg)
	else:
		var dir = DirAccess.open("C://") # Доступ до файлової системи
		error = dir.copy(old_path, new_path)
	
	if error == OK:
		print("Success! The file has been saved at the following path: ", new_path)
	else:
		print("An error occurred while saving: ", error)
