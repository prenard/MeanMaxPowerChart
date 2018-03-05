using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Math;
using Toybox.Application.Storage;

class MeanMaxPowerChartView extends Ui.DataField
{
	var app;
	
    var Rolling_Loop_Index;
    //var Rolling_Loop_Size;
	var Rolling_Loop_Value = new [0];

    var Rolling_Zone_Loop_Index;
    //var Rolling_Zone_Loop_Size;
	var Rolling_Zone_Loop_Value = new [0];

	var AVG_Power_Duration = 0;
	var AVG_Power_Duration_Idx = 0;
	
	var UserWeight;
	
	var AxisColor =  Gfx.COLOR_DK_GRAY;

	var CurrentPowerValuesLineColor =  Gfx.COLOR_GREEN;
	var RidePowerValuesLineColor =  Gfx.COLOR_DK_GREEN;
	var RidePowerValuesAreaColor =  0xC8C8C8;
	var RecordPowerValuesLineColor =  Gfx.COLOR_DK_GRAY;
	var RecordPowerValuesAreaColor =  0xE5E5E5;
	var DeltaRecordPowerValuesAreaColor =  Gfx.COLOR_RED;
	var LineWidth = 1;

	var PowerZonesPercent = [0,60,80];
	var PowerZonesColor = [Gfx.COLOR_DK_GREEN, Gfx.COLOR_YELLOW, Gfx.COLOR_RED];

    var PowerValuesHistory = new [2];
    var PowerValuesHistoryAvgPeriod = new [2];
	var PowerValuesHistoryIndex = new [2];
	var PowerValuesHistoryAvgSum = new [2];
	var PowerValuesHistoryAvgCount = new [2];

	var PWR_Label = "Pwr";
	var PWR_Label_x = 0;
	var PWR_Label_y = 0;
	var PWR_Label_font = Gfx.FONT_XTINY;

    var PWR_Value = 0;
	var PWR_Value_x = 0;
	var PWR_Value_y = 0;
	var PWR_Value_font = Gfx.FONT_XTINY;

	var CAD_Label = "Cad";
	var CAD_Label_x = 0;
	var CAD_Label_y = 0;
	var CAD_Label_font = Gfx.FONT_XTINY;
	
    var CAD_Value = 0;
	var CAD_Value_x = 0;
	var CAD_Value_y = 0;
	var CAD_Value_font = Gfx.FONT_XTINY;

	var HR_Label = "HR";
	var HR_Label_x = 0;
	var HR_Label_y = 0;
	var HR_Label_font = Gfx.FONT_XTINY;

    var HR_Value = 0;
	var HR_Value_x = 0;
	var HR_Value_y = 0;
	var HR_Value_font = Gfx.FONT_XTINY;

	var FTP = 0;
	var NP = 0;
	var NP_Samples_Number = 0;
	var	NP_Sum_30AvgP4 = 0;


	// Rolling Field

    var TimeOfDay_Value = "";
    var TimeOfDay_Meridiem_Value = "";
    var Distance_Value = 0;
    var Distance_Unit = "km";
    var Timer_Value = 0;
    var Time_Value = 0;
	var TSS_Value = 0;
	
	var RollingValue = "";
	var RollingValue_x = 0;
	var RollingValue_y = 0;
	var RollingValue_font = Gfx.FONT_XTINY;

	var RollingValue_Unit = "";
	var RollingValue_Unit_x = 0;
	var RollingValue_Unit_y = 0;
	var RollingValue_Unit_font = Gfx.FONT_XTINY;

	var RollingValue_Label = "";
	var RollingValue_Label_x = 0;
	var RollingValue_Label_y = 0;
	var RollingValue_Label_font = Gfx.FONT_XTINY;

	var ZoneRollingValue = "";
	var ZoneRollingValue_x = 0;
	var ZoneRollingValue_y = 0;
	var ZoneRollingValue_font = Gfx.FONT_XTINY;
	var ZoneRollingValue_font_Color = Gfx.COLOR_BLACK;

	var ZoneRollingValue_Label = "";
	var ZoneRollingValue_Label_x = 0;
	var ZoneRollingValue_Label_y = 0;
	var ZoneRollingValue_Label_font = Gfx.FONT_XTINY;


	var	X_bar_x_left = 0;
	var	X_bar_x_right = 0;
	var X_bar_y = 0;
	var X_bar_font = Gfx.FONT_XTINY;
	var X_bar_Unit_font = Gfx.FONT_XTINY;
		
	var	Y_bar_x = 0;
	var	Y_bar_y_top = 0;
	var Y_bar_y_bottom = 0;
	var Y_bar_font = Gfx.FONT_XTINY;
	
	var BatteryLevelBitmap;
	var BatteryLevelBitmap_x = 0;
	var BatteryLevelBitmap_y = 0;
	var BatteryLevel = 0;
	var BatteryLevel_font = Gfx.FONT_XTINY;

	var Zone_Color_Gray = 0xABABAB;
	var Zone_Color_Blue = 0x00B0F0;
	var Zone_Color_Green = 0x92D050;
	var Zone_Color_Yellow = 0xFFFF00;
	var Zone_Color_Orange = 0xF79646;
	var Zone_Color_Red = 0xFF0000;
	var Zone_Color_Dark_Red = 0xD80000;

