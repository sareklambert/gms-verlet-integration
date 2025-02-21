/// @function		VICollider(x, y);
/// @param {Real} x	The collider's x position.
/// @param {Real} y	The collider's y position.
/// @description	Base struct for colliders.
function VICollider(x, y) : VIObject() constructor {
	// Initialize "private" member vaiables
	// Do not change these values directly unless you know what you're doing!
	subtype = VI_SUBTYPE.COLLIDER;
	self.x = x;
	self.y = y;
	center = {x : x, y : y};
	shapeInverted = false;
	
	/// @function				SetInverted(invert);
	/// @param {Bool} invert	Wether or not to invert the shape.
	/// @description			Sets a flag for inverting the colliders shape.
	SetInverted = function(invert) {
		shapeInverted = invert;
	};
	
	/// @function			Collide(px, py);
	/// @param {Real} px	The x position to check.
	/// @param {Real} py	The y position to check.
	/// @description		Checks if the position is within the collider.
	Collide = function(px, py) {};
	
	/// @function		UpdateCenterPosition();
	/// @description	Updates the center position to the current position.
	UpdateCenterPosition = function() {
		center.x = x;
		center.y = y;
	};
	
	/// @function				Simulate(delta, grav, frict);
	/// @param {Real} delta		The delta time.
	/// @param {Real} grav		The gravity.
	/// @param {Real} frict		The friction.
	/// @description			Simulates this object.
	Simulate = function(delta, grav, frict) {
		// Make sure the object is active
		if (!active) exit;
		
		// Update center position
		UpdateCenterPosition();
		
		var pointAmount, currentPoint;
		
		// Iterate through system groups
		var groupAmount = ds_list_size(systemReference.objectList);
		var currentGroup;
		for (var i = 0; i < groupAmount; i++) {
			currentGroup = systemReference.objectList[| i];
			
			// Ignore non physicals
			if (currentGroup.subtype != VI_SUBTYPE.PHYSICAL) continue;
			
			// Iterate through points
			pointAmount = ds_list_size(currentGroup.pointList);
			for (var j = 0; j < pointAmount; j++) {
				currentPoint = currentGroup.pointList[| j];
				
				// Ignore points with no mass
				if (currentPoint.mass == 0) continue;
				
				// Ignore points outside the collider
				if (!Collide(currentPoint.position.current.x, currentPoint.position.current.y)) continue;
				
				// Get outwards direction
				var dir = point_direction(center.x, center.y, currentPoint.position.current.x, currentPoint.position.current.y) + (shapeInverted ? 180 : 0);
				
				// Try to reset to last position if it's not to far away
				if (point_distance(currentPoint.position.current.x, currentPoint.position.current.y, currentPoint.position.previous.x, currentPoint.position.previous.y) < 1 &&
					!Collide(currentPoint.position.previous.x, currentPoint.position.previous.y)) {
					currentPoint.position.current.x = currentPoint.position.previous.x;
					currentPoint.position.current.y = currentPoint.position.previous.y;
					continue;
				}
				
				// Push the point
				while (Collide(currentPoint.position.current.x, currentPoint.position.current.y)) {
					currentPoint.position.current.x += lengthdir_x(1, dir);
					currentPoint.position.current.y += lengthdir_y(1, dir);
				}
				
				// Approach collider to stabilize points
				while (!Collide(currentPoint.position.current.x - lengthdir_x(.1, dir), currentPoint.position.current.y - lengthdir_y(.1, dir))) {
					currentPoint.position.current.x -= lengthdir_x(.1, dir);
					currentPoint.position.current.y -= lengthdir_y(.1, dir);
				}
				
				// Reset previous position
				currentPoint.position.previous.x = currentPoint.position.current.x;
				currentPoint.position.previous.y = currentPoint.position.current.y;
			}
		}
	};
	
	/// @function		Draw();
	/// @description	Draws this object. Override.
	Draw = function() {};
};

/// @function				VIColliderSphere(x, y, radius);
/// @param {Real} x			The sphere collider's x position.
/// @param {Real} y			The sphere collider's y position.
/// @param {Real} radius	The sphere collider's radius.
/// @description			A spherical collider.
function VIColliderSphere(x, y, radius) : VICollider(x, y) constructor {
	// Save input parameters
	self.radius = radius;
	
	/// @function			Collide(px, py);
	/// @param {Real} px	The x position to check.
	/// @param {Real} py	The y position to check.
	/// @description		Checks if the position is within the collider.
	Collide = function(px, py) {
		return shapeInverted != point_in_circle(px, py, x, y, radius);
	};
	
	/// @function		DrawWireframe();
	/// @description	Draws this object as wireframe.
	DrawWireframe = function() {
		draw_circle(x, y, radius, true);
	};
};

