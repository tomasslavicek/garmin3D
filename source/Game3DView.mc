using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Timer;

class Game3DView extends Ui.View {

	var drawCount = 0, fps = 0, lastSec = 0;
	var timer = new Timer.Timer();
	var width, height;
	
	var data = new GameData(); // For a real game we should pass an info which level to load etc.
	var renderer;	

    function initialize() {
        View.initialize();
        renderer = new Renderer(data);
    }

    function onLayout(dc) {
    	width = dc.getWidth();
    	height = dc.getHeight();
    	renderer.onLayout(dc);
    }

    function onShow() {
    }
    
    function enterPressed() {  
    }
    
    function upPressed() {
    	if (data.rotationDirection == 0) {
    		data.rotationDirection = -1;
    	}
    }
    
    function downPressed() {
    	if (data.rotationDirection == 0) {
    		data.rotationDirection = 1;
    	}
    }

    function onUpdate(dc) {
    	data.onUpdate();
    	draw(dc);
    	
    	// Calculate FPS (and draw the value once per second)
    	// - 50 ms is the fastest possible refresh rate in the Connect IQ SDK (20 FPS)
        updateFps();
        timer.start(method(:timerCallback), 50, false);
        drawFps(dc);
        
        if (fps > 1) {
        	data.updateAnimation(fps);
        }
    }
    
    function draw(dc) {
    	// Draw the screen (it's doing a full redraw)
    	// - to optimize the rendering we can pre-render some part to a background bitmap, precalculate values etc.
    	dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    	dc.fillRectangle(0, 0, width, width);
    	
    	renderer.draw(dc);
    	if (width != height) {
    		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    		dc.fillRectangle(0, width, width, height - width);
    	}
    }
    
    function updateFps() {
    	drawCount++;
        var clockTime = Sys.getClockTime();
        if (clockTime.sec != lastSec) {
        	fps = drawCount;
        	drawCount = 0;
        	lastSec = clockTime.sec;
        }
    }
    
    function drawFps(dc) {
    	// Draws the FPS text over the window (it's using a small default font, not a custom font)
    	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    	dc.drawText(width / 2, 10, Gfx.FONT_TINY, fps, Gfx.TEXT_JUSTIFY_CENTER);
    }
    
    function timerCallback() {
    	// Refresh the UI on every timer tick
    	Ui.requestUpdate();
    }

    function onHide() {
    }

}