	var Zone_L;
	var Zone_H;
	var Max_Zone_Display_Timer = 10;
	var Zone_Display_Timer = 0;
	var Zone_Color = [Zone_Color_Gray,Zone_Color_Blue,Zone_Color_Green,Zone_Color_Yellow,Zone_Color_Orange,Zone_Color_Red,Zone_Color_Dark_Red];

	var Zone_Time;
    var Zone_Loop_Index;
    var Zone_Loop_Size;
	var Zone_Loop_Value;
	
    function initialize(Args)
    {
        DataField.initialize();

        app = App.getApp();

	    //Device_Type = Ui.loadResource(Rez.Strings.Device);
		System.println("Device_Type = " + app.Device_Type);

		AVG_Power_Duration		= Args[0];
		System.println("AVG_Power_Duration = " + AVG_Power_Duration);

		for (var i = 0; i < app.TimeValues.size(); ++i)
		{
			if (app.TimeValues[i] == AVG_Power_Duration)
			{
				AVG_Power_Duration_Idx = i;
				break;
			}
		}

		System.println("RecordPowerValue = " + Storage.getValue("RecordPowerValues"));

		System.println("TimeValues.size() = " + app.TimeValues.size()); 
		System.println("TimeValuesAvgPeriod.size() = " + app.TimeValuesAvgPeriod.size());

		var Label_Value = Args[2];
		var Duration_Value = Args[3];

		Zone_L = Args[4];
		Zone_H = Args[5];
		Zone_Display_Timer = Args[6];
		FTP = Args[7];

		Zone_Time = new [app.Max_Zones_Number];
		Zone_Loop_Value = new [Max_Zone_Display_Timer * app.Max_Zones_Number];

		Zone_Loop_Index = 0;
		for (var i = 0; i <= app.Zones_Number ; ++i)
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

		Rolling_Zone_Loop_Index = 0;
		for (var i = 0; i < Zone_L.size() ; ++i)
       	{
			Initialize_Rolling_Zone_Loop_Value(i,Zone_Display_Timer);
		}
		//Rolling_Zone_Loop_Index = 0;
		
		Rolling_Loop_Index = 0;
		for (var i = 0; i < Label_Value.size() ; ++i)
       	{
			//System.println(Label_Value[i]);
       	   	if (Label_Value[i] != null)
       	   	{
				Initialize_Rolling_Loop_Value(Label_Value[i],Duration_Value[i]);
       	   		//Rolling_Loop_Size += Duration_Value[i];
       	   	}
		}
		//Rolling_Loop_Index = 0;


		PowerValuesHistoryAvgPeriod[0] = 1; 
		PowerValuesHistory[0] = new [300];
		PowerValuesHistoryAvgPeriod[1] = 5; 
		PowerValuesHistory[1] = new [2160];

		if (app.Device_Type.equals("edge_520"))
		{
		}
		else
		if (app.Device_Type.equals("edge_820"))
		{
			PWR_Label_x = 100;
			PWR_Label_y = 1;
			PWR_Label_font = Gfx.FONT_XTINY;

			PWR_Value_x = 199;
			PWR_Value_y = 1;
			PWR_Value_font = Gfx.FONT_NUMBER_HOT;

			CAD_Label_x = 100;
			CAD_Label_y = 41;
			CAD_Label_font = Gfx.FONT_XTINY;

			CAD_Value_x = 199;
			CAD_Value_y = 41;
			CAD_Value_font = Gfx.FONT_NUMBER_HOT;

			HR_Label_x = 100;
			HR_Label_y = 81;
			HR_Label_font = Gfx.FONT_XTINY;

			HR_Value_x = 199;
			HR_Value_y = 81;
			HR_Value_font = Gfx.FONT_NUMBER_HOT;

			RollingValue_x = 199;
			RollingValue_y = 237;
			RollingValue_font = Gfx.FONT_NUMBER_MILD;

			RollingValue_Unit_x = 199;
			RollingValue_Unit_y = 226;
			RollingValue_Unit_font = Gfx.FONT_XTINY;

			RollingValue_Label_x = 175;
			RollingValue_Label_y = 226;
			RollingValue_Label_font = Gfx.FONT_XTINY;

			ZoneRollingValue = "";
			ZoneRollingValue_x = 0;
			ZoneRollingValue_y = 237;
			ZoneRollingValue_font = Gfx.FONT_NUMBER_MILD;

			ZoneRollingValue_Label = "";
			ZoneRollingValue_Label_x = 0;
			ZoneRollingValue_Label_y = 226;
			ZoneRollingValue_Label_font = Gfx.FONT_XTINY;


			X_bar_x_left = 35;
			X_bar_x_right = 190;
			X_bar_y = 210;
			X_bar_font = Gfx.FONT_SMALL;
			
			Y_bar_y_top = 20;
			Y_bar_font = Gfx.FONT_SMALL;

			BatteryLevelBitmap_x = 35; 
			BatteryLevelBitmap_y = 1;
		}
		
		Y_bar_x = X_bar_x_left;
		Y_bar_y_bottom = X_bar_y;

		BatteryLevelBitmap = new Ui.Bitmap({:rezId=>Rez.Drawables.BatteryLevel100});

		for (var i = 0; i < PowerValuesHistory.size(); ++i)
		{
			//System.println("During PowerValuesHistory Array Allocation - " + i + " - Total Memory = " + System.getSystemStats().totalMemory + " / Used Memory = " + System.getSystemStats().usedMemory);

			PowerValuesHistoryIndex[i] = 0;
			PowerValuesHistoryAvgSum[i] = 0;
			PowerValuesHistoryAvgCount[i] = 0;
			for (var j = 0; j < PowerValuesHistory[i].size(); ++j)
			{
				PowerValuesHistory[i][j] = 0;
			}
		}
		
		for (var i = 0; i < app.TimeValues.size(); ++i)
		{
			app.TimeValuesValid[i] = false;
			app.PowerSumOfSamples[i] = 0;
			app.PowerNumberOfSamples[i] = 0;
			app.CurrentPowerValues[i] = 0;
			app.RidePowerValues[i] = 0;
			app.TimeValues_x[i] = X_bar_x_left + (X_bar_x_right - X_bar_x_left + 1) * Math.log(app.TimeValues[i], 10) / Math.log(app.TimeValues[app.TimeValues.size() - 1], 10); 
			System.println("TimeValues_x[" + i + "] = " + app.TimeValues_x[i]);
		}

		UserWeight =  UserProfile.getProfile().weight / 1000;
		System.println("UserWeight = " + UserWeight);
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc)
    {

    	System.println("DC Height  = " + dc.getHeight());
      	System.println("DC Width  = " + dc.getWidth());

		BatteryLevelBitmap.setLocation(BatteryLevelBitmap_x,BatteryLevelBitmap_y);
		
    	View.setLayout(Rez.Layouts.MainLayout(dc));

        return true;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info)
    {

        if( (info.currentHeartRate != null))
        {
			HR_Value = info.currentHeartRate;
		}
/*
        if( (info.currentPower != null))
        {
			PWR_Value = info.currentPower;
		}
*/
        if( (info.currentCadence != null))
        {
			CAD_Value = info.currentCadence;
		}

		// Manage Rolling Field

		if( info.elapsedTime != null )
            {
                Time_Value = TimeFormat((info.elapsedTime / 1000), "h:mm:ss");
            }
		
		if( info.timerTime != null )
            {
                Timer_Value = TimeFormat((info.timerTime / 1000), "h:mm:ss");
            }

		Distance_Value = 0;
		if( info.elapsedDistance != null )
    	    {
        	    Distance_Value = (info.elapsedDistance / 1000);
            }

		/* Time Of Day value */
		
		var time = Time.now().value() + System.getClockTime().timeZoneOffset;
    	var hour = (time / 3600) % 24;
		var min = (time / 60) % 60;
		var sec = time % 60;
		
		// Process 12/24 hr differences
		var meridiemTxt = "";

		if (System.getDeviceSettings().is24Hour)
		 {
			if(0 == time)
			 {
				hour = 24;
			 }
			else 
			 {
				hour = hour % 24;
			 }
		 }
		else
		 {
			if(12 > hour)
			 {
				meridiemTxt = "AM";
			 }
			else
			 {
				meridiemTxt = "PM";
			 }
			hour = 1 + (hour + 11) % 12;
		 }

		// Format time
    	var timeStr = format("$1$:$2$", [hour.format("%01d"), min.format("%02d")]);
		
		TimeOfDay_Value = timeStr;
		TimeOfDay_Meridiem_Value = meridiemTxt;




        if (info.currentPower != null && info.elapsedTime != null && info.elapsedTime > 0)
        {
			//System.println("==> New - info.currentPower = " + info.currentPower);

			Zone_Time[GetPowerZone(info.currentPower)]++;
			
			for (var i = 0; i < PowerValuesHistory.size(); ++i)
			{
				PowerValuesHistoryAvgSum[i] += info.currentPower;
				PowerValuesHistoryAvgCount[i]++;
				if (((PowerValuesHistoryAvgCount[i] % PowerValuesHistoryAvgPeriod[i]) == 0))
				{

		           	for (var j = 0; j < app.TimeValues.size(); ++j)
		           	{
		           		if ((app.TimeValuesAvgPeriod[j] == i))
		           		{
        					var OldestIndex = (PowerValuesHistoryIndex[i] - (app.TimeValues[j] / PowerValuesHistoryAvgPeriod[app.TimeValuesAvgPeriod[j]]) + PowerValuesHistory[i].size()) % (PowerValuesHistory[i].size());
							app.PowerSumOfSamples[j] -= PowerValuesHistory[i][OldestIndex];
							app.PowerSumOfSamples[j] += PowerValuesHistoryAvgSum[i] / PowerValuesHistoryAvgCount[i];
							app.PowerNumberOfSamples[j]++;
							if ((app.PowerNumberOfSamples[j] * PowerValuesHistoryAvgPeriod[app.TimeValuesAvgPeriod[j]]) >= app.TimeValues[j])
							{
								app.TimeValuesValid[j] = true;
								app.CurrentPowerValues[j] = app.PowerSumOfSamples[j] / (app.TimeValues[j] / PowerValuesHistoryAvgPeriod[app.TimeValuesAvgPeriod[j]]);
								// Compute NP
								if (app.TimeValues[j] == 30)
								{
									NP_Samples_Number++;
									NP_Sum_30AvgP4 += Math.pow(app.CurrentPowerValues[j], 4);
									NP = Math.sqrt(Math.sqrt(NP_Sum_30AvgP4 / NP_Samples_Number));
									System.println("NP = " + NP);
									TSS_Value = ((info.elapsedTime / 1000) * NP * (NP / FTP) / (FTP * 3600)) * 100;
									System.println("TSS = " + TSS);
								}
								if (app.CurrentPowerValues[j] > app.RidePowerValues[j])
								{
									app.RidePowerValues[j] = app.CurrentPowerValues[j];
									if (app.RidePowerValues[j] > app.RecordPowerValues[j])
									{
										app.RecordPowerValues[j] = app.RidePowerValues[j];
										System.println("Saving new RecordPowerValues to storage... RecordPowerValues = " + app.RecordPowerValues);
										Storage.setValue("RecordPowerValues",app.RidePowerValues);
									}
								}
								
								//System.println("Valid - TimeValues[" + j + "] = " + app.TimeValues[j] + " - CurrentPowerValues[" + j + "] = " + app.CurrentPowerValues[j] + " - RidePowerValues[" + j + "] = " + app.RidePowerValues[j]); 
							}
							//PowerValuesHistoryIndex[j] = (PowerValuesHistoryIndex[j] + 1) % PowerValuesHistory[j].size();
		           		}
					}
					PowerValuesHistory[i][PowerValuesHistoryIndex[i]] = PowerValuesHistoryAvgSum[i] / PowerValuesHistoryAvgCount[i];
					//PowerValuesHistoryIndex[i]++;
					PowerValuesHistoryIndex[i] = (PowerValuesHistoryIndex[i] + 1) % PowerValuesHistory[i].size();
					//System.println("PowerValuesHistory[" + i + "] = " + PowerValuesHistory[i]);
					//System.println("PowerValuesHistoryIndex[" + i + "] = " + PowerValuesHistoryIndex[i]);
					PowerValuesHistoryAvgSum[i] = 0;
					PowerValuesHistoryAvgCount[i] = 0;

				}
			}
/*
			for (var i = 0; i < PowerValuesHistory.size(); ++i)
			{
				for (var j = 0; j < PowerValuesHistoryIndex[i]; ++j)
				{
					System.println("PowerValuesHistory[" + i + "] [" + j + "] = " + PowerValuesHistory[i][j]);

        			// subtract the oldest sample from our moving sum
        			var OldestIndex = (PowerValuesHistoryIndex[j] - TimeValues[j] + PowerValuesHistory[j].size()) % (PowerValuesHistory[j].size());
					System.println("Before - " + TimeValues[j] + " - PowerSumOfSamples[" + j + "] = " + PowerSumOfSamples[j]);
					System.println("OldestIndex = " + OldestIndex);
					PowerSumOfSamples[j] -= PowerValuesHistory[j][OldestIndex]; 

					// add the newest sample to our moving sum
					//PowerSumOfSamples[j] += PowerValuesHistory[j][PowerValuesHistoryIndex[i];
					//System.println("After - " + TimeValues[j] + " - PowerSumOfSamples[" + j + "] = " + PowerSumOfSamples[j]);]


				}
			}
*/

//			PowerValuesHistory[PowerValuesHistoryIndex] = info.currentPower;
//			System.println("PowerValuesHistory[" + PowerValuesHistoryIndex + "] = " + PowerValuesHistory[PowerValuesHistoryIndex]);

/*			
           	for (var i = 0; i < TimeValues.size(); ++i)
       		{
				var AvgPeriod = TimeValuesAvgPeriod[i];
				
				System.println("TimeValues[" + i + "] = " + TimeValues[i] + " - TimeValuesAvgPeriod[" + i + "] =  " + TimeValuesAvgPeriod[i]);
        		// subtract the oldest sample from our moving sum
        		var OldestIndex = (PowerValuesHistoryIndex - TimeValues[i] + PowerValuesHistory.size()) % (PowerValuesHistory.size());
				System.println("Before - " + TimeValues[i] + " - PowerSumOfSamples[" + i + "] = " + PowerSumOfSamples[i]);
				System.println("OldestIndex = " + OldestIndex);
				PowerSumOfSamples[i] -= PowerValuesHistory[OldestIndex]; 

				// add the newest sample to our moving sum
				PowerSumOfSamples[i] += PowerValuesHistory[PowerValuesHistoryIndex];
				System.println("After - " + TimeValues[i] + " - PowerSumOfSamples[" + i + "] = " + PowerSumOfSamples[i]);
			}
*/
			// Goe to the next sample, and wrap around to the beginning
//			PowerValuesHistoryIndex = (PowerValuesHistoryIndex + 1) % PowerValuesHistory.size();

		}

    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc)
    {

		BatteryLevel = System.getSystemStats().battery;
		//System.println("BatteryLevel = " + BatteryLevel);
		var BatteryLevelBitmapIdentifier = Rez.Drawables.BatteryLevel100;
		if (BatteryLevel > 75)
		{
			BatteryLevelBitmapIdentifier = Rez.Drawables.BatteryLevel100;
		}
		else
		if (BatteryLevel > 50)
		{
			BatteryLevelBitmapIdentifier = Rez.Drawables.BatteryLevel075;
		}
		else
		if (BatteryLevel > 25)
		{
			BatteryLevelBitmapIdentifier = Rez.Drawables.BatteryLevel050;
		}
		else
		{
			BatteryLevelBitmapIdentifier = Rez.Drawables.BatteryLevel025;
		}

        // Set the background color
        View.findDrawableById("Background").setColor(getBackgroundColor());

		var FontDisplayColor = Gfx.COLOR_BLACK;

        if (getBackgroundColor() == Gfx.COLOR_BLACK)
        {
            FontDisplayColor = Gfx.COLOR_WHITE;
        }
        else
        {
            FontDisplayColor = Gfx.COLOR_BLACK;
        }

		// Manage Zone Rolling Field

  	    Rolling_Zone_Loop_Index = (Rolling_Zone_Loop_Index + 1) % Rolling_Zone_Loop_Value.size();

  	    ZoneRollingValue = TimeFormat(Zone_Time[Rolling_Zone_Loop_Value[Rolling_Zone_Loop_Index]], "m:ss");
 		ZoneRollingValue_Label = "Zone " + (Rolling_Zone_Loop_Value[Rolling_Zone_Loop_Index] + 1) + " " + Zone_L[Rolling_Zone_Loop_Value[Rolling_Zone_Loop_Index]] + "-" + Zone_H[Rolling_Zone_Loop_Value[Rolling_Zone_Loop_Index]];
		ZoneRollingValue_font_Color = Zone_Color[Rolling_Zone_Loop_Value[Rolling_Zone_Loop_Index]];
  	    
		// Manage Rolling Field

  	    Rolling_Loop_Index = (Rolling_Loop_Index + 1) % Rolling_Loop_Value.size();
  	   
  	    var Field = Rolling_Loop_Value[Rolling_Loop_Index];
  	    var Value_Picked = "";
  	    var Value_Unit_Picked = "";

		RollingValue_Label = Field;

		if (Field.equals(Ui.loadResource(Rez.Strings.Field_Time_Label_Title)))
		//if (Field.equals("Time"))
		{
            Value_Picked = Time_Value.toString();
			Value_Unit_Picked = "";
		}
		else
		if (Field.equals(Ui.loadResource(Rez.Strings.Field_Timer_Label_Title)))
		//if (Field.equals("Timer"))
		{
            Value_Picked = Timer_Value.toString();
			Value_Unit_Picked = "";
		}
		else
		if (Field.equals(Ui.loadResource(Rez.Strings.Field_Distance_Label_Title)))
		//if (Field.equals("Distance")) 
		{

			if (System.getDeviceSettings().distanceUnits == System.UNIT_METRIC)
			  {
				Value_Unit_Picked = "km";
			  }
			 else
			 {
				var km_mi_conv = 0.621371;
				Value_Unit_Picked = "mi";
				Distance_Value = Distance_Value * km_mi_conv;
			 }
			//System.println(Distance_Value);
            Value_Picked = Distance_Value.format("%.1f").toString();
		}
		else
		if (Field.equals(Ui.loadResource(Rez.Strings.Field_TimeOfDay_Label_Title)))
		{
            Value_Picked = TimeOfDay_Value.toString();
            Value_Unit_Picked = TimeOfDay_Meridiem_Value.toString();
		}
		else
		if (Field.equals(Ui.loadResource(Rez.Strings.Field_TSS_Label_Title)))
		{
            Value_Picked = TSS_Value.format("%.1f").toString();
            Value_Unit_Picked = "";
		}


		RollingValue = Value_Picked;
 		RollingValue_Unit = Value_Unit_Picked;


        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);

