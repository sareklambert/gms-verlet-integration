/// @function						VIRope(x, y, length, pointAmount, stiffness, tearThreshold);
/// @param {Real} x					The rope's x position.
/// @param {Real} y					The rope's y position.
/// @param {Real} length			The rope's length.
/// @param {Real} pointAmount		How many points the rope should have.
/// @param {Real} stiffness			The amount of iterations the sticks try to correct their positions.
/// @param {Real} tearThreshold		The threshold of overstretching before the sticks breaks. (-1 to disable tearing).
/// @description					Base struct for ropes.
function VIRope(x, y, length, pointAmount, stiffness, tearThreshold) : VIPhysical(stiffness) constructor {
	// Save input parameters
	self.pointAmount = pointAmount;
	
	// Create points and sticks
	var currentPoint;
	for (var i = 0; i < pointAmount; i++) {
		AddPoint(x, y + i * length / (pointAmount - 1), 1);
		if (i > 0) AddStick(pointList[| i - 1], pointList[| i], length / (pointAmount - 1), tearThreshold);
		
		// Set up a chain of previous points
		// This is used for connector rotations
		currentPoint = pointList[| i];
		if (i > 0) {
			currentPoint.previousPoint = pointList[| i - 1];
		}
	}
	
	// Add functions for locking points
	/// @function		LockFirstPoint();
	/// @description	Locks the first point.
	LockFirstPoint = function() {
		pointList[| 0].mass = 0;
	}
};

/// @function						VIRopeColored(x, y, length, pointAmount, color, tickness, stiffness, tearThreshold);
/// @param {Real} x					The rope's x position.
/// @param {Real} y					The rope's y position.
/// @param {Real} length			The rope's length.
/// @param {Real} pointAmount		How many points the rope should have.
/// @param {Constant.Color} color	The rope's color.
/// @param {Real} thickness			The rope's thickness.
/// @param {Real} stiffness			The amount of iterations the sticks try to correct their positions.
/// @param {Real} tearThreshold		The threshold of overstretching before the sticks breaks. (-1 to disable tearing).
/// @description					A colored rope.
function VIRopeColored(x, y, length, pointAmount, color, thickness, stiffness, tearThreshold) : VIRope(x, y, length, pointAmount, stiffness, tearThreshold) constructor {
	// Save input parameters
	self.color = color;
	self.thickness = thickness;
	
	// Override draw function
	Draw = function () {
		// Exit if the object is not visible
		if (!visible) exit;
		
		draw_set_color(color);
		
		var stickAmount = ds_list_size(stickList);
		var currentStick;
		for (var i = 0; i < stickAmount; i++) {
			currentStick = stickList[| i];
			
			draw_line_width_color(currentStick.p1.position.current.x, currentStick.p1.position.current.y, currentStick.p2.position.current.x, currentStick.p2.position.current.y, thickness, color, color);
		}
		
		draw_set_color(c_white);
	};
};

/// @function						VIRopeTextured(x, y, length, pointAmount, sprite, stiffness, tearThreshold);
/// @param {Real} x					The rope's x position.
/// @param {Real} y					The rope's y position.
/// @param {Real} length			The rope's length.
/// @param {Real} pointAmount		How many points the rope should have.
/// @param {Asset.GMSprite} sprite	The rope's sprite.
/// @param {Real} stiffness			The amount of iterations the sticks try to correct their positions.
/// @param {Real} tearThreshold		The threshold of overstretching before the sticks breaks. (-1 to disable tearing).
/// @description					A rope drawn using a texture.
function VIRopeTextured(x, y, length, pointAmount, sprite, stiffness, tearThreshold) : VIRope(x, y, length, pointAmount, stiffness, tearThreshold) constructor {
	// Save input parameters
	self.sprite = sprite;
	
	// Override draw function
	Draw = function () {
		// Exit if the object is not visible
		if (!visible) exit;
		
		var texture = sprite_get_texture(sprite, 0);
		var swHalf = sprite_get_width(sprite) / 2;
		var dir;
		
		var rotationLeftX, rotationLeftY;
		var rotationRightX, rotationRightY;
		var offsetX, offsetY;
		
		var stickAmount = ds_list_size(stickList);
		var currentStick;
		for (var i = 0; i < stickAmount; i++) {
			currentStick = stickList[| i];
			
			dir = point_direction(currentStick.p1.position.current.x, currentStick.p1.position.current.y, currentStick.p2.position.current.x, currentStick.p2.position.current.y);
			
			rotationLeftX = lengthdir_x(swHalf, dir - 90);
			rotationLeftY = lengthdir_y(swHalf, dir - 90);
			rotationRightX = lengthdir_x(swHalf, dir + 90);
			rotationRightY = lengthdir_y(swHalf, dir + 90);
			offsetX = lengthdir_x(sprite_get_yoffset(sprite), dir + 180);
			offsetY = lengthdir_y(sprite_get_yoffset(sprite), dir + 180);
			
			draw_primitive_begin_texture(pr_trianglestrip, texture);
			draw_vertex_texture(currentStick.p1.position.current.x + rotationLeftX + offsetX, currentStick.p1.position.current.y + rotationLeftY + offsetY, 0, 0);
			draw_vertex_texture(currentStick.p1.position.current.x + rotationRightX + offsetX, currentStick.p1.position.current.y + rotationRightY + offsetY, 1, 0);
			draw_vertex_texture(currentStick.p2.position.current.x + rotationLeftX, currentStick.p2.position.current.y + rotationLeftY, 0, 1);
			draw_vertex_texture(currentStick.p2.position.current.x + rotationRightX, currentStick.p2.position.current.y + rotationRightY, 1, 1);
			draw_primitive_end();
		}
	};
};