/// @function				VIColliderBox(x, y, width, height);
/// @param {Real} x			The box collider's x position.
/// @param {Real} y			The box collider's y position.
/// @param {Real} width		The box collider's width.
/// @param {Real} height	The box collider's height.
/// @description			A box collider.
function VIColliderBox(x, y, width, height) : VICollider(x, y) constructor {
	// Save input parameters
	self.width = width;
	self.height = height;
	
	/// @function			Collide(px, py);
	/// @param {Real} px	The x position to check.
	/// @param {Real} py	The y position to check.
	/// @description		Checks if the position is within the collider.
	Collide = function(px, py) {
		return shapeInverted != point_in_rectangle(px, py, x, y, x + width, y + height);
	};
	
	/// @function		UpdateCenterPosition();
	/// @description	Updates the center position to the current position.
	UpdateCenterPosition = function() {
		center.x = x + width / 2;
		center.y = y + height / 2;
	};
	
	/// @function		DrawWireframe();
	/// @description	Draws this object as wireframe.
	DrawWireframe = function() {
		draw_rectangle(x, y, x + width, y + height, true);
	};
};

/// @function						VIColliderSprite(x, y, sprite);
/// @param {Real} x					The collider's x position.
/// @param {Real} y					The collider's y position.
/// @param {Asset.GMSprite} sprite	The collider's sprite.
/// @description					A sprite collider. Must be initialized before it works!
function VIColliderSprite(x, y, sprite) : VICollider(x, y) constructor {
	// Save input parameters
	self.sprite = sprite;
	
	// Sprite buffer variables
	initialized = false;
	buffer = noone;
	
	/// @function		Initialize();
	/// @description	Initializes the sprite collider. Must be called ONCE in any DRAW event!
	Initialize = function() {
		// Exit if the collider was already initialized
		if (initialized) exit;
		
		// Store sprite in surface
		var surface = surface_create(sprite_get_width(sprite), sprite_get_height(sprite), surface_r8unorm);
		surface_set_target(surface);
		draw_clear_alpha(c_black, 0);
		draw_sprite(sprite, 0, 0, 0);
		surface_reset_target();
		
		// Load surface into buffer
		buffer = buffer_create(sprite_get_width(sprite) * sprite_get_height(sprite), buffer_fast, 1);
		buffer_get_surface(buffer, surface, 0);
		
		// Delete surface
		surface_free(surface);
		
		// Set initialized flag
		initialized = true;
	};
	
	/// @function			Collide(px, py);
	/// @param {Real} px	The x position to check.
	/// @param {Real} py	The y position to check.
	/// @description		Checks if the position is within the collider.
	Collide = function(px, py) {
		// Exit if the collider was not initialized
		if (!initialized) return false;
		
		// Get local position
		var xx = floor(px - x);
		var yy = floor(py - y);
		
		// Prevent outside of buffer checks
		if (!point_in_rectangle(xx, yy, 0, 0, sprite_get_width(sprite), sprite_get_height(sprite))) return false;
		
		// Check for collisions
		return shapeInverted != (buffer_peek(buffer, yy * sprite_get_width(sprite) + xx, buffer_u8) != 0);
	};
	
	/// @function		UpdateCenterPosition();
	/// @description	Updates the center position to the current position.
	UpdateCenterPosition = function() {
		center.x = x + sprite_get_width(sprite) / 2;
		center.y = y + sprite_get_height(sprite)  / 2;
	};
	
	/// @function		DrawWireframe();
	/// @description	Draws this object as wireframe.
	DrawWireframe = function() {
		draw_sprite(sprite, 0, x, y);
		
		//for (var i = 0; i < sprite_get_width(sprite); i++) {
		//	for (var j = 0; j < sprite_get_height(sprite); j++) {
		//		if (Collide(i, j)) draw_point(x + i, y + j);
		//	}
		//}
	};
	
	/// @function		Draw();
	/// @description	Draws this object. Override.
	Draw = DrawWireframe;
	
	/// @function		Cleanup();
	/// @description	Destroys data structures.
	Cleanup = function() {
		if (buffer_exists(buffer)) buffer_delete(buffer);
	};
};
