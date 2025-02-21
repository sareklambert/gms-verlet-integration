/// @function						VICloth(x, y, width, height, pointAmountX, pointAmountY, stiffness, tearThreshold);
/// @param {Real} x					The cloth's left x position.
/// @param {Real} y					The cloth's top y position.
/// @param {Real} width				The cloth's width.
/// @param {Real} height			The cloth's height.
/// @param {Real} pointAmountX		How many points the cloth should have on the x axis.
/// @param {Real} pointAmountY		How many points the cloth should have on the y axis.
/// @param {Real} stiffness			The amount of iterations the sticks try to correct their positions.
/// @param {Real} tearThreshold		The threshold of overstretching before the sticks breaks. (-1 to disable tearing).
/// @description					Base struct for cloths.
function VICloth(x, y, width, height, pointAmountX, pointAmountY, stiffness, tearThreshold) :
			VIPhysical(stiffness) constructor {
	// Save input parameters
	self.pointAmountX = pointAmountX;
	self.pointAmountY = pointAmountY;
	
	// Create points
	for (var i = 0; i < pointAmountX; i++) {
		for (var j = 0; j < pointAmountY; j++) {
			AddPoint(x + i * width / (pointAmountX - 1), y + j * height / (pointAmountY - 1), 1);
		}
	}
	
	// Create sticks
	for (var i = 0; i < pointAmountX; i++) {
		for (var j = 0; j < pointAmountY; j++) {
			if (i > 0) AddStick(pointList[| (i - 1) * pointAmountY + j], pointList[| i * pointAmountY + j], width / (pointAmountX - 1), tearThreshold);
			if (j > 0) AddStick(pointList[| i * pointAmountY + j - 1], pointList[| i * pointAmountY + j], height / (pointAmountY - 1), tearThreshold);
		}
	}
	
	// Add functions for locking points
	/// @function		LockUpperCorners();
	/// @description	Locks the points in the upper corners.
	LockUpperCorners = function() {
		pointList[| 0].mass = 0;
		pointList[| (pointAmountX - 1) * pointAmountY].mass = 0;
	}
	
	/// @function		LockAllCorners();
	/// @description	Locks the points in all corners.
	LockAllCorners = function() {
		pointList[| 0].mass = 0;
		pointList[| (pointAmountX - 1) * pointAmountY].mass = 0;
		pointList[| pointAmountY - 1].mass = 0;
		pointList[| pointAmountX * pointAmountY - 1].mass = 0;
	}
	
	/// @function		LockUpperRow();
	/// @description	Locks the points in the upper row.
	LockUpperRow = function() {
		for (var i = 0; i < pointAmountX; i++) pointList[| i * pointAmountY].mass = 0;
	}
};

/// @function						VIClothColored(x, y, width, height, pointAmountX, pointAmountY, color, stiffness, tearThreshold);
/// @param {Real} x					The cloth's left x position.
/// @param {Real} y					The cloth's top y position.
/// @param {Real} width				The cloth's width.
/// @param {Real} height			The cloth's height.
/// @param {Real} pointAmountX		How many points the cloth should have on the x axis.
/// @param {Real} pointAmountY		How many points the cloth should have on the y axis.
/// @param {Constant.Color} color	The cloth's color.
/// @param {Real} stiffness			The amount of iterations the sticks try to correct their positions.
/// @param {Real} tearThreshold		The threshold of overstretching before the sticks breaks. (-1 to disable tearing).
/// @description					A colored cloth.
function VIClothColored(x, y, width, height, pointAmountX, pointAmountY, color, stiffness, tearThreshold) :
			VICloth(x, y, width, height, pointAmountX, pointAmountY, stiffness, tearThreshold) constructor {
	// Save input parameters
	self.color = color;
	
	// Override draw function
	Draw = function () {
		// Exit if the object is not visible
		if (!visible) exit;
		
		var p1, p2, p3, p4;
		
		// Construct primitive
		draw_set_color(color);
		draw_primitive_begin(pr_trianglelist);
		
		for (var i = 0; i < pointAmountX - 1; i++) {
			for (var j = 0; j < pointAmountY - 1; j++) {
				// Get points
				p1 = pointList[| (i + 0) * pointAmountY + (j + 0)];
				p2 = pointList[| (i + 1) * pointAmountY + (j + 0)];
				p3 = pointList[| (i + 0) * pointAmountY + (j + 1)];
				p4 = pointList[| (i + 1) * pointAmountY + (j + 1)];
				
				// Draw two triangles per grid cell
				if (p1.state == VI_POINT_STATE.ALIVE && p2.state == VI_POINT_STATE.ALIVE && p3.state == VI_POINT_STATE.ALIVE) {
					draw_vertex(p1.position.current.x, p1.position.current.y);
					draw_vertex(p2.position.current.x, p2.position.current.y);
					draw_vertex(p3.position.current.x, p3.position.current.y);
				}
				if (p2.state == VI_POINT_STATE.ALIVE && p3.state == VI_POINT_STATE.ALIVE && p4.state == VI_POINT_STATE.ALIVE) {
					draw_vertex(p3.position.current.x, p3.position.current.y);
					draw_vertex(p4.position.current.x, p4.position.current.y);
					draw_vertex(p2.position.current.x, p2.position.current.y);
				}
			}
		}
		
		draw_primitive_end();
		draw_set_color(c_white);
	};
};

