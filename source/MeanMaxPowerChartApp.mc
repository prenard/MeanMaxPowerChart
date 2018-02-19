// History:
//
// 2018-01-21 - V 01.00
//
//		* xxxx


using Toybox.System;
using Toybox.Application as App;
using Toybox.WatchUi as Ui;


class MeanMaxPowerChartApp extends App.AppBase
{

	var Garmin_Device_Type;
	
    function initialize()
    {
        AppBase.initialize();
		var DeviceSettings = System.getDeviceSettings();

   		System.println("Application Start - Total Memory = " + System.getSystemStats().totalMemory + " / Used Memory = " + System.getSystemStats().usedMemory);

        Garmin_Device_Type = Ui.loadResource(Rez.Strings.Device);

        System.println("Device Type = " + Garmin_Device_Type);
        System.println("Device - Screen Height = " + DeviceSettings.screenHeight);
        System.println("Device - Screen Width = " + DeviceSettings.screenWidth);
        System.println("Device - Is Touchscreen = " + DeviceSettings.isTouchScreen);

    }

    // onStart() is called on application start up
    function onStart(state)
    {
    }

    // onStop() is called when your application is exiting
    function onStop(state)
    {
    }

    //! Return the initial view of your application here
    function getInitialView()
    {
        return [ new MeanMaxPowerChartView() ];
    }

}