/// @function				VIForcefield(x, y, radius);
/// @param {Real} x			The x position of the field.
/// @param {Real} y			The y position of the field.
/// @param {Real} radius	The radius of the field.
/// @description			Base struct for force fields.
function VIForcefield(x, y, radius) : VIObject() constructor {
	// Initialize "private" member vaiables
	// Do not change these values directly unless you know what you're doing!
	subtype = VI_SUBTYPE.FORCEFIELD;
	self.x = x;
	self.y = y;
	self.radius = radius;
	
	/// @function		DrawWireframe();
	/// @description	Draws this object as wireframe.
	DrawWireframe = function() {
		draw_circle(x, y, radius, true);
	};
	
	/// @function		Draw();
	/// @descriptiocccn	Draws this object. Override.
	Draw = function() {};
};

/// @function				VIForcefieldWind(x, y, radius, dir, str, spd);
/// @param {Real} x			The x position of the field.
/// @param {Real} y			The y position of the field.
/// @param {Real} radius	The radius of the field.
/// @param {Real} dir		The direction of the field.
/// @param {Real} str		The strength of the field.
/// @param {Real} spd		The speed of how fast the wind direction changes.
/// @description			Accelerates points in the wind direction in a waving motion.
function VIForcefieldWind(x, y, radius, dir, str, spd) : VIForcefield(x, y, radius) constructor {
	// Save input parameters
	self.dir = dir;
	self.str = str;
	self.spd = spd;
	strStart = str;
	
	/// @function				Simulate(delta, grav, frict);
	/// @param {Real} delta		The delta time.
	/// @param {Real} grav		The gravity.
	/// @param {Real} frict		The friction.
	/// @description			Simulates this object.
	Simulate = function(delta, grav, frict) {
		// Make sure the object is active
		if (!active) exit;
		
		// Update strength
		str = VIMathWave(0, strStart, spd, 0);
		
		var objectAmount = ds_list_size(systemReference.objectList);
		var currentObject, pointAmount, currentPoint, len;
		for (var i = 0; i < objectAmount; i++) {
			currentObject = systemReference.objectList[| i];
			
			// Ignore non physicals
			if (currentObject.subtype != VI_SUBTYPE.PHYSICAL) continue;
			
			// Push points
			pointAmount = ds_list_size(currentObject.pointList);
			for (var j = 0; j < pointAmount; j++) {
				currentPoint = currentObject.pointList[| j];
				
				// Ignore deleted points
				if (currentPoint.state == VI_POINT_STATE.DELETED) continue;
				
				if (point_in_circle(currentPoint.position.current.x, currentPoint.position.current.y, x, y, radius)) {
					len = str / currentPoint.mass;
					currentPoint.position.previous.x -= lengthdir_x(len, dir) * delta;
					currentPoint.position.previous.y -= lengthdir_y(len, dir) * delta;
				}
			}
		}
	};
	
	// Override draw functions
	/// @function		DrawWireframe();
	/// @description	Draws this object as wireframe.
	DrawWireframe = function() {
		var len = (str / strStart) * radius;
		
		draw_circle(x, y, radius, true);
		draw_line_width(x, y, x + lengthdir_x(len, dir), y + lengthdir_y(len, dir), 1);
	};
};

/// @function				VIForcefieldAttract(x, y, radius, str);
/// @param {Real} x			The x position of the field.
/// @param {Real} y			The y position of the field.
/// @param {Real} radius	The radius of the field.
/// @param {Real} str		The strength of the field.
/// @description			Attracts points in the field towards its center.
function VIForcefieldAttract(x, y, radius, str) : VIForcefield(x, y, radius) constructor {
	// Save input parameters
	self.str = str;
	
	/// @function				Simulate(delta, grav, frict);
	/// @param {Real} delta		The delta time.
	/// @param {Real} grav		The gravity.
	/// @param {Real} frict		The friction.
	/// @description			Simulates this object.
	Simulate = function(delta, grav, frict) {
		// Make sure the object is active
		if (!active) exit;
		
		var objectAmount = ds_list_size(systemReference.objectList);
		var currentObject, pointAmount, currentPoint;
		for (var i = 0; i < objectAmount; i++) {
			currentObject = systemReference.objectList[| i];
			
			// Ignore non physicals
			if (currentObject.subtype != VI_SUBTYPE.PHYSICAL) continue;
			
			// Attract points
			pointAmount = ds_list_size(currentObject.pointList);
			for (var j = 0; j < pointAmount; j++) {
				currentPoint = currentObject.pointList[| j];
				
				// Ignore deleted points
				if (currentPoint.state == VI_POINT_STATE.DELETED) continue;
				
				if (point_in_circle(currentPoint.position.current.x, currentPoint.position.current.y, x, y, radius)) {
					dir = point_direction(currentPoint.position.current.x, currentPoint.position.current.y, x, y);
					
					currentPoint.position.previous.x -= lengthdir_x(str, dir) * delta;
					currentPoint.position.previous.y -= lengthdir_y(str, dir) * delta;
				}
			}
		}
	};
};

/// @function				VIForcefieldDelete(x, y, radius);
/// @param {Real} x			The x position of the field.
/// @param {Real} y			The y position of the field.
/// @param {Real} radius	The radius of the field.
/// @description			Deletes all points within the field.
function VIForcefieldDelete(x, y, radius) : VIForcefield(x, y, radius) constructor {
	/// @function				Simulate(delta, grav, frict);
	/// @param {Real} delta		The delta time.
	/// @param {Real} grav		The gravity.
	/// @param {Real} frict		The friction.
	/// @description			Simulates this object.
	Simulate = function(delta, grav, frict) {
		// Make sure the object is active
		if (!active) exit;
		
		var objectAmount = ds_list_size(systemReference.objectList);
		var currentObject, pointAmount, currentPoint;
		for (var i = 0; i < objectAmount; i++) {
			currentObject = systemReference.objectList[| i];
			
			// Ignore non physicals
			if (currentObject.subtype != VI_SUBTYPE.PHYSICAL) continue;
			
			// Delete points
			pointAmount = ds_list_size(currentObject.pointList);
			for (var j = pointAmount - 1; j >= 0; j--) {
				currentPoint = currentObject.pointList[| j];
				
				// Ignore deleted points
				if (currentPoint.state == VI_POINT_STATE.DELETED) continue;
				
				if (point_in_circle(currentPoint.position.current.x, currentPoint.position.current.y, x, y, radius)) {
					currentObject.DeletePoint(j);
				}
			}
		}
	};
};
