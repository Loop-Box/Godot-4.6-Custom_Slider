
extends Line2D

@export var BG:Line2D
@export var Pointer:Node2D
@export var Distance_To_Move:float = 8.0
var Last_Position:Vector2 = Vector2.ZERO

var Total_Length:float = 0.0

@export_category("Value")
@export_range(0.0,100.0,0.1) var Start_Value:float
@export var Target_Node:Node
@export var Target_Var:String
@export var Label_:Label

func _ready() -> void:
	BG.points = points
	Total_Length = Calculate_Total_Length()
	Update_Value(Start_Value / 100.0)

func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("Left_Click"):
		Check_Distance()

func Check_Distance() -> void:
	var Mouse_Pos:Vector2 = get_global_mouse_position()
	var Check_Value = Get_Closest_Point_On_Line(Mouse_Pos)
	if Check_Value.get("Distance") > Distance_To_Move:
		return
	
	var Change:float = Check_Value.get("Length") / Total_Length
	
	
	Update_Value(Change)

func Update_Value(New_Value:float) -> void:
	
	var New_Position:Vector2 = Get_Point_At_Value(New_Value)
	
	if Last_Position != Vector2.ZERO:
		if New_Position.distance_to(Last_Position) > Distance_To_Move:
			return
	
	Last_Position = New_Position
	Pointer.global_position = to_global(New_Position)
	
	(texture as GradientTexture1D).gradient.set_offset(1,New_Value)
	
	if Target_Node:
		Target_Node.set(Target_Var,New_Value)
	
	var Percent_Value:float = New_Value * 100.0
	Label_.text = "%.2f%%" % Percent_Value




func Calculate_Total_Length() -> float:
	var Points:PackedVector2Array = points
	var Length:float = 0.0
	
	for Index:int in range(Points.size() - 1):
		Length += Points[Index].distance_to(Points[Index + 1])
	
	return Length

func Get_Point_At_Value(Value:float) -> Vector2:
	var Target_Length:float = Value * Total_Length
	return Get_Point_At_Length(Target_Length)

func Get_Point_At_Length(Target_Length: float) -> Vector2:
	var Points: PackedVector2Array = points
	var Accumulated_Length: float = 0.0

	for Index in range(Points.size() - 1):
		var A:Vector2 = Points[Index]
		var B:Vector2 = Points[Index + 1]

		var Segment_Length: float = A.distance_to(B)

		if Accumulated_Length + Segment_Length >= Target_Length:
			var Local_T: float = (Target_Length - Accumulated_Length) / Segment_Length
			return A.lerp(B, Local_T)

		Accumulated_Length += Segment_Length

	return Points[Points.size() - 1]

func Get_Closest_Point_On_Line(Mouse_Pos: Vector2) -> Dictionary:
	var Best_Point: Vector2 = Vector2.ZERO
	var Best_Distance: float = INF

	var Points: PackedVector2Array = points

	var Best_Length: float = 0.0
	var Running_Length: float = 0.0
	
	for Index in range(Points.size() - 1):
		var A: Vector2 = to_global(Points[Index])
		var B: Vector2 = to_global(Points[Index + 1])

		var AB: Vector2 = B - A
		var AP: Vector2 = Mouse_Pos - A

		var Segment_Length: float = AB.length()
		
		var Local_T: float = clamp(AP.dot(AB) / AB.length_squared(), 0.0, 1.0)
		var Closest: Vector2 = lerp(A, B, Local_T)

		var Distance: float = Mouse_Pos.distance_to(Closest)

		if Distance < Best_Distance:
			Best_Distance = Distance
			Best_Point = Closest
			Best_Length = Running_Length + (Segment_Length * Local_T)

		Running_Length += Segment_Length

	return {
		"Point": Best_Point,
		"Distance": Best_Distance,
		"Length": Best_Length,
		"Total_Length": Total_Length
	}
