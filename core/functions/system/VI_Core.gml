/// @function			VISystem(frict, grav);
/// @param {Real} frict	The system's friction.
/// @param {Real} grav	The system's gravity.
/// @description		System struct.
function VISystem(frict, grav) constructor {
	// Initialize "private" member vaiables
	// Do not change these values directly unless you know what you're doing!
	type = VI_TYPE.SYSTEM;
	active = true;
	visible = true;
	objectList = ds_list_create();
	
	self.frict = frict;
	self.grav = grav;
	
	/// @function				SetActive(active);
	/// @param {Bool} active	Active flag.
	/// @description			Sets whether or not the system is active (simulating) or not.
	SetActive = function(active) {
		self.active = active;
	};
	
	/// @function				SetVisible(visible);
	/// @param {Bool} visible	Visible flag.
	/// @description			Sets whether or not the system is visible (drawing) or not.
	SetVisible = function(visible) {
		self.visible = visible;
	};
	
	/// @function				AddObject(object);
	/// @param {Struct} object	The object to add.
	/// @description			Adds an object to the objects list.
	AddObject = function(object) {
		ds_list_add(objectList, object);
		object.systemReference = self;
	};
	
	/// @function				GetDistance(xx, yy, precise);
	/// @param {Real} xx		The x position to measure from.
	/// @param {Real} yy		The y position to measure from.
	/// @param {Bool} precise	Wether or not to use precise measurements. Be careful with this, precise measurements can be very resource intensive!
	/// @description			Returns the distance to the system.
	/// @return {Bool}
	GetDistance = function(xx, yy, precise) {
		// Check all objects of the system
		var objectAmount = ds_list_size(objectList);
		var currentObject;
		
		for (var i = 0; i < objectAmount; i++) {
			// Get next object
			currentObject = objectList[| i];
			
			// Skip if the object is not valid
			if (!VIObjectExists(currentObject)) continue;
			
			// Check if the object is within bounds
			if (currentObject.GetDistance(xx, yy, precise)) return true;
		}
		
		// No objects were in range, return false
		return false;
	};
	
	/// @function			Simulate(delta);
	/// @param {Real} delta	The delta time.
	/// @description		Simulates all objects of this system.
	Simulate = function(delta) {
		// Exit if the system is not active
		if (!active) exit;
		
		// Simulate all objects of the system
		var objectAmount = ds_list_size(objectList);
		var currentObject;
		
		for (var i = objectAmount - 1; i >= 0; i--) {
			// Get next object
			currentObject = objectList[| i];
			
			// Skip if the object is not valid or not active
			if (!VIObjectExists(currentObject) || !currentObject.active) continue;
			
			// Delete the object if there are no more sticks left
			if (currentObject.subtype == VI_SUBTYPE.PHYSICAL && ds_list_empty(currentObject.stickList)) {
				ds_list_delete(objectList, i);
				continue;
			}
			
			// Simulate the object, pass system settings
			currentObject.Simulate(delta, grav, frict);
		}
	};
	
	/// @function				Draw(wireframe);
	/// @param {Bool} wireframe	Whether or not to use wireframe drawing or not.
	/// @description			Draws all objects of this system.
	Draw = function(wireframe) {
		// Exit if the system is not visible
		if (!visible) exit;
		
		// Draw all objects of the system
		var objectAmount = ds_list_size(objectList);
		var currentObject;
		
		for (var i = 0; i < objectAmount; i++) {
			// Get next object
			currentObject = objectList[| i];
			
			// Skip if the object is not valid or not visible
			if (!VIObjectExists(currentObject) || !currentObject.visible) continue;
			
			// Draw the object
			if (wireframe) {
				currentObject.DrawWireframe();
			} else {
				currentObject.Draw();
			}
		};
		
	};
	
	/// @function		Cleanup();
	/// @description	Performs cleanup for all objects of this system.
	Cleanup = function() {
		var objectAmount = ds_list_size(objectList);
		var currentObject;
		
		// Perform cleanup for all objects
		repeat (objectAmount) {
			// Select first object
			currentObject = objectList[| 0];
			
			// Perform cleanup
			if (VIObjectExists(currentObject)) {
				currentObject.Cleanup();
				
				delete objectList[| 0];
			}
			
			// Delete object
			ds_list_delete(objectList, 0);
		}
		
		// Destroy system data structures
		if (ds_exists(objectList, ds_type_list)) ds_list_destroy(objectList);
	};
};

