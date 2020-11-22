using Toybox.System as Sys;

// An object of a game scene, contains an info about the level and the camera
class GameData {
	const SEGMENTS = 11;
	const CIRCLES = 7; // How many circles should be drawn
	
	var animCoef = 0.0; // Animation of a movement by 1 circle (values: 0.0-1.0)
	var animSpeed = 2.0; // The speed animation (how many circles should the level move in 1 second)	
	var oddState = 0; // 0 or 1, how the background gray and black circles should be drawn
	
	var rotation = 0.0; // Animation of the left/right rotation, by up and down arrows or a swipe gesture (0.0-1.0)
	var rotationSpeed = 3.0;
	var rotationDirection = 0; // -1, 0, 1 (direction of the rotation: left, none, right)
	
	var skewVector = 0.0; // Camera skew / rotation by X axis
	var minSkew = -0.07, maxSkew = 0.07, skewSpeed = 0.03, isSkewRight = true;
	
	var cubes; // The array of info on which indices we want to show the cubes: index [SEGMENTS, CIRCLES]
	var drawFront; // A bool array, if the front side of the cube should be drawn (precalculated, indexed the same way as the cube array)

    function initialize() { 
    	cubes = new[6];   
    	cubes[0] = [1, 1]; //TODO we should load this from the game level, precalculate from the nearest to furthest etc.
    	cubes[1] = [1, 4];  
    	cubes[2] = [3, 3];  
    	cubes[3] = [3, 2];  
    	cubes[4] = [3, 1];  
    	cubes[5] = [4, 0];
    	
    	// Precalculation of the bool array, if we should/not draw the front side of the cube
    	drawFront = new[cubes.size()];
    	for (var i = 0; i < cubes.size(); i++) {
    		var isPrecedesor = false;
    		for (var j = 0; j < cubes.size(); j++) {
    			if (i != j && cubes[i][0] == cubes[j][0] && cubes[i][1] == cubes[j][1] + 1) {
    				isPrecedesor = true;
    			}
    		}
    		drawFront[i] = !isPrecedesor;
    	}
    }
    
    function onUpdate() {
    }
    
    function updateAnimation(fps) { 
        // Forward movement of the cubes (animation)
    	animCoef += animSpeed / fps;    	    
    	if (animCoef >= 1.0) {
    		animCoef -= 1.0;
    		
    		// Temporary: if he moves by one cube to front, I put this cube to back (so it displays them again and again)
    		//TODO we should load this from a game level
    		oddState = (oddState == 0) ? 1 : 0;
    		for (var i = 0; i < cubes.size(); i++) {
    			cubes[i][1] -= 1;
    			if (cubes[i][1] < 0) {
    				cubes[i][1] = CIRCLES - 2;
    			}
    		}
    	}
    	
    	// Rotation of the cubes after up/down button is pressed
    	if (rotationDirection != 0) {
    		rotation += rotationSpeed * rotationDirection / fps; //TODO we should multiply this by sinus to look better
    		if (rotation > 1.0) {
    			switchCubes(1);
    		}
    		if (rotation < -1.0) {
    			switchCubes(-1);
    		}
    	}
    	
    	// Skew effect of the camera
    	if (isSkewRight) {
	    	skewVector += skewSpeed / fps;
	    	if (skewVector > maxSkew) {
	    		skewVector = maxSkew;
	    		isSkewRight = false;
	    	}
    	} else {
	    	skewVector -= skewSpeed / fps;    		
	    	if (skewVector < minSkew) {
	    		skewVector = minSkew;
	    		isSkewRight = true;
	    	}
    	}
    }
    
    function switchCubes(incr) {
        // Rotates the cubes by one to the right, or left
    	rotation = 0;
		rotationDirection = 0;
		oddState = (oddState == 0) ? 1 : 0;
		for (var i = 0; i < cubes.size(); i++) {
			cubes[i][0] += incr;
			if (cubes[i][0] > 5) {
				cubes[i][0] = 0;
			}
			if (cubes[i][0] < 0) {
				cubes[i][0] = 5;
			}
		} 		
    }

}








