extends Node2D

var time : float
@export var day_length : float = 200.0
@export var start_time : float = 0.3
var time_rate : float

# sun
var sun : DirectionalLight2D
@export var sun_color : Gradient 
@export var sun_intensity : Curve
var sunSprite : AnimatedSprite2D
#var sunLight : PointLight2D
# moon
var moon : DirectionalLight2D
@export var moon_color : Gradient 
@export var moon_intensity : Curve
var moonLight : PointLight2D

# sky (this didn't work, but leaving it here in case) 
var environment : ColorRect
@export var sky_top_color : Gradient
@export var sky_horizon_color : Gradient 

# SKY TEXTURE INTERPOLATION
# ===========================================
@export var tex_day : Texture2D
@export var tex_sunset : Texture2D
@export var tex_night : Texture2D

# set sky textureRect
@onready var canvas : CanvasLayer = get_node("CanvasLayer")
@onready var day_rect : TextureRect = canvas.get_node("dayRect")
@onready var night_rect : TextureRect = canvas.get_node("nightRect")
@onready var sunset_rect : TextureRect = canvas.get_node("sunsetRect")

# set sun/moon sprites
@onready var sun_sprite : Node2D = get_node("CanvasLayer/sunPath/sunFollow/sunSprite")
@onready var moon_sprite : Node2D = get_node("CanvasLayer/moonPath/moonSprite")

# sun/moon follow spline
@onready var sun_follow: PathFollow2D = get_node("CanvasLayer/sunPath/sunFollow")
@onready var moon_follow: PathFollow2D = get_node("CanvasLayer/moonPath/moonFollow")
@onready var sunLight : PointLight2D = get_node("CanvasLayer/sunPath/sunFollow/sunSprite/sunLight")

# sun/moon sprite sky relativity config 
@export var sky_center : Vector2 = Vector2(300, 90) 
@export var sky_radius : Vector2 = Vector2(240, 100)
@export var sun_arc_center_angle : float = 50.0
@export var sun_arc_span : float = 180.0
@export var moon_arc_span : float = 180.0
@export var moon_radius : Vector2 = Vector2(600, 250)
@export var moon_arc_center_angle : float = 220.0
# day/night background time configuration
@export_range(0.0, 1.0) var sunrise_start := 0.13
@export_range(0.0, 1.0) var sunrise_end   := 0.30
@export_range(0.0, 1.0) var sunset_start  := 0.62
@export_range(0.0, 1.0) var sunset_end    := 0.78


var tween : Tween
# ===========================================

# DAY COUNT 
# ===========================================
var yearDay : int # for tracking season progression
var totalDay : int # for tracking total days survived
# ===========================================

# WEATHER
@export var yearWeatherChance : Curve
var weatherChanceMultiplier : float = 0.001

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0, 0, 0, 0)) # transparent
	
	time_rate = 1.0 / day_length
	time = start_time
	sun = get_node("Sun")
	moon = get_node("Moon")
	environment = get_node("ColorRect")
	
	day_rect.modulate.a = 0.0
	sunset_rect.modulate.a = 0.0
	night_rect.modulate.a = 1.0
	_update_sky(time)
	
	sun_sprite.play("shine")
func set_sky(texture: Texture2D, fade_time : float = 1.0) -> void:
	var back := night_rect
	var front := day_rect # assume day_rect is the front one initially 
	
	back.texture = texture
	back.modulate.a = 0.0
	
	if tween : tween.kill()
	tween = create_tween()
	tween.tween_property(front, "modulate:a", 0.0, fade_time)
	tween.tween_property(back, "modulate:a", 1.0, fade_time)

func _fade(a: float, b: float, t: float) -> float:
	if b <= a:
		return 1.0 if t >= b else 0.0
	return clamp((t-a) / (b-a), 0.0, 1.0)

func fract(x: float) -> float:
		return x - floor(x)
		
