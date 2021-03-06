extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn");

export var ACCELERATION = 300;
export var MAX_SPEED = 50;
export var FRICTION = 200;

enum {
	IDLE,
	WANDER,
	CHASE,
	ATTACK
}

var velocity = Vector2.ZERO;
var knockback = Vector2.ZERO;
var state = CHASE;

onready var animationPlayer = $AnimationPlayer;
onready var animationTree = $AnimationTree;
onready var animationState = animationTree.get("parameters/playback");
onready var sprite = $Sprite;
onready var stats = $Stats;
onready var playerDetectionZone = $PlayerDetectionZone;

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE;

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta);
	knockback = move_and_slide(knockback);
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta);
			seek_player();
		
		WANDER:
			pass
		
		ATTACK:
			var player = playerDetectionZone.player;
			if player != null:
				var direction = (player.global_position - global_position).normalized();
				animationTree.set("parameters/Attack/blend_position", direction);
				animationState.travel("Attack");
				
			else:
				state = IDLE;
		
		CHASE:
			var player = playerDetectionZone.player;
			if player != null:
				var direction = (player.global_position - global_position).normalized();
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta);
				animationTree.set("parameters/Run/blend_position", direction);
				animationState.travel("Run");
				#if :
					#state = ATTACK;
			else:
				state = IDLE;
	velocity = move_and_slide(velocity)


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage;
	knockback = area.knockback_vector * 100;


func _on_Stats_no_health():
	queue_free();
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect);
	enemyDeathEffect.global_position = global_position;