		var PowerMax = Math.ceil((max(app.RecordPowerValues[0],Zone_L[Zone_L.size()-1] + 100).toFloat() / 100)) * 100;
		if (PowerMax == 0)
		{
			PowerMax = 100;
		}
		//System.println("RidePowerValues[0] = " + app.RidePowerValues[0] + " - PowerMax = " + PowerMax);

		dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
   		dc.setPenWidth(1);
   		dc.drawLine(X_bar_x_right, X_bar_y, X_bar_x_left, X_bar_y);
   		dc.drawLine(Y_bar_x, Y_bar_y_top, Y_bar_x, Y_bar_y_bottom);

		for (var i = 0; i < (app.TimeValues.size() - 1); ++i)
		{

			if (app.RecordPowerValues[i] > 0 and app.RecordPowerValues[i + 1] > 0)
			{
				// Draw Record Curve
				var y1 = Y_bar_y_bottom - (Y_bar_y_bottom - Y_bar_y_top + 1) * app.RecordPowerValues[i] / PowerMax;
				var y2 = Y_bar_y_bottom - (Y_bar_y_bottom - Y_bar_y_top + 1) * app.RecordPowerValues[i + 1] / PowerMax;

				dc.setColor(RecordPowerValuesAreaColor, Gfx.COLOR_TRANSPARENT);
				dc.fillPolygon([[app.TimeValues_x[i], Y_bar_y_bottom], [app.TimeValues_x[i], y1], [app.TimeValues_x[i+1], y2], [app.TimeValues_x[i+1], Y_bar_y_bottom]]);

				dc.setColor(RecordPowerValuesLineColor, Gfx.COLOR_TRANSPARENT);
   				dc.setPenWidth(LineWidth);
   				dc.drawLine(app.TimeValues_x[i], y1, app.TimeValues_x[i + 1], y2);
			}

			if (app.RidePowerValues[i] > 0 and app.RidePowerValues[i + 1] > 0)
			{
				// Draw Ride Curve
				var y1 = Y_bar_y_bottom - (Y_bar_y_bottom - Y_bar_y_top + 1) * app.RidePowerValues[i] / PowerMax;
				var y2 = Y_bar_y_bottom - (Y_bar_y_bottom - Y_bar_y_top + 1) * app.RidePowerValues[i + 1] / PowerMax;
				//System.println("y1 = " + y1 + " - y2 = " + y2);

				dc.setColor(RidePowerValuesAreaColor, Gfx.COLOR_TRANSPARENT);
				dc.fillPolygon([[app.TimeValues_x[i], Y_bar_y_bottom], [app.TimeValues_x[i], y1], [app.TimeValues_x[i+1], y2], [app.TimeValues_x[i+1], Y_bar_y_bottom]]);

				dc.setColor(RidePowerValuesLineColor, Gfx.COLOR_TRANSPARENT);
   				dc.setPenWidth(LineWidth);
   				dc.drawLine(app.TimeValues_x[i], y1, app.TimeValues_x[i + 1], y2);
			}

			if (app.RecordPowerValues[i] > 0 and app.RecordPowerValues[i + 1] > 0)
			{
				// Draw Record Curve
				var y1 = Y_bar_y_bottom - (Y_bar_y_bottom - Y_bar_y_top + 1) * app.RecordPowerValues[i] / PowerMax;
				var y2 = Y_bar_y_bottom - (Y_bar_y_bottom - Y_bar_y_top + 1) * app.RecordPowerValues[i + 1] / PowerMax;

				// Draw Record Curve - Delta
				if ((app.RecordPowerValues[i] > app.PreviousRecordPowerValues[i]) or (app.RecordPowerValues[i+1] > app.PreviousRecordPowerValues[i+1]))
				{
					System.println("New Record !");
					System.println("RecordPowerValues = " + app.RecordPowerValues);
					System.println("PreviousRecordPowerValues = " + app.PreviousRecordPowerValues);

					var py1 = Y_bar_y_bottom - (Y_bar_y_bottom - Y_bar_y_top + 1) * app.PreviousRecordPowerValues[i] / PowerMax;
					var py2 = Y_bar_y_bottom - (Y_bar_y_bottom - Y_bar_y_top + 1) * app.PreviousRecordPowerValues[i + 1] / PowerMax;

					dc.setColor(DeltaRecordPowerValuesAreaColor, Gfx.COLOR_TRANSPARENT);


					if ((app.RecordPowerValues[i] > app.PreviousRecordPowerValues[i]) and (app.RecordPowerValues[i+1] > app.PreviousRecordPowerValues[i+1]))
					{
						dc.fillPolygon([[app.TimeValues_x[i], py1], [app.TimeValues_x[i], y1], [app.TimeValues_x[i+1], y2], [app.TimeValues_x[i+1], py2]]);
					} 
					else
					{
						if (app.RecordPowerValues[i] > app.PreviousRecordPowerValues[i])
						{
							dc.fillPolygon([[app.TimeValues_x[i], py1], [app.TimeValues_x[i], y1], [app.TimeValues_x[i+1], y2]]);
						}
						else
						{
							dc.fillPolygon([[app.TimeValues_x[i], y1], [app.TimeValues_x[i+1], y2], [app.TimeValues_x[i+1], py2]]);
						}
					}

				}

			}

			if (app.RidePowerValues[i] > 0 and app.RidePowerValues[i + 1] > 0)
			{
				// Draw Current Curve

				var CurrentPowerZoneColor = Gfx.COLOR_TRANSPARENT;

				var y1 = Y_bar_y_bottom - (Y_bar_y_bottom - Y_bar_y_top + 1) * app.CurrentPowerValues[i] / PowerMax;
				var y2 = Y_bar_y_bottom - (Y_bar_y_bottom - Y_bar_y_top + 1) * app.CurrentPowerValues[i + 1] / PowerMax;

				CurrentPowerZoneColor = Zone_Color[GetPowerZone(app.CurrentPowerValues[i])];
/*
				for (var j = (PowerZonesPercent.size() - 1); j >= 0; --j)
				{
					//System.println("Looking for Power color...");
					if ((app.CurrentPowerValues[i] > (PowerZonesPercent[j].toFloat() / 100 * app.RecordPowerValues[i])) or (app.CurrentPowerValues[i+1] > (PowerZonesPercent[j].toFloat() / 100 * app.RecordPowerValues[i+1])))
					{
						//System.println("... Color is found !");
						CurrentPowerZoneColor = PowerZonesColor[j];
						break;
					}
				}
*/
				dc.setColor(CurrentPowerZoneColor, Gfx.COLOR_TRANSPARENT);
				dc.fillPolygon([[app.TimeValues_x[i], Y_bar_y_bottom], [app.TimeValues_x[i], y1], [app.TimeValues_x[i+1], y2], [app.TimeValues_x[i+1], Y_bar_y_bottom]]);

				dc.setColor(CurrentPowerValuesLineColor, Gfx.COLOR_TRANSPARENT);
   				dc.setPenWidth(LineWidth);
   				dc.drawLine(app.TimeValues_x[i], y1, app.TimeValues_x[i + 1], y2);
			}
		}



