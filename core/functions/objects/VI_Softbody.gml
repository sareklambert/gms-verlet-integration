/// @function				VISoftbody(stiffness);
/// @param {Real} stiffness	The amount of iterations the sticks try to correct their positions.
/// @description			Base struct for softbodies.
function VISoftbody(stiffness) : VIPhysical(stiffness) constructor {
	/// @function ComputeCenter();
	/// @return {Struct}
	ComputeCenter = function() {
		var cx = 0, cy = 0;
		var pointAmount = ds_list_size(pointList);

		for (var i = 0; i < pointAmount; i++) {
			cx += pointList[| i].position.current.x;
			cy += pointList[| i].position.current.y;
		}

		return {x: cx / pointAmount, y: cy / pointAmount};
	};
	
	/// @function		InitShapeData();
	/// @description	Initializes the data needed for the maintain shape function.
	InitShapeData = function () {
		var centerInitial = ComputeCenter();
		
		var pointAmount = ds_list_size(pointList);
		var currentPoint;
		for (var i = 0; i < pointAmount; i++) {
			currentPoint = pointList[| i];
			
			currentPoint.originalOffset = {x: currentPoint.position.current.x - centerInitial.x,
											y: currentPoint.position.current.y - centerInitial.y };
		}
	};
	
	/// @function		MaintainShape();
	/// @description	Tries to push the points back into their original shape.
	MaintainShape = function () {
		// Compute current center of mass
		var centerCurrent = ComputeCenter();
		
		// Compute covariance matrix (2x2 components)
		var Axx = 0, Axy = 0, Ayx = 0, Ayy = 0;
		
		var pointAmount = ds_list_size(pointList);
		var currentPoint;
		for (var i = 0; i < pointAmount; i++) {
			currentPoint = pointList[| i];
			
			var p = currentPoint.position.current;
			var r = currentPoint.originalOffset;
			
			var px = p.x - centerCurrent.x;
			var py = p.y - centerCurrent.y;
			
			// Covariance matrix accumulation
			Axx += px * r.x;
			Axy += px * r.y;
			Ayx += py * r.x;
			Ayy += py * r.y;
		}
		
		// Approximate rotation using polar decomposition
		var det = Axx * Ayy - Axy * Ayx;
		if (det == 0) return; // Prevent divide by zero
		
		var scale = sqrt(Axx * Axx + Ayx * Ayx);
		if (scale == 0) return;
		
		var Rxx = Axx / scale;
		var Rxy = Axy / scale;
		var Ryx = Ayx / scale;
		var Ryy = Ayy / scale;
		
		// Apply rotation and shape correction
		for (var i = 0; i < pointAmount; i++) {
			currentPoint = pointList[| i];
			
			var r = currentPoint.originalOffset;
			
			// Rotate relative position
			var rx = Rxx * r.x + Rxy * r.y;
			var ry = Ryx * r.x + Ryy * r.y;
			
			var targetX = centerCurrent.x + rx;
			var targetY = centerCurrent.y + ry;
			
			// Apply correction force
			currentPoint.position.current.x += (targetX - currentPoint.position.current.x) / 2;
			currentPoint.position.current.y += (targetY - currentPoint.position.current.y) / 2;
		}
	};
	
	// Override Simulate function
	/// @function				Simulate(delta, grav, frict);
	/// @param {Real} delta		The delta time.
	/// @param {Real} grav		The gravity.
	/// @param {Real} frict		The friction.
	/// @description			Simulates this object.
	Simulate = function(delta, grav, frict) {
		// Make sure the object is active
		if (!active) exit;
		
		VerletSimulation(delta, grav, frict);
		MaintainShape();
	};
};

