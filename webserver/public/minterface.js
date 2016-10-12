MissionIntelApp.GUI = function() {
    
    var settings = {
        showRed: false,
        showBlue: false
    };
    var backgroundCanvas;
    
    /**
     * Initialize GUI
     */
    this.initialize = function() {
        
        backgroundCanvas = document.createElement("canvas");
        backgroundCanvas.width = 800;
        backgroundCanvas.height = 600;
        document.body.appendChild(backgroundCanvas);
        
        var ctx = backgroundCanvas.getContext("2d");
        ctx.rect(20,20,150,100);
        ctx.fill();
        
        ctx.fillText("Hello world", 300,300);
        
        var menu = new dat.GUI();
        menu.add(settings, "showRed");
        menu.add(settings, "showBlue");
        
        console.log("GUI initialized");
        
    };
    
    /**
     * Add unit
     * @param {DCSUnit} unit
     */
    this.addUnit = function(unit) {
        
    };
    
    /**
     * Remove all units from view
     */
    this.clearUnits = function() {
        
    };
    
}
