#include "box.ch"
#include "its.ch"
#include "inkey.ch"
#include "Janus.ch"
#include "aChoice.ch"
#include "setcurs.ch"

#ifdef COLOR_STAT
#define BAR "F2-Add F3-Edit F4-[Del/Undel] F5-Search F6-Items F7-Print ESC-Abort"
#else
#define BAR "F2-Add F3-Edit F4-[Del/Undel] F5-Search F6-Items F7-Print ESC-Abort"
#endif

memvar getlist,aScrollBar

static xGetVar[14],aPicture0
static aType := {}, aClass := {}, PAGELEN 

function do_PO()
local wWindow, nkey
   aPicture0 := array(7,3)
   aPicture0[1,1] := FieldBlock("POI_LINK")
   aPicture0[1,2] := "@!"
   aPicture0[1,3] := .f.
   aPicture0[2,1] := FieldBlock("POI_ITEM")
   aPicture0[2,2] := "@K "+repl("9",PLU_CODE_LEN)   
   aPicture0[2,3] := .t.
   aPicture0[3,1] := FieldBlock("POI_DESC")
   aPicture0[3,2] := "@! "+ repl("X",40)
   aPicture0[3,3] := .f.   
   aPicture0[4,1] := FieldBlock("POI_UM")
   aPicture0[4,2] := "@! "+ repl("X",10)
   aPicture0[4,3] := .f.   
   aPicture0[5,1] := FieldBlock("POI_URET")
   aPicture0[5,2] := "99,999.99"
   aPicture0[5,3] := .f.   
   aPicture0[6,1] := FieldBlock("POI_COST")
   aPicture0[6,2] := "99,999.99"
   aPicture0[6,3] := .f.   
   aPicture0[7,1] := FieldBlock("POI_QORD")
   aPicture0[7,2] := "99,999,999"
   aPicture0[7,3] := .t.   
/*   aPicture0[8,1] := FieldBlock("POI_QREC")
   aPicture0[8,2] := "99,999,999"
   aPicture0[8,3] := .f.   
   aPicture0[9,1] := FieldBlock("POI_QRET")
   aPicture0[9,2] := "99,999,999"
   aPicture0[9,3] := .f.      
*/
   Message("Opening Databases...")
   if netUse("V",DB_SHARED,NUM_SECONDS)
      set index to V_001
   endif
   if Netuse("IV",DB_SHARED,NUM_SECONDS)
      set index to IV_LINK
   endif   
   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
      set index to I_001,I_020
   endif               
   if NetUse("PO",DB_SHARED,NUM_SECONDS)
      set index to PO_001
   endif   
   
   if NetUse("PO_ITEMS",DB_SHARED,NUM_SECONDS)
      set index to POI_LINK
   endif  
   if NetUse("CL",DB_SHARED,NUM_SECONDS)
      set index to CL_001
   endif
   
      
   wWindow := OpenWindow(04,05,13,73,"Purchase Order File")   
   if PO->(reccount())==0 ; Screen_Form(APPEND_MODE) ; endif
   if lastKey()!=K_ESC
      do while (nkey!=K_ESC)
         Screen_Form(VIEW_MODE)
         nkey:=inkey(0)
         do case
            case nkey==K_DOWN
               PO->(Dbskip())
               if PO->(eof())
                  PO->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_UP
               PO->(Dbskip(-1))
               if PO->(bof())
                  PO->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               PO->(Dbskip(NUM_TO_SKIP))
               if PO->(eof())
                  PO->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               PO->(Dbskip(-NUM_TO_SKIP))
               if PO->(bof())
                  PO->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_END
               PO->(Dbgobottom())
                  Message("Moving to end of file....")
                  inkey(1)
            case nKey==K_HOME
               PO->(Dbgotop())
                  Message("Moving to beginning of file....")
                  inkey(1)
            case nKey==K_F2
                  Screen_Form(APPEND_MODE)
            case nKey==K_F3
               if (PO->PO_007 == 0)
                 Screen_Form(EDIT_MODE)
               else
                 PO_ITEMS->(aBrowse0(PO->PO_001,aPicture0,EDIT_MODE))                   
                 PO->(RecLock(0))
                 PO->PO_007 := 7
                 PO->(DbUnLock())
               endif 
            case nKey==K_F4
             if (PO->PO_007 == 0)
             if PO->(Deleted())
               Message("Press ENTER to Undelete record, ESC to abort.")
               if inkey(0)==K_ENTER
                  Message("Undeleting current record....")
                  PO_ITEMS->(DbSeek(PO->PO_001))
                  PO_ITEMS->(FilLock(0)) 
                  while PO_ITEMS->(!Eof()) .and. PO_ITEMS->POI_LINK == PO->PO_001                 
                     PO_ITEMS->(DbRecall())                  
                     PO_ITEMS->(DbSkip())
                  enddo                 
                  PO_ITEMS->(DbUnlock())
                  PO->(RecLock(0))
                  PO->(DbRecall())
                  PO->PO_018 := 4
                  PO->(Dbunlock())
               endif
             else
                Message("Press ENTER to delete record, ESC to abort.")
               if inkey(0)==K_ENTER
                  Message("Deleting current record....")
                  PO_ITEMS->(DbSeek(PO->PO_001))
                  PO_ITEMS->(FilLock(0)) 
                  while PO_ITEMS->(!Eof()) .and. PO_ITEMS->POI_LINK == PO->PO_001                 
                     PO_ITEMS->(DbDelete())                  
                     PO_ITEMS->(DbSkip())
                  enddo                   
                  PO_ITEMS->(DbUnlock())                  
                  PO->(RecLock(0))
                  PO->(Dbdelete())
                  PO->PO_018 := 3
                  PO->(Dbunlock())
               endif
             endif
             endif
            case nKey==K_F5
               PO->(Search_Form("I.P. No.",8))
            case nKey==K_F6
               PO->(RECLOCK(0))
               PO->PO_018 := 2
               PO->(DBUNLOCK())
               PO_ITEMS->(aBrowse0(PO->PO_001,aPicture0,EDIT_MODE))
            case nKey==K_F7   
               PrintPO()
         endcase
      enddo
   endif
   Message("Closing Databases....")   
   DbCloseAll()
   CloseWindow(wWindow)
