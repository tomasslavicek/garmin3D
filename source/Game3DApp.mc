using Toybox.Application;
using Toybox.WatchUi;

class Game3DApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    function getInitialView() {
    	var view = new Game3DView();
        return [ view, new Game3DDelegate(view) ];
    }

}
