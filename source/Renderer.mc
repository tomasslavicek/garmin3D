using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

// 3D renderer of the layout
// - reads the GameData object (information where are the cubes, what are the parameters of the camera)
// - on every frame it gets the position of vertices in 3D, sets up the perspective camera, and calculates the projected positions on the screen
// - this algorithm calculates it using the model, view and projection matrices (theory: https://cw.fel.cvut.cz/b182/courses/gvg/start),
//   although the calculations are a bit more compact for this specific case (if something in the matrix was 0, we don't calculate it here)
// - another document to this topic (in Czech language): https://cw.fel.cvut.cz/old/_media/courses/b0b39pgr/05-transformace-2.pdf
// - author: Tomas Slavicek, support @ tomasslavicek.cz
class Renderer {
	const INDICES = [6, 7, 8, 9, 10, 0, 1, 2]; // Which indices from these 11 points should be drawn on screen (+ one more additional point for animations)
	const PI = 3.14159;
	const INNER_CIRCLE = 0.6;

	var data; // The Game data object
	var circlePoints; // Precalculated sin, cos values of the points around
	var points; // The array of arrays, the individual drawn circles (preallocated, in 3D coordinates, in the last step we draw the x/y coordinates from them)
	var lastRotation = -1;
	
	var perspective = 0.0304;
	var viewAngleX = 0.015 * 2 * PI, viewAngleY = -0.015 * 2 * PI;
	var sinX, cosX, sinY, cosY, w;
	var circleSize = 4.0;
		
    function initialize(gameData) {
    	data = gameData;
    	circlePoints = new[data.SEGMENTS]; // Values x/y for sin cos (2D coordinates around), then we multiply them by a radius
    	    	
    	// It generates the points, for the specified indices
    	points = new[data.CIRCLES];
    	for (var i = 0; i < data.CIRCLES; i++) {
    		points[i] = new[INDICES.size()];
    		for (var j = 0; j < INDICES.size(); j++) {
    			points[i][j] = new[3]; // 3D vector for each given point, X/Y are circle points, axis Z goes from 0 to 7 * circleSize
    		}
    	}
    }
    
    function onLayout(dc) { 
    	// Parameters of the display resolution
    	w = dc.getWidth() / 2;
    	sinX = Math.sin(viewAngleX); // viewAngleX/Y = rotation of the camera
    	sinY = Math.sin(viewAngleY);
    	cosX = Math.cos(viewAngleX); 
    	cosY = Math.cos(viewAngleY);   	
    }
	
	function draw(dc) {
    	var incr = (data.animCoef + 0.72) * circleSize;
    	var x = 0, y = 0, z = 0;
    	
		var max = INDICES.size() - 1;
		var min = 1;
		if (data.rotationDirection == 1) { max--; min--; }
    	
    	// Updates the rotation by the buttons up/down
    	if (lastRotation != data.rotation) {
	    	for (var i = 0; i < data.SEGMENTS; i++) {
	    		circlePoints[i] = [Math.sin((i + data.rotation) * 2 * PI / data.SEGMENTS), -Math.cos((i + data.rotation) * 2 * PI / data.SEGMENTS)];
	    	}
	    	lastRotation = data.rotation;
    	}
    	
    	// Skew / rotation by the axis X
    	sinX = Math.sin(viewAngleX + data.skewVector);
    	cosX = Math.cos(viewAngleX + data.skewVector); 
    	
    	for (var i = 0; i < data.CIRCLES; i++) {
    		z = i * circleSize - incr;
    		    		
    		for (var j = 0; j < INDICES.size(); j++) {   
    			// Rotation by the angle X, Y 	
				x = circlePoints[INDICES[j]][0] * cosX + z * sinX;
				y = circlePoints[INDICES[j]][1] * cosY - z * sinY;
				z = x * -1 * sinX + z * cosX;
				z = y * sinY + z * cosY;
				
				// Projection to a 3D with the perspective camera (with a ratio by axis Z, and the constant of the perspective distortion)
	    		points[i][j][0] = (x - x * z * perspective) * w + w;
	    		points[i][j][1] = (y - y * z * perspective) * w * -1 + w;
    		}
    		
    		// Drawing of the selected layer of background rectangles
    		dc.setColor(0x0000AA, Gfx.COLOR_BLACK); 
    		if (i == data.CIRCLES - 1 && data.animCoef <= 0.6) {
    			dc.setColor(0x000055, Gfx.COLOR_BLACK); 
    		}    		
    		for (var j = min; j < max; j++) {	    		
	    		if (i > 0 && (j + i + data.oddState) % 2 == 0) {
	    			dc.fillPolygon([points[i][j], points[i][j + 1], points[i - 1][j + 1], points[i - 1][j]]);
	    		}
    		}
    	}
    	
    	// Drawing of cubes over the background, very similar logic of drawing
		for (var c = 0; c < data.cubes.size(); c++) {
			var cube = data.cubes[c];
			var i = cube[1], j = cube[0];
			if (j < min || j > max) { continue; } // A range for which we should draw the cubes
    		
    		var z1 = i * circleSize - incr;
			var p1 = getCirclePoint(circlePoints[INDICES[j]], INNER_CIRCLE, x, y, z1);
			var p2 = getCirclePoint(circlePoints[INDICES[j + 1]], INNER_CIRCLE, x, y, z1);
						
			var z2 = (i + 1) * circleSize - incr;
			var p3 = getCirclePoint(circlePoints[INDICES[j]], INNER_CIRCLE, x, y, z2);
			var p4 = getCirclePoint(circlePoints[INDICES[j + 1]], INNER_CIRCLE, x, y, z2);
			
			// Right and left side of the cube
			dc.setColor(0xff0000, Gfx.COLOR_BLACK); 
			if (INDICES[j + 1] != 7 && INDICES[j + 1] != 8) {
				dc.fillPolygon([points[i][j + 1], points[i + 1][j + 1], p4, p2]);
			}
			if (INDICES[j] > 1) {
				dc.fillPolygon([points[i][j], points[i + 1][j], p3, p1]);
			}
			
			// Front side
			if (data.drawFront[c]) {
				dc.setColor(0xff5555, Gfx.COLOR_BLACK); 
				dc.fillPolygon([points[i][j], points[i][j + 1], p2, p1]);
			}
			
			// Top rectangle
			dc.setColor(0xaa0000, Gfx.COLOR_BLACK); 
			dc.fillPolygon([p3, p1, p2, p4]);
		}
	}
	
	function getCirclePoint(point, radius, x, y, z) {
	    // Really similar logic to the drawing of background rectangles
		x = point[0] * radius * cosX + z * sinX;
		y = point[1] * radius * cosY - z * sinY;
		z = x * -1 * sinX + z * cosX;
		z = y * sinY + z * cosY;		
	    return [(x - x * z * perspective) * w + w, (y - y * z * perspective) * w * -1 + w];		
	}	
}