/// @function				VISystemExists(system);
/// @param {Struct} system	The variable to check.
/// @description			Returns wether or not the input variable is a valid VI system.
/// @return {Bool}
function VISystemExists(system) {
	return (is_struct(system) && variable_struct_exists(system, "type") && system.type == VI_TYPE.SYSTEM);
};

/// @function		VIObject();
/// @description	Base struct for all objects.
function VIObject() constructor {
	// Initialize "private" member vaiables
	// Do not change these values directly unless you know what you're doing!
	type = VI_TYPE.OBJECT;
	active = true;
	visible = true;
	
	/// @function				SetActive(active);
	/// @param {Bool} active	Active flag.
	/// @description			Sets whether or not the system is active (simulating) or not.
	SetActive = function(active) {
		self.active = active;
	};
	
	/// @function				SetVisible(visible);
	/// @param {Bool} visible	Visible flag.
	/// @description			Sets whether or not the system is visible (drawing) or not.
	SetVisible = function(visible) {
		self.visible = visible;
	};
	
	/// @function				GetDistance(xx, yy, precise);
	/// @param {Real} xx		The x position to measure from.
	/// @param {Real} yy		The y position to measure from.
	/// @param {Bool} precise	Wether or not to use precise measurements. Be careful with this, precise measurements can be very resource intensive!
	/// @description			Returns the distance to the group.
	/// @return {Bool}
	GetDistance = function(xx, yy, precise) {};
	
	/// @function				Simulate(delta, grav, frict);
	/// @param {Real} delta		The delta time.
	/// @param {Real} grav		The gravity.
	/// @param {Real} frict		The friction.
	/// @description			Simulates this object.
	Simulate = function(delta, grav, frict) {};
	
	/// @function		DrawWireframe();
	/// @description	Draws this object as wireframe.
	DrawWireframe = function() {};
	
	/// @function		Draw();
	/// @description	Draws this object. Override.
	Draw = DrawWireframe;
	
	/// @function		Cleanup();
	/// @description	Destroys data structures.
	Cleanup = function() {};
};

/// @function				VIObjectExists(object);
/// @param {Struct} object	The variable to check.
/// @description			Returns wether or not the input variable is a valid VI object.
/// @return {Bool}
function VIObjectExists(object) {
	return (is_struct(object) && variable_struct_exists(object, "type") && object.type == VI_TYPE.OBJECT);
};

