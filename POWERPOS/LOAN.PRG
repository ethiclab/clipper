#include "terminal.ch"
#include "config.ch"
#include "pfl_clip.ch"
#include "message.ch"

#ifdef DEF_GRAPHICS
  #include "grfx_all.ch"
#endif

function loan(cDataBuff)
local nAmount := 0

   cDataBuff := put_decimal(cDataBuff)
   nAmount := val(cDataBuff)   

   if nAmount <= 0
      ErrorDisp("ZERO LOAN AMOUNT....")
   else
      
    #ifdef DEF_GRAPHICS
       Disp_BoldChar(nAmount, "Amount Loan")
       MsgAreaDisp("Amount Loan :" + transform(nAmount, "9999,999.99"))
     #endif 
     open_drawr()
     
     disp_clr()
     DISPTEXTXY(2,1,0,0,1,1,"LOAN                ")
     DISPTEXTXY(3,1,0,0,2,1,tran(nAmount,"         9999,999.99"))

     if config(POS_CASH_DRAWER) != "NO" 
        MsgAreaDisp(MSG_D014) // Close Drawer msg
        while chk_drawr() != DRAWER_CLOSED
          inkey()              
        enddo         
     endif     
     
     print_loan(nAmount)   

     #ifdef DEF_GRAPHICS
       getRcptRow(0)
       getRcptCol(0)
       Rcpt_Scroll(0)
       Disp_BoldChar(0, "Total Amount")
       Disp_Data(chr(95))
     #endif


     Term_nData( TR_LOAN_TOT, nAmount )
     Term_nData( TR_LOAN_KNT, 1 )
     Term_nData( TR_CASH_TOT, nAmount )
     
  endif   
         
return nil

function print_loan(nVar)
local out_text 
   out_text := pad("*LOAN",21) + tran(nVar ,"9999,999.99")
   A_RJS_PRNT(1, 1, 0, out_text, 0)
   prnt_end()
return nil   