/*   if NetUse("PO_ITEMS",DB_EXCLUSIVE,NUM_SECONDS)
      PO_ITEMS->(RecLock(0))
      PO_ITEMS->(__DbPack())
      PO_ITEMS->(DbUnlock())
      index on PO_ITEMS->POI_LINK to POI_LINK
      PO_ITEMS->(DbCloseArea())
   endif  */
return nil

static function Screen_Form(nMode)
local clr, crs 
local Variable,aTerms := ARRAY_TERMS 

   tone(300,1)
   Screen_Init(nMode)
   MsgBar(BAR)
   clr := setcolor(TITLE_ATTR)
   if nMode==APPEND_MODE
       @ 04,62 say "< New >   "
       @ 04,35 say "         "
   else
      if PO->(Deleted()) 
        @ 04,35 say "<deleted>"
      elseif PO->PO_007 != 0  
        @ 04,35 say " <posted>" 
      else  
        @ 04,35 say "         "
      endif
      @ 04, 62 say "Rec #"+transform(PO->(recno()),"9999")
   endif
   setcolor( clr )

//jzo05-17-98   @ 06,      06 say "   Purchase Order No." get xGetVar[1] pict "@K 99999999" WHEN refno(nMode) VALID VldtPo(nMode)
   @ 06,      06 say "    Import Permit No." get xGetVar[1] pict "@K 99999999" WHEN refno(nMode) VALID VldtPo(nMode)
   @ row()+1, 06 say "        Supplier Code" get xGetVar[2] pict "@K 999" WHEN VldtVenLnk() VALID PostVldtVen(xGetVar[2])
   GetTerms(@Variable)
   @ row()+1, 06 say "Supplier Credit Terms" get Variable pict "@K" WHEN GetTerms(@Variable)
   @ row()+1, 06 say "              IP Date" get xGetVar[3] pict "@K D" VALID !EMPTY (xGetVar[3])
   @ row()+1, 06 say "    Cancellation Date" get xGetVar[4] pict "@K D" // VALID !EMPTY (xGetVar[4])
   @ row()+1, 06 say "        Delivery Date" get xGetVar[14] pict "@K D" // VALID !EMPTY (xGetVar[6])
   @ row()+1, 06 say "           Deliver To" get xGetVar[6] pict "@S15! "  VALID !EMPTY (xGetVar[6])

   @ 06,      45 say "        Type" get xGetVar[7] PICT "@K! XXXXXXXXX" when prevldtType() valid vldttype()
   @ row()+1, 45 say "       Label" get xGetVar[8] pict "@!K " + repl("X",15) 
   @ row()+1, 45 say "         Tag" get xGetVar[9] pict "@!K " + repl("X",15) 
   @ row()+1, 45 say "  Class Code" get xGetVar[10] pict "@K 9999" WHEN  VldtClsLnk() VALID PostVldtCl()
   @ row()+1, 45 say "Terms [Days]" get xGetVar[11] pict "@K 999"  // VALID !EMPTY (xGetVar[11])
   @ row()+1, 45 say "     Percent" get xGetVar[12] pict "@K 99.99"  when .f. // VALID !EMPTY (xGetVar[12])
   @ row()+1, 45 say "    Discount" get xGetVar[13] pict "@K 99.99" // VALID !EMPTY (xGetVar[13])

   
   if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      crs := setcursor(SC_NORMAL)
      read
      if lastkey()!=K_ESC
         Screen_Save(nMode)
         PO_ITEMS->(aBrowse0(PO->PO_001,aPicture0,nMode))
      endif
      setcursor( crs )
   else
      clear gets
   endif