		// Draw Y axis
/*		
		for (var i = 0; i < ((PowerMax / 100) + 1); ++i)
		{
			var y = Y_bar_y_bottom - (Y_bar_y_bottom - Y_bar_y_top + 1) * (i * 100) / PowerMax; 
			//System.println("y = " + y);
			dc.setColor(AxisColor, Gfx.COLOR_TRANSPARENT);
   			dc.setPenWidth(1);
   			dc.drawLine(Y_bar_x - 0, y, X_bar_x_right, y);
			textR(dc, Y_bar_x - 5, y - 10, Y_bar_font, FontDisplayColor, (i * 100).toString());
			// Watts / Kg 
			//textL(dc, Y_bar_x + 5, y - 10, Y_bar_font, FontDisplayColor, (i.toFloat() * 100 / UserWeight).format("%.1f").toString());
		}
*/

		//System.println("PowerMax = " + PowerMax);
		DrawHorizontalAxis(dc,0,AxisColor,1,PowerMax,FontDisplayColor,true);


		for (var i = 1; i < Zone_L.size(); ++i)
		{
			var y = Y_bar_y_bottom - (Y_bar_y_bottom - Y_bar_y_top + 1) * Zone_L[i] / PowerMax; 
			var ShowPowerValue = false;
			if (i == Rolling_Zone_Loop_Value[Rolling_Zone_Loop_Index])
			{
				ShowPowerValue = true;
			}
			DrawHorizontalAxis(dc,Zone_L[i],Zone_Color[i],2,PowerMax,Zone_Color[i],ShowPowerValue);
		}
		DrawHorizontalAxis(dc,PowerMax,AxisColor,1,PowerMax,FontDisplayColor,true);