/// @function				VIPhysical(stiffness);
/// @param {Real} stiffness	The amount of iterations the sticks try to correct their positions.
/// @description			Base struct for physical objects. (Things that contain points and sticks)
function VIPhysical(stiffness) : VIObject() constructor {
	// Initialize "private" member vaiables
	// Do not change these values directly unless you know what you're doing!
	subtype = VI_SUBTYPE.PHYSICAL;
	pointList = ds_list_create();
	stickList = ds_list_create();
	stabilizeTime = 4; // This is the time in seconds we allow the simulation to stabilize before tearing can occur
	self.stiffness = stiffness;
	
	/// @function			AddPoint(x, y, mass);
	/// @param {Real} x		The point's x position.
	/// @param {Real} y		The point's y position.
	/// @param {Real} mass	The point's mass.
	/// @description		Adds a new point to the point list.
	AddPoint = function(x, y, mass) {
		ds_list_add(pointList, new VIPoint(x, y, mass, 1));
	}
	
	/// @function					AddStick(p1, p2, length, tearThreshold);
	/// @param {Struct} p1			The stick's first point its attached to.
	/// @param {Struct} p2			The stick's second point its attached to.
	/// @param {Real} length		The stick's length.
	/// @param {Real} tearThreshold	The threshold of overstretching before the stick breaks. (-1 to disable tearing).
	/// @description				Adds a new stick to the stick list.
	AddStick = function(p1, p2, length, tearThreshold) {
		ds_list_add(stickList, new VIStick(p1, p2, length, tearThreshold));
	};
	
	/// @function			DeletePoint(index);
	/// @param {Real} index	The point's index within the point list.
	/// @description		Deletes a point from the point list.
	DeletePoint = function(index) {
		// Get point
		var currentPoint = pointList[| index];
		
		// Update point state
		// Points are not deleted from the list, but flagged as deleted in order for the cloth drawing logic to still work
		currentPoint.state = VI_POINT_STATE.DELETED;
		
		// Delete all sticks attached to that point
		var stickAmount = ds_list_size(stickList);
		var currentStick;
		for (var i = stickAmount - 1; i >= 0; i--) {
			currentStick = stickList[| i];
			
			if (currentStick.p1 == currentPoint || currentStick.p2 == currentPoint) {
				ds_list_delete(stickList, i);
			}
		}
	};
	
	/// @function				GetPointByKeyword(keyword);
	/// @param {Real} keyword	A keyword from VI_POINT_INDEX.
	/// @description			Returns a point from the point list.
	/// @return {Struct}
	GetPointByKeyword = function(keyword) {
		var index;
		switch (keyword) {
			case VI_POINT_INDEX.FIRST: index = 0 break;
			case VI_POINT_INDEX.CENTER: index = floor(ds_list_size(pointList) / 2) break;
			case VI_POINT_INDEX.LAST: index = (ds_list_size(pointList) - 1) break;
		}
		
		return pointList[| index];
	};
	
	/// @function			GetPointByIndex(index);
	/// @param {Real} index	The index of the point within the object's pointList.
	/// @description		Returns a point from the point list.
	/// @return {Struct}
	GetPointByIndex = function(index) {
		return pointList[| index];
	};
	
	/// @function				VerletSimulation(delta, grav, frict);
	/// @param {Real} delta		The delta time.
	/// @param {Real} grav		The gravity.
	/// @param {Real} frict		The friction.
	/// @description			Verlet simulation.
	VerletSimulation = function(delta, grav, frict) {
		#region Update points
		var pointAmount = ds_list_size(pointList);
		var currentPoint, force, acceleration, posPre, externals;
		
		for (var i = 0; i < pointAmount; i++) {
			currentPoint = pointList[| i];
			
			// Skip if the point has no mass or is deleted
			if (currentPoint.mass == 0 || currentPoint.state == VI_POINT_STATE.DELETED) continue;
			
			force = {x : 0, y : grav * currentPoint.mass};
			acceleration = {x : force.x, y : force.y};
			posPre = {x: currentPoint.position.current.x, y: currentPoint.position.current.y};
			externals = (1 - frict) * sqr(min(1, delta));
			
			currentPoint.position.current.x = 2 * currentPoint.position.current.x - currentPoint.position.previous.x + acceleration.x * externals;
		    currentPoint.position.current.y = 2 * currentPoint.position.current.y - currentPoint.position.previous.y + acceleration.y * externals;
			
		    currentPoint.position.previous.x = posPre.x;
		    currentPoint.position.previous.y = posPre.y;
		}
		#endregion
		
		#region Update sticks
		var stickAmount, currentStick, diff, len, diffFactor, offset;
		
		repeat (stiffness) {
			stickAmount = ds_list_size(stickList)
			for (var i = stickAmount - 1; i >= 0; i--) {
				currentStick = stickList[| i];
				
				// Calculate restraints
				diff = {x: currentStick.p1.position.current.x - currentStick.p2.position.current.x, y: currentStick.p1.position.current.y - currentStick.p2.position.current.y};
				len = sqrt(sqr(diff.x) + sqr(diff.y));
				diffFactor = (currentStick.length - len) / len * 0.5;
				offset = {x: diff.x * diffFactor, y: diff.y * diffFactor};
				
				// Update point positions
				// Skip if the point has no mass
				if (currentStick.p1.mass > 0) {
					currentStick.p1.position.current.x += offset.x;
					currentStick.p1.position.current.y += offset.y;
				}
				if (currentStick.p2.mass > 0) {
					currentStick.p2.position.current.x -= offset.x;
					currentStick.p2.position.current.y -= offset.y;
				}
				
				// Tear connections when overstretching
				if (currentStick.tearThreshold == -1 || stabilizeTime > 0) continue;
				
				if (len / currentStick.length > currentStick.tearThreshold) {
					ds_list_delete(stickList, i);
				}
			}
		}
		#endregion
		
		// Count stabilize time
		stabilizeTime -= 1 / game_get_speed(gamespeed_fps) * delta;
		if (stabilizeTime < 0) stabilizeTime = 0;
	};
	
	/// @function				Simulate(delta, grav, frict);
	/// @param {Real} delta		The delta time.
	/// @param {Real} grav		The gravity.
	/// @param {Real} frict		The friction.
	/// @description			Simulates this object.
	Simulate = function(delta, grav, frict) {
		// Make sure the object is active
		if (!active) exit;
		
		VerletSimulation(delta, grav, frict);
	};
	
	/// @function		DrawWireframe();
	/// @description	Draws this object as wireframe.
	DrawWireframe = function() {
		// Draw sticks
		draw_set_color(c_gray);
		var stickAmount = ds_list_size(stickList);
		var currentStick;
		for (var i = 0; i < stickAmount; i++) {
			currentStick = stickList[| i];
			draw_line_width(currentStick.p1.position.current.x, currentStick.p1.position.current.y, currentStick.p2.position.current.x, currentStick.p2.position.current.y, 1);
		}
		draw_set_color(c_white);
		
		// Draw points
		var pointAmount = ds_list_size(pointList);
		var currentPoint, isInsideField, col;
		var objectAmount, currentObject;
		for (var i = 0; i < pointAmount; i++) {
			// Get next point
			currentPoint = pointList[| i];
			
			// Ignore deleted points
			if (currentPoint.state == VI_POINT_STATE.DELETED) continue;
			
			// Check if point is inside any field
			isInsideField = false;
			
			objectAmount = ds_list_size(systemReference.objectList);
			for (var j = 0; j < objectAmount; j++) {
				currentObject = systemReference.objectList[| j];
				
				if (VIObjectExists(currentObject) && currentObject.subtype == VI_SUBTYPE.FORCEFIELD) {
					if (point_in_circle(currentPoint.position.current.x, currentPoint.position.current.y, currentObject.x, currentObject.y, currentObject.radius)) {
						isInsideField = true;
						break;
					}
				}
			}
			
			// Draw point
			col = (isInsideField ? c_red : $c6ff00);
			draw_circle_color(currentPoint.position.current.x, currentPoint.position.current.y, currentPoint.radius, col, col, false);
		}
	};
	
	/// @function		Draw();
	/// @description	Draws this object. Override.
	Draw = DrawWireframe;
	
	/// @function		Cleanup();
	/// @description	Destroys data structures.
	Cleanup = function() {
		// Destroy data structures
		if (ds_exists(pointList, ds_type_list)) ds_list_destroy(pointList);
		if (ds_exists(stickList, ds_type_list)) ds_list_destroy(stickList);
	};
};

/// @function				VIPoint(x, y, mass, radius);
/// @param {Real} x			The point's x position.
/// @param {Real} y			The point's y position.
/// @param {Real} mass		How much the point gets influenced by forces. (0 = frozen in place)
/// @param {Real} radius	The radius of the point.
/// @description			Point struct.
function VIPoint(x, y, mass, radius) constructor {
	state = VI_POINT_STATE.ALIVE;
	position = {current : {x : x, y : y}, previous : {x : x, y : y}};
	self.mass = mass;
	self.radius = radius;
	
	previousPoint = noone;
};

/// @function					VIStick(p1, p2, length, tearThreshold);
/// @param {Struct} p1			The stick's first point its attached to.
/// @param {Struct} p2			The stick's second point its attached to.
/// @param {Real} length		The stick's length.
/// @param {Real} tearThreshold	The threshold of overstretching before the stick breaks. (-1 to disable tearing).
/// @description				Stick struct.
function VIStick(p1, p2, length, tearThreshold) constructor {
	self.p1 = p1;
	self.p2 = p2;
	self.length = length;
	self.tearThreshold = tearThreshold;
};