/// @function						VIClothTextured(x, y, width, height, pointAmountX, pointAmountY, sprite, stiffness, tearThreshold);
/// @param {Real} x					The cloth's left x position.
/// @param {Real} y					The cloth's top y position.
/// @param {Real} width				The cloth's width.
/// @param {Real} height			The cloth's height.
/// @param {Real} pointAmountX		How many points the cloth should have on the x axis.
/// @param {Real} pointAmountY		How many points the cloth should have on the y axis.
/// @param {Asset.GMSprite} sprite	The cloth's sprite.
/// @param {Real} stiffness			The amount of iterations the sticks try to correct their positions.
/// @param {Real} tearThreshold		The threshold of overstretching before the sticks breaks. (-1 to disable tearing).
/// @description					A cloth drawn using a texture.
function VIClothTextured(x, y, width, height, pointAmountX, pointAmountY, sprite, stiffness, tearThreshold) :
			VICloth(x, y, width, height, pointAmountX, pointAmountY, stiffness, tearThreshold) constructor {
	// Save input parameters
	self.sprite = sprite;
	
	// Override draw function
	Draw = function () {
		// Exit if the object is not visible
		if (!visible) exit;
		
		var p1, p2, p3, p4;
		
		// Construct primitive
		var texture = sprite_get_texture(sprite, 0);
		draw_primitive_begin_texture(pr_trianglelist, texture);
		
		for (var i = 0; i < pointAmountX - 1; i++) {
			for (var j = 0; j < pointAmountY - 1; j++) {
				// Get points
				p1 = pointList[| (i + 0) * pointAmountY + (j + 0)];
				p2 = pointList[| (i + 1) * pointAmountY + (j + 0)];
				p3 = pointList[| (i + 0) * pointAmountY + (j + 1)];
				p4 = pointList[| (i + 1) * pointAmountY + (j + 1)];
				
				// Compute UV coordinates
				var u0 = i / (pointAmountX - 1);
				var v0 = j / (pointAmountY - 1);
				var u1 = (i + 1) / (pointAmountX - 1);
				var v1 = (j + 1) / (pointAmountY - 1);
				
				// Draw two triangles per grid cell
				if (p1.state == VI_POINT_STATE.ALIVE && p2.state == VI_POINT_STATE.ALIVE && p3.state == VI_POINT_STATE.ALIVE) {
					draw_vertex_texture(p1.position.current.x, p1.position.current.y, u0, v0);
					draw_vertex_texture(p2.position.current.x, p2.position.current.y, u1, v0);
					draw_vertex_texture(p3.position.current.x, p3.position.current.y, u0, v1);
				}
				if (p2.state == VI_POINT_STATE.ALIVE && p3.state == VI_POINT_STATE.ALIVE && p4.state == VI_POINT_STATE.ALIVE) {
					draw_vertex_texture(p3.position.current.x, p3.position.current.y, u0, v1);
					draw_vertex_texture(p4.position.current.x, p4.position.current.y, u1, v1);
					draw_vertex_texture(p2.position.current.x, p2.position.current.y, u1, v0);
				}
			}
		}
		draw_primitive_end();
	};
};
