extends KinematicBody2D

var bulletTscn = preload("res://scenes/Bullet.tscn")

const weapons = {
	"pistol":{
		"fire_rate": 0.75,
		"damage": 50
	},
	"laser gun":{
		"fire_rate": 0.2,
		"damage": 50
	}
}

var enabled_weapons
var current_weapon
const shoot_speed = 500
const bullet_range = 50000
var fire_ready = 0

var velocity

var dead

var max_life
var life

var devil_hearts
var devil_eyes
var devil_shoes


var shoot_postition
func _ready():
	# Init vars
	dead = false
	max_life = 5000
	life = max_life
	
	enabled_weapons = ["pistol"]
	current_weapon = weapons["pistol"]
	
	velocity = 350
	
	devil_hearts = 0
	devil_eyes = 0
	devil_shoes = 0
	
	self.shoot_postition = self.get_node("Sprite/weapon_sprite/ShotPosition")
	set_process_input(true)
	set_fixed_process(true)

func _fixed_process(delta):
	set_player_orientation()
	self.fire_ready -= delta
	if self.fire_ready < 0:
		self.fire_ready = 0
	
	var vect = Vector2(0,0)
	
	if Input.is_action_pressed("ui_up") :
		vect.y = -1
	if Input.is_action_pressed("ui_down") :
		vect.y = 1
	if Input.is_action_pressed("ui_right") :
		vect.x = 1
	if Input.is_action_pressed("ui_left") :
		vect.x = -1
	
	var motion = vect.normalized() * velocity * delta
	self.move(motion)
	
	if is_colliding() :
		var n = get_collision_normal()
		motion = n.slide(motion)
		vect = n.slide(vect)
		move(motion)
	if Input.is_action_pressed("action_shoot"):
		_shoot_arrow(delta)

func _shoot_arrow(delta):
	if self.fire_ready == 0:
		self.fire_ready = self.current_weapon["fire_rate"]
		var bullet_motion = (get_global_mouse_pos() - self.shoot_postition.get_global_pos()).normalized() * shoot_speed
		var new_arrow = bulletTscn.instance()
		var arrow_rotation = get_angle_to(get_global_mouse_pos()) + self.get_rot()
		new_arrow.set_rot(arrow_rotation)
		var weapon = find_node("ShotPosition")
		new_arrow.set_global_pos(weapon.get_global_pos())
		get_parent().bullerHolder.add_child(new_arrow)
		get_node("SamplePlayer").play("laser")
		new_arrow.init_bullet(bullet_motion, self.current_weapon["damage"], self.bullet_range )

func set_player_orientation():
	var self_pos = self.get_pos()
	var mouse_pos = self.get_global_mouse_pos()
	var dif = self_pos - mouse_pos
	if dif.x > 0:
		self.set_scale(Vector2(-1, 1))
	else :
		self.set_scale(Vector2(1, 1))
	
func take_damage(collider_pos, damage_amount):
	var direction = get_pos() - collider_pos
	life -= damage_amount
	
	if self.life <= 0 and !self.dead:
		self.dead = true
		self.play_animation("death")
		return
		
	if life > 0:
		self.move(direction.normalized() * 50)
		get_node("SamplePlayer").play("takeDamage")
		play_animation("take_damage")

func add_weapon(weapons) :
	for w in weapons :
		enabled_weapons.append(w["name"])
		max_life *= (100.0 - float(w["heart_malus"])) / 100.0
		devil_hearts -= w["heart_malus"]
		
		# TODO : Precision
		devil_eyes -= w["eye_malus"]
		
		velocity *= (100.0 - float(w["shoe_malus"])) / 100.0
		devil_shoes -= w["shoe_malus"]

# Helper to play animation
func play_animation(animation):
	self.get_node("AnimationPlayer").play(animation)
	