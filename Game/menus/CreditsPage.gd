extends Panel


@onready var main_menu = owner

@export var credits_label: RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	credits_label.push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
	credits_label.append_text("Third party licenses:\n")
	credits_label.append_text(Engine.get_license_text())
	credits_label.append_text('\n\nVoxel Tools for Godot Engine
--------------------------------

Copyright (c) 2016-2022 Marc Gilleron

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
')
	credits_label.pop()


func _on_back_button_pressed():
	main_menu.change_page_to(main_menu.main_page)
