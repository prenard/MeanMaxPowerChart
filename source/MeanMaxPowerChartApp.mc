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

	var TimeValues = [1,2,3,5,10,15,20,30,40,60,90,120,180,300,600,900,1200,1800,2400,3600,4800,6000,7200,9000,10800];

	var TimeValuesAvgPeriod = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1];
	var TimeValuesValid = new [TimeValues.size()];
	var TimeValues_x = new [TimeValues.size()];
	var TimeValuesX = [1,0,0,1,0,0,0,0,0,1,0,0,0,1,0,0,1,0,0,1,0,0,0,0,1];
	
	var CurrentPowerValues = new [TimeValues.size()];
	var RidePowerValues = new [TimeValues.size()];
	var RecordPowerValues = new [TimeValues.size()];
	var PreviousRecordPowerValues = new [TimeValues.size()];
	
	var PowerSumOfSamples = new [TimeValues.size()];
	var PowerNumberOfSamples = new [TimeValues.size()];

	
	var Device_Type;
	
    function initialize()
    {
        AppBase.initialize();
		var DeviceSettings = System.getDeviceSettings();

   		System.println("Application Start - Total Memory = " + System.getSystemStats().totalMemory + " / Used Memory = " + System.getSystemStats().usedMemory);

        Device_Type = Ui.loadResource(Rez.Strings.Device);

        System.println("Device Type = " + Device_Type);
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
		System.println("onStop - state = " + state);
    }

    //! Return the initial view of your application here
    function getInitialView()
    {


		var Label_Value = new [4];
		var Duration_Value = new [4];

		for (var i = 0; i < Label_Value.size() ; ++i)
       	{
       	   Label_Value[i] = null;
       	   Duration_Value[i] = 0;
		}


		Label_Value[0] = getProperty("Field_Time_Label");
		Duration_Value[0] = getProperty("Field_Time_Duration");

		Label_Value[1] = getProperty("Field_Timer_Label");
		Duration_Value[1] = getProperty("Field_Timer_Duration");

		Label_Value[2] = getProperty("Field_Distance_Label");
		Duration_Value[2] = getProperty("Field_Distance_Duration");

		Label_Value[3] = getProperty("Field_TimeOfDay_Label");
		Duration_Value[3] = getProperty("Field_TimeOfDay_Duration");
				
		var Args = new [4];
		
		Args[0]  = readPropertyKeyInt("AVG_Power_Duration",3);
		Args[1] = getProperty("Reset_RecordValues");
		Args[2] = Label_Value;
		Args[3] = Duration_Value;

		if (Args[1])
		{
			System.println("Going to reset Power Values Record...");
			for (var i = 0; i < TimeValues.size(); ++i)
			{
				RecordPowerValues[i] = 0;
			}
			System.println("Saving new RecordPowerValues to storage... RecordPowerValues = " + RecordPowerValues);
			Storage.setValue("RecordPowerValues", RecordPowerValues);
		}

		if (Storage.getValue("RecordPowerValues") != null)
		{
			System.println("Loading RecordPowerValues from storage...");
			RecordPowerValues = Storage.getValue("RecordPowerValues");
		}
		else
		{
			System.println("Going to initialize Power Values Record...");
			for (var i = 0; i < TimeValues.size(); ++i)
			{
				RecordPowerValues[i] = 0;
			}
		}

		for (var i = 0; i < TimeValues.size(); ++i)
		{
			PreviousRecordPowerValues[i] = RecordPowerValues[i];
		}


		System.println("RecordPowerValues = " + RecordPowerValues);
		//PreviousRecordPowerValues = RecordPowerValues;
		System.println("PreviousRecordPowerValues = " + PreviousRecordPowerValues);
				
        return [ new MeanMaxPowerChartView(Args) ];
    }

	function readPropertyKeyInt(key,thisDefault)
	{
		var value = getProperty(key);
        if(value == null || !(value instanceof Number))
        {
        	if(value != null)
        	{
            	value = value.toNumber();
        	}
        	else
        	{
                value = thisDefault;
        	}
		}
		return value;
	}


}