//+------------------------------------------------------------------+
//|                                                  ATR_Percent.mq5 |
//|                   Copyright 2009-2020, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009-2020, MetaQuotes Software Corp."
#property link        "http://www.mql5.com"
#property description "Average True Range"
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_color1  DodgerBlue
#property indicator_label1  "ATR_Percent"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSilver
#property indicator_label2  "ATR_Percent_MA"
//--- input parameters
input int InpAtrPeriod=14;  // ATR period
input int InpAtrMAPeriod=20;  // ATR period
//--- indicator buffers
double    ExtATRBuffer[];
double    ExtATR_MA_Buffer[];
double    ExtTRBuffer[];

int       ExtPeriodATR, ExtPeriodATR_MA;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- check for input value
   if(InpAtrPeriod<=0)
     {
      ExtPeriodATR=14;
      PrintFormat("Incorrect input parameter InpAtrPeriod = %d. Indicator will use value %d for calculations.",InpAtrPeriod,ExtPeriodATR);
     }
   else
      ExtPeriodATR=InpAtrPeriod;
      ExtPeriodATR_MA=InpAtrMAPeriod;
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtATRBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtATR_MA_Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtTRBuffer,INDICATOR_CALCULATIONS);
//---
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpAtrPeriod);
//--- name for DataWindow and indicator subwindow label
   string short_name=StringFormat("ATR_Percent(%d)",ExtPeriodATR);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   PlotIndexSetString(0,PLOT_LABEL,short_name);
   
 //--- sets first bar from what index will be drawn
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,InpAtrPeriod + InpAtrMAPeriod);
//--- name for DataWindow and indicator subwindow label
   string short_name=StringFormat("ATR_Percent_MA(%d)",ExtPeriodATR_MA);
   PlotIndexSetString(1,PLOT_LABEL,short_name);  
  }
//+------------------------------------------------------------------+
//| Average True Range                                               |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total<=ExtPeriodATR)
      return(0);

   int i,start;
//--- preliminary calculations
   if(prev_calculated==0)
     {
      ExtTRBuffer[0]=0.0;
      ExtATR_MA_Buffer[0]=0.0;
      ExtATRBuffer[0]=0.0;
      //--- filling out the array of True Range values for each period
      for(i=1; i<rates_total && !IsStopped(); i++)
         ExtTRBuffer[i]=MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]) / close[i-1];
      //--- first AtrPeriod values of the indicator are not calculated
      double firstValue=0.0;
      for(i=1; i<=ExtPeriodATR; i++)
        {
         ExtATRBuffer[i]=0.0;
         firstValue+=ExtTRBuffer[i];
        }
      //--- calculating the first value of the indicator
      firstValue/=ExtPeriodATR;
      ExtATRBuffer[ExtPeriodATR]=firstValue;
      start=ExtPeriodATR+1;
      //--- filling out the array of True Range MA values for each period
      for(i=1; i<rates_total && !IsStopped(); i++) {
         ExtTR_MA_Buffer[i]=iMAOnArray()
     }   
   }
   else
      start=prev_calculated-1;
//--- the main loop of calculations
   for(i=start; i<rates_total && !IsStopped(); i++)
     {
      ExtTRBuffer[i]=MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]) / close[i-1];
      ExtATRBuffer[i]=ExtATRBuffer[i-1]+(ExtTRBuffer[i]-ExtTRBuffer[i-ExtPeriodATR])/ExtPeriodATR;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