return nil

static function GetTerms(New)
local aTerms := ARRAY_TERMS
if xGetvar[5] != 0
 New := padl(ltrim(tran(xGetVar[5], "99")),2,"0")+" "+aTerms[xGetVar[5]]     
else
 new  := "0 Concess're"
endif 
return .f.


static function VldtClsLnk()
local  lVal:= .t.,n:=0
 if empty(aClass)
   CL->(DbGotop())
   while CL->(!eof())
      if CL->(!Deleted())
       aAdd(aClass," "+CL->CL_001+" "+CL->CL_002+" ")
      endif
      CL->(DbSkip())
   enddo
 endif
 if (( n:= LookUp(9,55,aClass,"Class Link",xGetVar[10])) != 0)
       xGetVar[10] := subs(aClass[n],2,4)
       lVal :=  .f.
 endif
 MsgBar(BAR) 
return lVal

static function PostVldtCl()
local lVal := .t.
 if empty(xGetVar[10])
    return .f.
 endif
 xGetVar[10] :=  padl( alltrim(xGetVar[10]),4,"0")
 CL->(DbGotop())
 if !CL->(DbSeek(xGetVar[10]))
   lVal := .f.
   Message(" Class Link Number "+xGetVar[10]+" does not exist.... ")
   Tone(500,3)
   Inkey(1)
   Tone(200,2)
 endif  
 
  while Inkey() != 0 ; enddo
  MsgBar(BAR)
return lVal


static function PreVldtType()
local  lVal:= .t.,n:=0
 if empty(aType)
     aAdd(aType," "+"NEW ORDER"+" ")
     aAdd(aType," "+"RE-ORDER "+" ")
 endif

 if (( n:= LookUp(07,60,aType,"Type",xGetVar[7])) != 0)
       xGetVar[7] := substr(aType[n],2)
       lVal :=  .f.
 endif
 MsgBar(BAR) 
return lVal

static function vldttype()
xGetVar[7] := padr(xGetVar[7],9)
return .t.


static function refno(nMode)
local nrecno := PO->(Recno())


   if nMode == APPEND_MODE
      if PO->(LastRec()) == 0
         xGetvar[1] := STR(1)
      endif
      PO->(DbGoBottom())
      xGetvar[1] := STR(VAL(PO->PO_001) + 1)
      PO->(DbGoto(nRecNo))
   endif
   xGetVar[1] :=  padl( alltrim(xGetVar[1]),8,"0")
return .T.


static function VldtPo(Mode)
local lRetVal:= .t.,nRecNo:= PO->(RecNo())

 if empty(xGetVar[1])
    return .f.
 endif


 xGetVar[1] :=  padl( alltrim(xGetVar[1]),8,"0")
 if (Mode == APPEND_MODE) .or. (Mode == EDIT_MODE .and. xGetVar[1] != PO->PO_001)
   PO->(DbSeek(xGetVar[1]))
   if (PO->(found()))
    lRetVal := .f.
    Message(" I.P. Number : "+xGetVar[1]+" already exist...")      
      Tone(300,3)
      Tone(500,3)
      Inkey(3)
      Tone(200,2)
   endif
   PO->(DbGoto(nRecNo))
   MsgBar(BAR)
 endif
return lRetVal

static function VldtVenLnk()
local bMyBlock,lVal := .t.
local nRecNo := V->(RecNo())
 Message(" Please Wait...") 
 bMyblock := {|| " "+V->V_001+" "+V->V_002+" "}
 if (V->(DbfLookUp(8,35,bMyBlock,"Supplier Reference Link",xGetVar[2])) != 0)
     xGetVar[2] := V->V_001
     xGetVar[5] := V->V_009
     xGetVar[12] := V->V_012
     lVal := .f.
 endif
 V->(DbGoto(nRecNo))
