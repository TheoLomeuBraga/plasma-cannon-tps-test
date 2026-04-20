@tool
extends Node3D

@export var legs_ik : RemoteTransform3D
@export var torso_ik : RemoteTransform3D

@onready var skeleton : Skeleton3D = %GeneralSkeleton

@onready var target_legs : Node3D = $target_legs
@onready var target_torso : Node3D = $target_torso

@onready var hands_base : Node3D = $arm_ik_r/hands_base
@onready var animation_tree : AnimationTree = $AnimationTree

@onready var arm_r_ik : Array[SkeletonModifier3D] = [
	$metarig/GeneralSkeleton/TwoBoneIK3D_hand_r,
	$metarig/GeneralSkeleton/CopyTransformModifier3D_hand_r
	]

var gun_estate_tween : Tween
var gun_estate : float :
	set(value):
		gun_estate = value
		
		for ik : SkeletonModifier3D in arm_r_ik:
			if ik != null:
				ik.influence = value
				print("ok\n")

enum Estate {RUN,AIR,RUN_GUN,AIR_GUN}
@export var estate : Estate = Estate.RUN :
	set(value):
		estate = value
		if animation_tree != null:
			
			gun_estate_tween = create_tween()
			
			if value == Estate.RUN:
				animation_tree.set("parameters/player_estate/transition_request","run")
				gun_estate_tween.tween_property(self,"gun_estate",0.0,0.2)
			if value == Estate.AIR:
				animation_tree.set("parameters/player_estate/transition_request","air")
				gun_estate_tween.tween_property(self,"gun_estate",0.0,0.2)
			if value == Estate.RUN_GUN:
				animation_tree.set("parameters/player_estate/transition_request","run_gun")
				gun_estate_tween.tween_property(self,"gun_estate",1.0,0.2)
			if value == Estate.AIR_GUN:
				animation_tree.set("parameters/player_estate/transition_request","air_gun")
				gun_estate_tween.tween_property(self,"gun_estate",1.0,0.2)

@export_range(0.0,1.0) var run_speed : float = 0 : 
	set(value):
		run_speed = value
		if animation_tree != null:
			animation_tree.set("parameters/run_speed/blend_position",value)
			animation_tree.set("parameters/run_gun_speed/blend_position",value)


func _ready() -> void:
	if legs_ik != null:
		target_legs.remote_path = legs_ik.get_path()
		
	if torso_ik != null:
		target_torso.remote_path = torso_ik.get_path()

func _process(delta: float) -> void:
	
	hands_base.look_at(target_torso.global_position)
