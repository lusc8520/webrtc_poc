@tool
class_name mt
extends Node

@export var mesh: ArrayMesh
@export var mesh2: ArrayMesh

@export var gen: bool:
	set(v):
		generate()
	get:
		return false
		
func generate() -> void:
	if (mesh == null):
		return
	var st := SurfaceTool.new()
	st.create_from(mesh, 0)
	st.index()
	st.generate_normals()
	mesh2 = st.commit()