return lVal


static function Screen_Init(nMode)
 if nMode==APPEND_MODE
   xGetVar[ 1] := SPACE(8)
   xGetVar[ 2] := SPACE(3)
   xGetVar[ 3] := DATE()
   xGetVar[ 4] := CTOD("")
   xGetVar[ 5] := 1        
   xGetVar[ 6] := SPACE(20)
   xGetVar[ 7] := SPACE(9)
   xGetVar[ 8] := space(15)
   xGetVar[ 9] := space(15)
   xGetVar[10] := space(4)        
   xGetVar[11] := 0
   xGetVar[12] := 0
   xGetVar[13] := 0        
   xGetVar[14] := date()
   
   
 else
   xGetVar[1]  := PO->PO_001
   xGetVar[2]  := PO->PO_002
   xGetVar[3]  := PO->PO_003
   xGetVar[4]  := PO->PO_004
   xGetVar[5]  := PO->PO_005
   xGetVar[ 6] := PO->PO_012
   xGetVar[ 7] := PO->PO_013
   xGetVar[ 8] := PO->PO_015
   xGetVar[ 9] := PO->PO_016
   xGetVar[10] := PO->PO_014
   xGetVar[11] := PO->PO_009
   xGetVar[12] := PO->PO_010
   xGetVar[13] := PO->PO_011
   xGetVar[14] := PO->PO_017
 endif
return nil

static function Screen_Save(nMode)
   Message("Saving entries...")
   if nMode==APPEND_MODE
      PO->(FilLock(0))
      PO->(Dbappend())
      PO->PO_001 := xGetVar[ 1]
      PO->PO_002 := xGetVar[ 2]
      PO->PO_003 := xGetVar[ 3]
      PO->PO_004 := xGetVar[ 4]
      PO->PO_005 := xGetVar[ 5]
      PO->PO_012 := xGetVar[ 6] 
      PO->PO_013 := xGetVar[ 7] 
      PO->PO_015 := xGetVar[ 8] 
      PO->PO_016 := xGetVar[ 9] 
      PO->PO_014 := xGetVar[10]
      PO->PO_009 := xGetVar[11] 
      PO->PO_010 := xGetVar[12] 
      PO->PO_011 := xGetVar[13] 
      PO->PO_017 := xGetVar[14] 
      PO->PO_018 := 1
      PO->(DbUnlock())
      PO->(DbCommit())
   else
      PO->(RecLock(0))
      PO->PO_001 := xGetVar[ 1]
      PO->PO_002 := xGetVar[ 2]
      PO->PO_003 := xGetVar[ 3]
      PO->PO_004 := xGetVar[ 4]
      PO->PO_005 := xGetVar[ 5]
      PO->PO_012 := xGetVar[ 6] 
      PO->PO_013 := xGetVar[ 7] 
      PO->PO_015 := xGetVar[ 8] 
      PO->PO_016 := xGetVar[ 9] 
      PO->PO_014 := xGetVar[10]
      PO->PO_009 := xGetVar[11] 
      PO->PO_010 := xGetVar[12] 
      PO->PO_011 := xGetVar[13] 
      PO->PO_017 := xGetVar[14] 
      PO->PO_018 := 2
      PO->(DbUnlock())
      PO->(DbCommit())
   endif   
return nil


static function PrintPO()
local nrecno := PO->(Recno())
local ctr := 0, nLineCtr := 0
local ncost := 0, nRet := 0, xflag := " "
local nTcost := 0, nTRet := 0, nof := 0

PAGELEN := 0

PO->(DbGoto(nrecno))

if alert("Insert I.P. Slip",{"Continue","End"},"w+/b") == 1
else
   PO->(DbGoto(nRecno))
   return nil
endif

Set(_SET_CONSOLE,.F.)
Set(_SET_PRINTER,.T.)
Message("Printing Pls. Wait...")

PO_ITEMS->(DbGoTop())
PO_ITEMS->(DBSEEK(PO->PO_001))
DO WHILE PO_ITEMS->POI_LINK == PO->PO_001
   CTR += 1 
   PO_ITEMS->(DbSkip())
ENDDO

NOF := CTR / 12
if mod(ctr,12) <> 0
   nof := int(nof) + 1