		// Draw X axis
		
		for (var i = 0; i < app.TimeValues.size(); ++i)
		{
			var GridTop_y = X_bar_y;
			
			if (app.TimeValuesX[i] == 1)
			{
				var TimeValueToDisplay = app.TimeValues[i];
				for (var j = 0; j < 2; j++)
				{
					if ((TimeValueToDisplay / 60) >= 1)
					{
						TimeValueToDisplay = TimeValueToDisplay / 60;
					}
				}
				textR(dc, app.TimeValues_x[i], X_bar_y + 2, X_bar_font, FontDisplayColor, Gfx.COLOR_TRANSPARENT, (TimeValueToDisplay).toString());

				var TimeUnitToDisplay = "";
				
				if (app.TimeValues[i] == 1)
				{
					TimeUnitToDisplay = "S";
				}
				else
				if (app.TimeValues[i] == 60)
				{
					TimeUnitToDisplay = "M";
				}
				else
				if (app.TimeValues[i] == 3600)
				{
					TimeUnitToDisplay = "H";
				}

				textL(dc, app.TimeValues_x[i] + 1, X_bar_y + 7, X_bar_Unit_font, FontDisplayColor, Gfx.COLOR_TRANSPARENT, (TimeUnitToDisplay).toString());
				GridTop_y = Y_bar_y_top;
			}
			dc.setColor(AxisColor, Gfx.COLOR_TRANSPARENT);
   			dc.setPenWidth(1);
   			dc.drawLine(app.TimeValues_x[i], GridTop_y, app.TimeValues_x[i], X_bar_y + 5);
		}


