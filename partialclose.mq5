#include <Trade\Trade.mqh>
CTrade trade;

input string CloseSymbol = "EURUSD";  // symbol to close
input double CloseLots  = 0.5;        // lots to close
input bool  EnableEA    = true;       // enable automatic partial close

bool already_closed = false;           // ensures only one partial close

//+------------------------------------------------------------------+
int OnInit()
{
   Print("Partial Close EA initialized for ", CloseSymbol);
   already_closed = false;
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnTick()
{
   if(!EnableEA || already_closed) return;

   if(PartialCloseOne(CloseSymbol, CloseLots))
       already_closed = true;  // prevent further closing
}

//+------------------------------------------------------------------+
bool PartialCloseOne(string symbol, double lots_to_close)
{
   int total = PositionsTotal();
   if(total == 0) return false;

   // Loop through all positions
   for(int i=0; i<total; i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;

      if(!PositionSelectByTicket(ticket)) continue;

      string pos_symbol = PositionGetString(POSITION_SYMBOL);
      double volume     = PositionGetDouble(POSITION_VOLUME);

      if(pos_symbol != symbol) continue;

      if(lots_to_close <= 0 || lots_to_close > volume)
      {
         Print("Invalid lots to close. Position has ", volume, " lots.");
         return false;
      }

      // Partial close using built-in function
      if(trade.PositionClosePartial(ticket, lots_to_close))
      {
         Print("Partial close successful: ", lots_to_close, " lots of ", symbol);
         return true;  // Only one position closed
      }
      else
      {
         Print("Partial close failed. Error: ", GetLastError());
         return false;
      }
   }

   Print("No open position found for ", symbol);
   return false;
}
