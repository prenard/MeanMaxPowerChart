using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Math;

class MeanMaxPowerChartView extends Ui.DataField
{
	var Device_Type;

	var TimeValues = [1,2,3,5,10,15,20,30,40,60,90,120,180,300,600,900,1200,1800,2400,3600,4800,6000,7200,9000,10800];
	var TimeValuesAvgPeriod = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1];
	var TimeValuesValid = new [TimeValues.size()];
	var TimeValues_x = new [TimeValues.size()];
	var TimeValuesX = [1,0,0,1,0,0,0,0,0,1,0,0,0,1,0,0,1,0,0,1,0,0,0,0,1];
	
	var CurrentPowerValues = new [TimeValues.size()];
	var RidePowerValues = new [TimeValues.size()];
	
	var PowerSumOfSamples = new [TimeValues.size()];
	var PowerNumberOfSamples = new [TimeValues.size()];

    var PowerValuesHistory = new [2];
    var PowerValuesHistoryAvgPeriod = new [2];
	var PowerValuesHistoryIndex = new [2];
	var PowerValuesHistoryAvgSum = new [2];
	var PowerValuesHistoryAvgCount = new [2];

    var HR_Value = 0;

	var HR_Value_x = 0;
	var HR_Value_y = 0;
	var HR_Value_font = Gfx.FONT_XTINY;

	var	X_bar_x_left = 0;
	var	X_bar_x_right = 0;
	var X_bar_y = 0;
	var X_bar_font = Gfx.FONT_XTINY;
	
	var	Y_bar_x = 0;
	var	Y_bar_y_top = 0;
	var Y_bar_y_bottom = 0;
	var Y_bar_font = Gfx.FONT_XTINY;
	
    function initialize()
    {
        DataField.initialize();

	    Device_Type = Ui.loadResource(Rez.Strings.Device);
		System.println("Device_Type = " + Device_Type);

		System.println("TimeValues.size() = " + TimeValues.size()); 
		System.println("TimeValuesAvgPeriod.size() = " +TimeValuesAvgPeriod.size());

		PowerValuesHistoryAvgPeriod[0] = 1; 
		PowerValuesHistory[0] = new [300];
		PowerValuesHistoryAvgPeriod[1] = 5; 
		PowerValuesHistory[1] = new [2160];

		if (Device_Type.equals("edge_520"))
		{
		}
		else
		if (Device_Type.equals("edge_820"))
		{
			HR_Value_x = 190;
			HR_Value_y = 35;
			HR_Value_font = Gfx.FONT_NUMBER_HOT;

			X_bar_x_left = 30;
			X_bar_x_right = 190;
			X_bar_y = 220;
			X_bar_font = Gfx.FONT_SMALL;
			
			Y_bar_y_top = 20;
			Y_bar_font = Gfx.FONT_SMALL;
		}
		
		Y_bar_x = X_bar_x_left;
		Y_bar_y_bottom = X_bar_y;


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
		
		for (var i = 0; i < TimeValues.size(); ++i)
		{
			TimeValuesValid[i] = false;
			PowerSumOfSamples[i] = 0;
			PowerNumberOfSamples[i] = 0;
			CurrentPowerValues[i] = 0;
			RidePowerValues[i] = 0;
			TimeValues_x[i] = X_bar_x_left + (X_bar_x_right - X_bar_x_left + 1) * Math.log(TimeValues[i], 10) / Math.log(TimeValues[TimeValues.size() - 1], 10); 
			System.println("TimeValues_x[" + i + "] = " + TimeValues_x[i]);
		}

    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc)
    {

    	System.println("DC Height  = " + dc.getHeight());
      	System.println("DC Width  = " + dc.getWidth());

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


        if( (info.currentPower != null))
        {
			//System.println("==> New - info.currentPower = " + info.currentPower);
			
			for (var i = 0; i < PowerValuesHistory.size(); ++i)
			{
				PowerValuesHistoryAvgSum[i] += info.currentPower;
				PowerValuesHistoryAvgCount[i]++;
//var z = PowerValuesHistory[i].size();
//System.println("New 00 - " + PowerValuesHistoryIndex[i] + " - " + z);
				if (((PowerValuesHistoryAvgCount[i] % PowerValuesHistoryAvgPeriod[i]) == 0))
				{
//System.println("New 0 - i = " + i + " - PowerValuesHistoryIndex[" + i + "] = " + PowerValuesHistoryIndex[i]);

//System.println("New 1");
		           	for (var j = 0; j < TimeValues.size(); ++j)
		           	{
//System.println("New 2");
		           		if ((TimeValuesAvgPeriod[j] == i))
		           		{
							//System.println("Should add entry for TimeValues[" + j + "] = " + TimeValues[j]); 
		        			// subtract the oldest sample from our moving sum+
        					var OldestIndex = (PowerValuesHistoryIndex[i] - (TimeValues[j] / PowerValuesHistoryAvgPeriod[TimeValuesAvgPeriod[j]]) + PowerValuesHistory[i].size()) % (PowerValuesHistory[i].size());
							//System.println("Before - " + TimeValues[j] + " - PowerSumOfSamples[" + j + "] = " + PowerSumOfSamples[j]);
							//System.println("OldestIndex = " + OldestIndex);
	//System.println("i = " + i + " - j = " + j + " - OldestIndex = " + OldestIndex);
	//System.println("PowerValuesHistory[" + i + "] = " + PowerValuesHistory[i]); 
	//System.println("PowerValuesHistoryIndex[" + i + "] = " + PowerValuesHistoryIndex[i] + " - PowerValuesHistoryAvgPeriod[TimeValuesAvgPeriod[" + j + "]] = "  + PowerValuesHistoryAvgPeriod[TimeValuesAvgPeriod[j]]);
	//System.println("Before - PowerSumOfSamples[" + j + "] = " + PowerSumOfSamples[j]);
							PowerSumOfSamples[j] -= PowerValuesHistory[i][OldestIndex];
							// add the newest sample to our moving sum
							PowerSumOfSamples[j] += PowerValuesHistoryAvgSum[i] / PowerValuesHistoryAvgCount[i];
	//System.println("After - PowerSumOfSamples[" + j + "] = " + PowerSumOfSamples[j]);
							//System.println("After - " + TimeValues[j] + " - PowerSumOfSamples[" + j + "] = " + PowerSumOfSamples[j]);
							PowerNumberOfSamples[j]++;
							if ((PowerNumberOfSamples[j] * PowerValuesHistoryAvgPeriod[TimeValuesAvgPeriod[j]]) >= TimeValues[j])
							{
								TimeValuesValid[j] = true;
								CurrentPowerValues[j] = PowerSumOfSamples[j] / (TimeValues[j] / PowerValuesHistoryAvgPeriod[TimeValuesAvgPeriod[j]]);
								if (CurrentPowerValues[j] > RidePowerValues[j])
								{
									RidePowerValues[j] = CurrentPowerValues[j];
								}
								
								System.println("Valid - TimeValues[" + j + "] = " + TimeValues[j] + " - CurrentPowerValues[" + j + "] = " + CurrentPowerValues[j] + " - RidePowerValues[" + j + "] = " + RidePowerValues[j]); 
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


        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);

		var PowerMax = Math.ceil((RidePowerValues[0].toFloat() / 100)) * 100;
		if (PowerMax == 0)
		{
			PowerMax = 100;
		}
		System.println("RidePowerValues[0] = " + RidePowerValues[0] + " - PowerMax = " + PowerMax);

		dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
   		dc.setPenWidth(1);
   		dc.drawLine(X_bar_x_right, X_bar_y, X_bar_x_left, X_bar_y);
   		dc.drawLine(Y_bar_x, Y_bar_y_top, Y_bar_x, Y_bar_y_bottom);

		for (var i = 0; i < ((PowerMax / 100) + 1); ++i)
		{
			var y = Y_bar_y_bottom - (Y_bar_y_bottom - Y_bar_y_top + 1) * (i * 100) / PowerMax; 
			//System.println("y = " + y);
			dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
   			dc.setPenWidth(1);
   			dc.drawLine(Y_bar_x - 10, y, X_bar_x_right, y);
			textR(dc, Y_bar_x - 5, y - 10, Y_bar_font, FontDisplayColor, (i * 100).toString());
		}


		for (var i = 0; i < TimeValues.size(); ++i)
		{
			var GridTop_y = X_bar_y;
			
			if (TimeValuesX[i] == 1)
			{
				var TimeValueToDisplay = TimeValues[i];
				for (var j = 0; j < 2; j++)
				{
					if ((TimeValueToDisplay / 60) >= 1)
					{
						TimeValueToDisplay = TimeValueToDisplay / 60;
					}
				}
				textR(dc, TimeValues_x[i], X_bar_y + 15, X_bar_font, FontDisplayColor, (TimeValueToDisplay).toString());
				GridTop_y = Y_bar_y_top;
			}
			dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
   			dc.setPenWidth(1);
   			dc.drawLine(TimeValues_x[i], GridTop_y, TimeValues_x[i], X_bar_y + 5);
		}

		for (var i = 0; i < (TimeValues.size() - 1); ++i)
		{
			if (RidePowerValues[i] > 0 and RidePowerValues[i + 1] > 0)
			{
				var y1 = Y_bar_y_bottom - (Y_bar_y_bottom - Y_bar_y_top + 1) * RidePowerValues[i] / PowerMax;
				var y2 = Y_bar_y_bottom - (Y_bar_y_bottom - Y_bar_y_top + 1) * RidePowerValues[i + 1] / PowerMax;
				//System.println("y1 = " + y1 + " - y2 = " + y2);
				dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
   				dc.setPenWidth(3);
   				dc.drawLine(TimeValues_x[i], y1, TimeValues_x[i + 1], y2);

				y1 = Y_bar_y_bottom - (Y_bar_y_bottom - Y_bar_y_top + 1) * CurrentPowerValues[i] / PowerMax;
				y2 = Y_bar_y_bottom - (Y_bar_y_bottom - Y_bar_y_top + 1) * CurrentPowerValues[i + 1] / PowerMax;
				//System.println("y1 = " + y1 + " - y2 = " + y2);
				dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
   				dc.setPenWidth(3);
   				dc.drawLine(TimeValues_x[i], y1, TimeValues_x[i + 1], y2);

			}
		}

		textR(dc, HR_Value_x, HR_Value_y, HR_Value_font, FontDisplayColor, HR_Value.toString());
    }

	function textR(dc, x, y, font, color, s)
	{
		if (s != null)
		{
			dc.setColor(color, Gfx.COLOR_TRANSPARENT);
			dc.drawText(x, y, font, s, Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
		}
	}


}