func _update_sky(t: float) -> void:
	# normalize t to 0..1 (safety)
	t = wrapf(t, 0.0, 1.0)

	# day: full between sunrise_end and sunset_start
	# night: full outside those
	# sunset: only in the transition windows

	var alpha_sunrise := _fade(sunrise_start, sunrise_end, t) # 0->1
	var alpha_sunset  := 1.0 - _fade(sunset_start, sunset_end, t) # 1->0 (reversed)

	var alpha_day: float = clamp(alpha_sunrise * alpha_sunset, 0.0, 1.0)

	# night is the complement of day 
	var alpha_night: float = clamp(1.0 - alpha_day, 0.0, 1.0)

	# sunset only peeks during both transition regions
	var alpha_sunset_peek: float = max(
		_fade(sunrise_end, sunrise_end + 0.08, t),
		_fade(sunset_end - 0.08, sunset_end, t)
	)
	# do not exceed total visibility
	alpha_sunset_peek = clamp(alpha_sunset_peek * (1.0 - abs(alpha_day - 0.5) * 2.0), 0.0, 1.0)

	# blending day and night
	var alpha_sunset2: float = clamp(
		(1.0 - _fade(sunrise_end, sunrise_end, t)) * 0.0, # placeholder (kept for clarity)
		0.0, 1.0
	)

	# use sunset as the leftover between day/night
	#var alpha_sunset_final: float = clamp(1.0 - (alpha_day + alpha_night), 0.0, 1.0)

	# If you want sunset to actually show (not just leftover), uncomment this instead:
	var alpha_sunset_final: float = clamp(1.0 - abs(alpha_day - 0.5) * 2.0, 0.0, 1.0)

	day_rect.modulate.a = alpha_day
	night_rect.modulate.a = alpha_night
	sunset_rect.modulate.a = alpha_sunset_final

func _arc_pos(t: float, center_angle_deg: float, span_deg: float) -> Vector2:
	var angle_deg := -1*(center_angle_deg + (t-0.5) * span_deg)
	var angle := deg_to_rad(angle_deg) # convert degrees to radians
	print(angle_deg)
	print(angle)
	return sky_center + Vector2(cos(angle) * sky_radius.x, -sin(angle) * sky_radius.y)	

# WEATHER FUNCTIONS
# ==========================================================================
func weatherChance(yearlyChance: float, weatherChanceMultiplier: float):
	var rng = RandomNumberGenerator.new()
	var random_value = rng.randf_range(0, 1) * weatherChanceMultiplier
	if random_value >= yearlyChance :
		print("rain today")
		return true
	else: 
		return false
# ==========================================================================

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += time_rate * delta
	
	# sun stuff
	sun.color = sun_color.sample(time)
	sun.energy = sun_intensity.sample(time)
	sun.rotation_degrees = time * 360 + 90 	# rotate sun
	sun.visible = sun.energy > 0
	sunLight.color = sun_color.sample(time)
	
	# moon stuff
	moon.color = moon_color.sample(time)
	moon.energy = moon_intensity.sample(time)
	moon.rotation_degrees = time * 360 + 270 # rotate moon
	moon.visible = moon.energy > 0
	
	# environment stuff
	#environment.environment.sky.sky_material.set("sky_top_color", sky_top_color.sample(time))
	#environment.environment.sky.sky_material.set("sky_horizon_color", sky_horizon_color.sample(time))

	# DAY MANAGEMENT
	if time >= 1.0: # loop into the next day
		time = 0.0
		
		# season tracking
		yearDay = (yearDay + 1) / 365 # normalize 0..1
		if yearDay > 1:
			yearDay = 0
			
	totalDay = totalDay + 1 # add to total days survived counter
	
	#var sun_pos := _arc_pos(time, sun_arc_center_angle, sun_arc_span)
	#var moon_pos := _arc_pos(time, moon_arc_center_angle, moon_arc_span)
	#print(sun_pos)
	#sun_sprite.position = sun_pos
	#moon_sprite.position = moon_pos
	# time is 0..1 over a day
	#if(time > sunrise_start && time < sunset_end) :
	sun_follow.progress_ratio = (1-time-0.25)
	#else :
	moon_follow.progress_ratio = fract((1-time) + 0.5-0.25) # opposite phase

	# simple "below horizon" hide
	#var sun_t := (sun_pos.y - sky_center.y) / sky_radius.y
	#var moon_t := (moon_pos.y - sky_center.y) / moon_radius.y
	#sun_sprite.visible = sun_t > 0.0
	#moon_sprite.visible = moon_t > 0.0
	weatherChance(yearWeatherChance.sample(yearDay),weatherChanceMultiplier) # calculate chance of weather event

	_update_sky(time)
