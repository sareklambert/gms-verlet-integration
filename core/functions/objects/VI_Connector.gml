/// @function		VIConnector(x, y);
/// @param {Real} x	The x position of the connector.
/// @param {Real} y	The y position of the connector.
/// @description	Connects with points and/or objects.
function VIConnector(x, y) : VIObject() constructor {
	// Initialize "private" member vaiables
	// Do not change these values directly unless you know what you're doing!
	subtype = VI_SUBTYPE.CONNECTOR;
	visible = false;
	self.x = x;
	self.y = y;
	
	parent = noone;
	childList = ds_list_create();
	
	/// @function		SetPosition(x, y);
	/// @param {Real} x	The new x position.
	/// @param {Real} y	The new y position.
	/// @description	Sets the position of the collider.
	SetPosition = function(x, y) {
		self.x = x;
		self.y = y;
	};
	
	/// @function			SetParent(type, obj);
	/// @param {Real} type	The parent type. Selected from VI_PC_TYPE.
	/// @param {Any} obj	The VIPoint, instance, or VIForcefield.
	/// @description		Sets the parent of the connector.
	SetParent = function(type, obj) {
		parent = {type : type, obj : obj};
	};
	
	/// @function						AddChild(type, obj, updateRotation);
	/// @param {Real} type				The parent type. Selected from VI_PC_TYPE.
	/// @param {Any} obj				The VIPoint or instance.
	/// @param {Bool} updateRotation	Wehter or not to update the childs image_angle. (Parent must be VIPoint of a VIRope, Child must be instance)
	/// @description					Adds a child to the connector.
	AddChild = function(type, obj, updateRotation) {
		ds_list_add(childList, {type : type, obj : obj, updateRotation : updateRotation});
	};
	
	/// @function				Simulate(delta, grav, frict);
	/// @param {Real} delta		The delta time.
	/// @param {Real} grav		The gravity.
	/// @param {Real} frict		The friction.
	/// @description			Simulates this object.
	Simulate = function(delta, grav, frict) {
		// Make sure the object is active
		if (!active) exit;
		
		// Update own position
		if (parent != noone) {
			switch (parent.type) {
				case VI_PC_TYPE.POINT:
					// Get point position
					x = parent.obj.position.current.x;
					y = parent.obj.position.current.y;
					break;
				case VI_PC_TYPE.INSTANCE:
					// Get instance position
					x = parent.obj.x;
					y = parent.obj.y;
					break;
				case VI_PC_TYPE.COLLIDER:
					// Get collider position
					x = parent.obj.x;
					y = parent.obj.y;
					break;
			}
		}
		
		// Update child positions
		var childAmount = ds_list_size(childList);
		var currentChild;
		for (var i = 0; i < childAmount; i++) {
			currentChild = childList[| i];
			
			switch (currentChild.type) {
				case VI_PC_TYPE.POINT:
					// Set point position
					currentChild.obj.position.current.x = x;
					currentChild.obj.position.current.y = y;
					break;
				case VI_PC_TYPE.INSTANCE:
					// Set instance position
					currentChild.obj.x = x;
					currentChild.obj.y = y;
					
					// Set instance image angle (parent must be a VIRope)
					if (currentChild.updateRotation && parent.type == VI_PC_TYPE.POINT) {
						// Prevent errors when there is no previous point
						if (parent.obj.previousPoint == noone) continue;
						
						currentChild.obj.image_angle = point_direction(parent.obj.previousPoint.position.current.x, parent.obj.previousPoint.position.current.y,
																		parent.obj.position.current.x, parent.obj.position.current.y);
					}
					break;
				case VI_PC_TYPE.COLLIDER:
					// Set collider position
					currentChild.obj.x = x;
					currentChild.obj.y = y;
					break;
			}
		}
	};
	
	/// @function		DrawWireframe();
	/// @description	Draws this object as wireframe.
	DrawWireframe = function() {
		draw_circle(x, y, 6, false);
	};
	
	/// @function		Draw();
	/// @description	Draws this object. Override.
	Draw = DrawWireframe;
	
	/// @function		Cleanup();
	/// @description	Destroys data structures.
	Cleanup = function() {
		// Destroy data structures
		if (ds_exists(childList, ds_type_list)) ds_list_destroy(childList);
	};
};
