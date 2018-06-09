using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class MeanMaxPowerChartDelegate extends Ui.InputDelegate
{
	var app;

    function initialize()
    {
        InputDelegate.initialize();
        app = App.getApp();
    }
    // Handle touch events
    function onTap(evt)
    {
        System.println("MeanMaxPowerChartDelegate: onTap");
        // Display_CP_Values_Type =
        //
        //        0 - Current
        //        1 - Ride
        //        2 - Record
        //
        app.Display_CP_Values_Type = (app.Display_CP_Values_Type + 1) % 3;
        System.println("Display_CP_Values_Type = " + app.Display_CP_Values_Type);
 	}
 }