		PWR_Value = app.CurrentPowerValues[AVG_Power_Duration_Idx];

		textL(dc, PWR_Label_x, PWR_Label_y, PWR_Label_font, FontDisplayColor, Gfx.COLOR_TRANSPARENT, PWR_Label);
		textL(dc, PWR_Label_x, PWR_Label_y + 10, PWR_Label_font, FontDisplayColor, Gfx.COLOR_TRANSPARENT, AVG_Power_Duration.toString() + " s");
		textR(dc, PWR_Value_x, PWR_Value_y, PWR_Value_font, FontDisplayColor, Gfx.COLOR_TRANSPARENT, PWR_Value.toString());

		textL(dc, CAD_Label_x, CAD_Label_y, CAD_Label_font, FontDisplayColor, Gfx.COLOR_TRANSPARENT, CAD_Label);
		textR(dc, CAD_Value_x, CAD_Value_y, CAD_Value_font, FontDisplayColor, Gfx.COLOR_TRANSPARENT, CAD_Value.toString());

		textL(dc, HR_Label_x, HR_Label_y, HR_Label_font, FontDisplayColor, Gfx.COLOR_TRANSPARENT, HR_Label);
		textR(dc, HR_Value_x, HR_Value_y, HR_Value_font, FontDisplayColor, Gfx.COLOR_TRANSPARENT, HR_Value.toString());

