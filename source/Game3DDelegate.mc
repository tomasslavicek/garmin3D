using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class Game3DDelegate extends Ui.BehaviorDelegate {

	var view;

    function initialize(mview) {
    	view = mview;
        BehaviorDelegate.initialize();
    }
        
    function onPreviousPage() {        
        view.downPressed();    
        return true;
    }
    
    function onNextPage() {
        view.upPressed();
        return true;
    }
    
    function onKey(keyEvent) {
    	var key = keyEvent.getKey();
        if (key == Ui.KEY_ENTER) {
        	view.enterPressed();
        	return true;
        }
        return false;
    }
}