/// @function				VIBox(x, y, width, height, stiffness);
/// @param {Real} x			The box's x position.
/// @param {Real} y			The box's y position.
/// @param {Real} width		The box's width.
/// @param {Real} height	The box's height.
/// @param {Real} stiffness	The amount of iterations the sticks try to correct their positions.
/// @description			Base struct for boxes.
function VIBox(x, y, width, height, stiffness) : VISoftbody(stiffness) constructor {
	// Create points and sticks
	AddPoint(x, y, 1);
	AddPoint(x + width, y, 1);
	AddPoint(x, y + height, 1);
	AddPoint(x + width, y + height, 1);
	var p1 = pointList[| 0];
	var p2 = pointList[| 1];
	var p3 = pointList[| 2];
	var p4 = pointList[| 3];
	
	AddStick(p1, p2, width, -1);
	AddStick(p3, p4, width, -1);
	AddStick(p1, p3, height, -1);
	AddStick(p2, p4, height, -1);
	AddStick(p1, p4, sqrt(sqr(width) + sqr(height)), -1);
	AddStick(p2, p3, sqrt(sqr(width) + sqr(height)), -1);
	
	// Initialize shape data
	InitShapeData();
};

/// @function						VIBoxColored(x, y, width, height, color, stiffness);
/// @param {Real} x					The box's x position.
/// @param {Real} y					The box's y position.
/// @param {Real} width				The box's width.
/// @param {Real} height			The box's height.
/// @param {Constant.Color} color	The box's color.
/// @param {Real} stiffness			The amount of iterations the sticks try to correct their positions.
/// @description					A colored box.
function VIBoxColored(x, y, width, height, color, stiffness) : VIBox(x, y, width, height, stiffness) constructor {
	// Save input parameters
	self.color = color;
	
	// Override draw function
	Draw = function() {
		// Exit if the object is not visible
		if (!visible) exit;
		
		var p1 = pointList[| 0];
		var p2 = pointList[| 1];
		var p3 = pointList[| 2];
		var p4 = pointList[| 3];
		
		// Exit if a point was deleted
		if (p1.state == VI_POINT_STATE.DELETED || p2.state == VI_POINT_STATE.DELETED || p3.state == VI_POINT_STATE.DELETED || p4.state == VI_POINT_STATE.DELETED) exit;
		
		draw_set_color(color);
		draw_primitive_begin(pr_trianglestrip);
		draw_vertex(p1.position.current.x, p1.position.current.y);
		draw_vertex(p2.position.current.x, p2.position.current.y);
		draw_vertex(p3.position.current.x, p3.position.current.y);
		draw_vertex(p4.position.current.x, p4.position.current.y);
		draw_primitive_end();
		draw_set_color(c_white);
	};
};

/// @function						VIBoxTextured(x, y, width, height, sprite, stiffness);
/// @param {Real} x					The box's x position.
/// @param {Real} y					The box's y position.
/// @param {Real} width				The box's width.
/// @param {Real} height			The box's height.
/// @param {Asset.GMSprite} sprite	The box's sprite.
/// @param {Real} stiffness			The amount of iterations the sticks try to correct their positions.
/// @description					A box drawn using a texture.
function VIBoxTextured(x, y, width, height, sprite, stiffness) : VIBox(x, y, width, height, stiffness) constructor {
	// Save input parameters
	self.sprite = sprite;
	
	// Override draw function
	Draw = function() {
		// Exit if the object is not visible
		if (!visible) exit;
		
		var p1 = pointList[| 0];
		var p2 = pointList[| 1];
		var p3 = pointList[| 2];
		var p4 = pointList[| 3];
		
		// Exit if a point was deleted
		if (p1.state == VI_POINT_STATE.DELETED || p2.state == VI_POINT_STATE.DELETED || p3.state == VI_POINT_STATE.DELETED || p4.state == VI_POINT_STATE.DELETED) exit;
		
		var texture = sprite_get_texture(sprite, 0);
		draw_primitive_begin_texture(pr_trianglestrip, texture);
		draw_vertex_texture(p1.position.current.x, p1.position.current.y, 0, 0);
		draw_vertex_texture(p2.position.current.x, p2.position.current.y, 1, 0);
		draw_vertex_texture(p3.position.current.x, p3.position.current.y, 0, 1);
		draw_vertex_texture(p4.position.current.x, p4.position.current.y, 1, 1);
		draw_primitive_end();
	};
};