		textL(dc, ZoneRollingValue_x, ZoneRollingValue_y, ZoneRollingValue_font, Gfx.COLOR_BLACK, ZoneRollingValue_font_Color, ZoneRollingValue.toString());
		textL(dc, ZoneRollingValue_Label_x, ZoneRollingValue_Label_y, ZoneRollingValue_Label_font, FontDisplayColor, Gfx.COLOR_TRANSPARENT, ZoneRollingValue_Label.toString());

		//textR(dc, Timer_Value_x, Timer_Value_y, Timer_Value_font, FontDisplayColor, Timer_Value.toString());
		textR(dc, RollingValue_x, RollingValue_y, RollingValue_font, FontDisplayColor, Gfx.COLOR_TRANSPARENT, RollingValue.toString());
		textR(dc, RollingValue_Unit_x, RollingValue_Unit_y, RollingValue_Unit_font, FontDisplayColor, Gfx.COLOR_TRANSPARENT, RollingValue_Unit.toString());
		textR(dc, RollingValue_Label_x, RollingValue_Label_y, RollingValue_Label_font, FontDisplayColor, Gfx.COLOR_TRANSPARENT, RollingValue_Label.toString());

		BatteryLevelBitmap.setBitmap(BatteryLevelBitmapIdentifier);
		textL(dc, BatteryLevelBitmap_x + 25, BatteryLevelBitmap_y, BatteryLevel_font, FontDisplayColor, Gfx.COLOR_TRANSPARENT, BatteryLevel.format("%.0f").toString() + "%");
		BatteryLevelBitmap.draw(dc);

