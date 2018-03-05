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

	var TimeValues = [1,2,3,5,10,15,20,30,40,60,90,120,180,300,480,600,900,1200,1800,2400,3600,4800,6000,7200,9000,10800];

	var TimeValuesAvgPeriod = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1];
	var TimeValuesValid = new [TimeValues.size()];
	var TimeValues_x = new [TimeValues.size()];
	var TimeValuesX = [1,0,0,1,0,0,0,0,0,1,0,0,0,1,0,0,0,1,0,0,1,0,0,0,0,1];
	
	var CurrentPowerValues = new [TimeValues.size()];
	var RidePowerValues = new [TimeValues.size()];
	var RecordPowerValues = new [TimeValues.size()];
	var PreviousRecordPowerValues = new [TimeValues.size()];
	
	var PowerSumOfSamples = new [TimeValues.size()];
	var PowerNumberOfSamples = new [TimeValues.size()];

	var Max_Zones_Number = 7;
	var Zones_Number = 0;

/*
	var Max_Zone_Display_Timer = 10;
	var Zone_Display_Timer = 0;

	var Zone_Time = new [Max_Zones_Number];
    var Zone_Loop_Index;
    var Zone_Loop_Size;
	var Zone_Loop_Value = new [Max_Zone_Display_Timer*Max_Zones_Number];
*/
	
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


		var Label_Value = new [5];
		var Duration_Value = new [5];

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

		Label_Value[4] = getProperty("Field_TSS_Label");
		Duration_Value[4] = getProperty("Field_TSS_Duration");

		var Max_Power = 1999;


		var Z_H = new [Max_Zones_Number - 1];
		var Zone_L = new [0];
		var Zone_H = new [0];

				
		Z_H[0]  = readPropertyKeyInt("Z1_H",160);
		Z_H[1]  = readPropertyKeyInt("Z2_H",220);
		Z_H[2]  = readPropertyKeyInt("Z3_H",250);
		Z_H[3]  = readPropertyKeyInt("Z4_H",270);
		Z_H[4]  = readPropertyKeyInt("Z5_H",300);
		Z_H[5]  = readPropertyKeyInt("Z6_H",410);

		Zone_L.add(0);
		for (var i = 0; i < Z_H.size() ; ++i)
   	   	{
			for (var j = 0; j < Zones_Number ; ++j)
   			{
				System.println("Zone " + j + " : " + Zone_L[j] + " - " + Zone_H[j]);
			}

			if ((Z_H[i] == 0) and (!Last_Zone))
			{
				Zone_H.add(Max_HR);
			}
			else
			{
				Zone_H.add(Z_H[i]);
				Zones_Number++;
				Zone_L.add(Zone_H[Zones_Number-1] + 1);
				if (i == (Z_H.size() - 1))
				{
					Zone_H.add(Max_Power);
				}
			}
		}
		System.println("Zone_L = " + Zone_L);
		System.println("Zone_H = " + Zone_H);

/*
		Zone_Loop_Index = 0;
		for (var i = 0; i <= Zones_Number ; ++i)
       	{
			Zone_Time[i] = 0;
			var j = i + 1;
			System.println("Zone " + j + " : " + Zone_L[i] + " - " + Zone_H[i]);
			for (var k = 0; k < Zone_Display_Timer; ++k)
    	   	{
    	   		Zone_Loop_Value[Zone_Loop_Index] = i;
    	   		Zone_Loop_Index++;
			}
		}
		Zone_Loop_Size = Zone_Loop_Index;
*/
		
		var Args = new [8];
		
		Args[0]  = readPropertyKeyInt("AVG_Power_Duration",3);
		Args[1] = getProperty("Reset_RecordValues");
		Args[2] = Label_Value;
		Args[3] = Duration_Value;
		Args[4] = Zone_L;
		Args[5] = Zone_H;
		Args[6] = readPropertyKeyInt("Zone_Display_Timer",2);
		Args[7] = readPropertyKeyInt("FTP",250);

		if (Args[1])
		{
			System.println("Going to reset Power Values Record...");
			ReadPowerFromProperty();
/*			
			for (var i = 0; i < TimeValues.size(); ++i)
			{
				RecordPowerValues[i] = 0;
			}
*/
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
			ReadPowerFromProperty();
/*
			for (var i = 0; i < TimeValues.size(); ++i)
			{
				RecordPowerValues[i] = 0;
			}
*/
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

	function ReadPowerFromProperty()
	{
		RecordPowerValues[0] = readPropertyKeyInt("Field_PP_00001s",0);
		RecordPowerValues[1] = readPropertyKeyInt("Field_PP_00002s",0);
		RecordPowerValues[2] = readPropertyKeyInt("Field_PP_00003s",0);
		RecordPowerValues[3] = readPropertyKeyInt("Field_PP_00005s",0);
		RecordPowerValues[4] = readPropertyKeyInt("Field_PP_00010s",0);
		RecordPowerValues[5] = readPropertyKeyInt("Field_PP_00015s",0);
		RecordPowerValues[6] = readPropertyKeyInt("Field_PP_00020s",0);
		RecordPowerValues[7] = readPropertyKeyInt("Field_PP_00030s",0);
		RecordPowerValues[8] = readPropertyKeyInt("Field_PP_00040s",0);
		RecordPowerValues[9] = readPropertyKeyInt("Field_PP_00060s",0);
		RecordPowerValues[10] = readPropertyKeyInt("Field_PP_00090s",0);
		RecordPowerValues[11] = readPropertyKeyInt("Field_PP_00120s",0);
		RecordPowerValues[12] = readPropertyKeyInt("Field_PP_00180s",0);
		RecordPowerValues[13] = readPropertyKeyInt("Field_PP_00300s",0);
		RecordPowerValues[14] = readPropertyKeyInt("Field_PP_00480s",0);
		RecordPowerValues[15] = readPropertyKeyInt("Field_PP_00600s",0);
		RecordPowerValues[16] = readPropertyKeyInt("Field_PP_00900s",0);
		RecordPowerValues[17] = readPropertyKeyInt("Field_PP_01200s",0);
		RecordPowerValues[18] = readPropertyKeyInt("Field_PP_01800s",0);
		RecordPowerValues[19] = readPropertyKeyInt("Field_PP_02400s",0);
		RecordPowerValues[20] = readPropertyKeyInt("Field_PP_03600s",0);
		RecordPowerValues[21] = readPropertyKeyInt("Field_PP_04800s",0);
		RecordPowerValues[22] = readPropertyKeyInt("Field_PP_06000s",0);
		RecordPowerValues[23] = readPropertyKeyInt("Field_PP_07200s",0);
		RecordPowerValues[24] = readPropertyKeyInt("Field_PP_09000s",0);
		RecordPowerValues[25] = readPropertyKeyInt("Field_PP_10800s",0);
	}

}