else
   nof := int(nof) 
endif   

CTR := 0

heading(nof)

PO_ITEMS->(DbGoTop())
PO_ITEMS->(DBSEEK(PO->PO_001))
DO WHILE PO_ITEMS->POI_LINK == PO->PO_001
   if ITEM->(DbSeek(PO_ITEMS->POI_ITEM))
      if ITEM->I_004 == 1
         xflag := "X"
      elseif ITEM->I_004 == 2
         xFlag := "S"
      else
         xFlag := " "   
      endif            
   endif
   ? SPACE(1) + PO_ITEMS->POI_ITEM
   ?? SPACE(8) + PO_ITEMS->POI_DESC
   ?? SPACE(22) + TRANS(PO_ITEMS->POI_QORD,"999,999")
   ?? SPACE(2) + PADR(PO_ITEMS->POI_UM,10)
   ?? SPACE(1) + TRANS(PO_ITEMS->POI_COST,"9,999,999.99")
   ?? SPACE(5) + TRANS(PO_ITEMS->POI_URET,"9,999,999.99") + xflag
   NLINECTR += 1
   NCOST += PO_ITEMS->POI_COST * PO_ITEMS->POI_QORD
   NRET += PO_ITEMS->POI_URET * PO_ITEMS->POI_QORD
   Do Case
      Case PO->PO_010 == 0 .and. PO->PO_011 == 0
           nTCost := nCost
      Case PO->PO_010 == 0 .and. PO->PO_011 <> 0   
           nTCost :=  nCost - (nCost * (PO->PO_011/100))
      Case PO->PO_010 <> 0 
           nTCost := nret - ((nRet * (PO->PO_010/100)) +;
                 (nRet * (PO->PO_011/100)))
   Endcase

   IF NLINECTR == 12 .AND. !EOF()
      ? SPACE(95) + "TOTAL "
      ?? SPACE(4) + TRANS(NCOST,"9,999,999.99")
      ?? SPACE(5) + TRANS(NRET,"9,999,999.99")    
      NCOST := 0
      NRET := 0
      nlinectr := 0
      
      ?;?;?;?;?;?;?;?;?;?
      heading(nof)  
   ENDIF   
   PO_ITEMS->(DbSkip())
ENDDO
? SPACE(95) + "TOTAL "
?? SPACE(4) + TRANS(NCOST,"9,999,999.99")
?? SPACE(5) + TRANS(NRET,"9,999,999.99")    
? SPACE(80) + "TOTAL AMOUNT PAYABLE "
?? SPACE(4) + TRANS(NTCOST,"9,999,999.99")
// ?? SPACE(3) + TRANS(NTRET,"9,999,999.99")    

? // CHR(18)

Set(_SET_PRINTER,.F.)
Set(_SET_CONSOLE,.T.)

MsgBar(BAR)

return nil



static function heading(nof)
local aTerms := ARRAY_TERMS, vname := 0, atypes := VENDOR_TYPES
local vtype := 0

PAGELEN += 1

? // CHR(15)
?? space(115) + PO->PO_001
? // SPACE(115) + ALLTRIM(STR(PAGELEN)) + " OF " + alltrim(str(nof))
?
? 
?
IF V->(DBSEEK(PO->PO_002))
   VNAME := V->V_002
   VTYPE := V->V_010
ELSE
   VNAME := "SUPPLIER CODE NOT FOUND"
ENDIF

? SPACE(13) + VNAME
?? SPACE(20) + PO->PO_012
?? SPACE(23) + DTOC(PO->PO_003)

? SPACE(21) + PO->PO_002
?? SPACE(39) + DTOC(PO->PO_017)
?? SPACE(47) + PO->PO_014

? SPACE(11) + PADR(aTerms[PO->PO_005],8)     
?? SPACE(2) + PADR(PO->PO_010,7)
if vtype == 3
   ?? SPACE(2) + PADR(ATYPES[3],11)
   ?? SPACE(22) + DTOC(PO->PO_004)
else
   ?? SPACE(35) + DTOC(PO->PO_004)
endif
?? SPACE(35) + PO->PO_015

? SPACE(14) + TRANS(PO->PO_011,"99.99") + "%"
IF PO->PO_013 == ALLTRIM("NEW ORDER")
   ?? SPACE(40) + "X"
   ?? SPACE(44) + PO->PO_016
ELSE
   ?? SPACE(60) + "X"
   ?? SPACE(32) + PO->PO_016
ENDIF   

?

return nil



//end-of-file