		/*
		for (var i = 0; i < Zone_L.size(); ++i)
		{
			System.println("TimeFormat(Zone_Time[" + i + "]) = " + TimeFormat(Zone_Time[i], "m:ss"));
		}
		*/
    }

	function textR(dc, x, y, font, fg_color, bg_color, s)
	{
		if (s != null)
		{
			dc.setColor(fg_color, bg_color);
			dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_RIGHT);
			//dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
		}
	}

	function textL(dc, x, y, font, fg_color, bg_color, s)
	{
		if (s != null)
		{
			dc.setColor(fg_color, bg_color);
			dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_LEFT);
			//dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
		}
	}

    function Initialize_Rolling_Loop_Value(Value,Duration)
    {
		for (var i = 0; i < Duration; ++i)
       	{
			Rolling_Loop_Value.add(Value);
			//Rolling_Loop_Index++;
		}
        return true;
	}

    function Initialize_Rolling_Zone_Loop_Value(Value,Duration)
    {
		for (var i = 0; i < Duration; ++i)
       	{
			Rolling_Zone_Loop_Value.add(Value);
		}
        return true;
	}


    function min(a,b)
    {
		var min_value = b;
		if (a < b)
		{
			min_value = a;
		}
        return min_value;
	}

    function max(a,b)
    {
		var max_value = a;
		if (a < b)
		{
			max_value = b;
		}
        return max_value;
	}

	function DrawHorizontalAxis(dc,PowerValue,AxisColor,AxisWidth,PowerMax,FontDisplayColor,ShowPowerValue)
	{
		var y = Y_bar_y_bottom - (Y_bar_y_bottom - Y_bar_y_top + 1) * PowerValue / PowerMax; 
		dc.setColor(AxisColor, Gfx.COLOR_TRANSPARENT);
		dc.setPenWidth(AxisWidth);
		dc.drawLine(Y_bar_x - 0, y, X_bar_x_right, y);
		if (ShowPowerValue)
		{
			textR(dc, Y_bar_x - 5, y - 10, Y_bar_font, FontDisplayColor, Gfx.COLOR_TRANSPARENT, PowerValue.format("%.0f").toString());
		}
	}

    function GetPowerZone(pwr)
    {
		var Power_Zone = 0;
		for (var i = 0; i < Zone_L.size() ; ++i)
    	{
    		if ((Zone_L[i] <= pwr) and (pwr <= Zone_H[i]))
    	   	{
    	   		Power_Zone = i;
    	   		return Power_Zone;
    	   	}
        }
    	return Power_Zone;
	}

    function TimeFormat(Seconds,format)
    {
		var Rest;
               
		var Hour   = (Seconds - Seconds % 3600) / 3600; 
		Rest = Seconds - Hour * 3600;
		var Minute = (Rest - Rest % 60) / 60;
		var Second = Rest - Minute * 60; 

		var Return_Value = "h:mm:ss";
		
		if (format.equals("h:mm:ss"))
		{
			Return_Value = Hour.format("%d") + ":" + Minute.format("%02d") + ":" + Second.format("%02d");
		}
		else
		if (format.equals("h:mm"))
		{
			Return_Value = Hour.format("%d") + ":" + Minute.format("%02d");
		}
		else
		if (format.equals("m:ss"))
		{
			Return_Value = (Hour * 60 + Minute).format("%1d") + ":" + Second.format("%02d");
		}

		return Return_Value;
    }

}