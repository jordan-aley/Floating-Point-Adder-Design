----------------------------------COMPARE EXP--------------------------
LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


Entity CompareExp is
   Port(clk: in std_logic;
        reset: in std_logic;
	EnR: in std_logic;
	EnL: in std_logic;
        OP_A: in std_logic_vector(31 downto 0);
	OP_B: in std_logic_vector(31 downto 0);
	LExp: out std_logic_vector(7 downto 0);
	SExp: out std_logic_vector(7 downto 0);
	LMan: out std_logic_vector(22 downto 0);
	Sman: out std_logic_vector(22 downto 0);
	LSign: out std_logic;
	SSign: out std_logic;
	RunO: out std_logic
);
End CompareExp;

Architecture RTL of CompareExp IS
Begin
   PROCESS(Clk,reset)
   variable expA,expB:std_logic_vector(8 downto 0);
   BEGIN
      if(clk ='1' and clk'event) THEN
         IF(reset = '1') THEN
            RunO<='0';
            LExp <= (OTHERS => '0');
            SExp <= (OTHERS => '0');
            LMan <= (OTHERS => '0');
            SMan <= (OTHERS => '0');
            LSign <= '0';
            SSign <= '0';
         ELSE
            RunO <= EnR AND EnL;
            if (EnR='1' AND EnL='1') then
               expA:='0' & OP_A(30 downto 23);
               expB:='0' & OP_B(30 downto 23);
               if(expA>expB) then
                  SSign <= OP_B(31);
                  SExp <= OP_B(30 downto 23);
                  SMan <= OP_B(22 downto 0);
                  LSign <= OP_A(31);
		  LExp <= OP_A(30 downto 23);
                  LMan <= OP_A(22 downto 0);
               else
		  SSign <= OP_A(31);
                  SExp <= OP_A(30 downto 23);
                  SMan <= OP_A(22 downto 0);
                  LSign <= OP_B(31);
		  LExp <= OP_B(30 downto 23);
                  LMan <= OP_B(22 downto 0);
	       end if;
	    end if;
         END IF;
      end if;
end PROCESS;
end RTL;

----------------------------------COMPUTE SHIFT--------------------------

LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."-";
use IEEE.std_logic_unsigned.">";
use IEEE.std_logic_unsigned.SHR;
use IEEE.std_logic_unsigned.CONV_INTEGER;
use IEEE.std_logic_misc.OR_REDUCE;
use IEEE.std_logic_arith.all;

Entity ComputeShift IS
   port(
	clk :in std_logic;
	reset :in std_logic;
	Run :in std_logic;
	LExp :in std_logic_vector(7 downto 0);
	SExp: in std_logic_vector(7 downto 0);
	LMan :in std_logic_vector(22 downto 0);
	SMan :in std_logic_vector(22 downto 0);
	LSign :in std_logic;
	SSign :in std_logic;
	LExpP :out std_logic_vector(7 downto 0);
	SExpP :out std_logic_vector(7 downto 0);
	LManP :out std_logic_vector(22 downto 0);
	SManP :out std_logic_vector(22 downto 0);
	LSignP :out std_logic;
	SSignP :out std_logic;
	shiftdistance :out std_logic_vector(4 downto 0);
	RunO :out std_logic
);
END ComputeShift;

Architecture RTL of ComputeShift IS
Begin
   PROCESS(Clk,reset)
   variable sdistance:std_logic_vector(7 downto 0);
   BEGIN
      if(clk ='1' and clk'event) THEN
         IF(reset = '1') THEN
            RunO<='0';
            sdistance := (OTHERS => '0');
            LExpP <= (OTHERS => '0');
            SExpP <= (OTHERS => '0');
            LManP <= (OTHERS => '0');
            SManP <= (OTHERS => '0');
            LSignP <= '0';
            SSignP <= '0';
            shiftdistance <= sdistance(4 downto 0);
         ELSE
            RunO <= Run;
               sdistance := LExp - SExp;
               LExpP <= LExp;
               SExpP <= SExp;
               LManP <= LMan;
               SManP <= SMan;
               LSignP <= LSign;
               SSignP <= SSign;
               shiftdistance <= sdistance(4 downto 0);
         END IF;
      end if;
end PROCESS;
end RTL;

----------------------------------SHIFT MANTISSA--------------------------

library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.">";
use ieee.std_logic_unsigned.SHR;
use ieee.std_logic_unsigned.CONV_INTEGER;
use ieee.std_logic_misc.OR_REDUCE;
use ieee.std_logic_arith.all;

entity ShiftMan is
port(
clk: in std_logic;
reset: in std_logic;
Run: in std_logic;
shiftdistance: in std_logic_vector(4 downto 0);
LExp: in std_logic_vector(7 downto 0);
SExp: in std_logic_vector(7 downto 0);
LMan: in std_logic_vector(22 downto 0);
SMan: in std_logic_vector(22 downto 0);
LSign: in std_logic;
SSign: in std_logic;
LExpP: out std_logic_vector(7 downto 0);
LManP: out std_logic_vector(24 downto 0);
SManP: out std_logic_vector(24 downto 0);
LSignP: out std_logic;
SSignP: out std_logic;
RunO: out std_logic
);

end ShiftMan;

architecture RTL of ShiftMan is 

signal t_RunO, t_LSignP, t_SSignP: std_logic;
signal t_LManP, t_SManP: std_logic_vector(24 downto 0);
signal t_LExpP: std_logic_vector(7 downto 0);

BEGIN 
process (CLK, reset)
variable ManA, ManB: std_logic_vector(24 downto 0);
variable bitA,bitB: std_logic;


BEGIN
IF (clk = '1' and clk'event) THEN
    IF (reset = '1') THEN
    t_LExpP <= (others => '0');
    t_LManP <= (others => '0');
    t_SManP <= (others => '0');
    t_LSignP <= '0';
    t_SSignP <= '0';
    t_RunO <= '0';


    ELSE

       t_RunO <= Run;

       bitA:=LSign OR OR_REDUCE(LMan) OR OR_REDUCE(LExp);
       manA:=bitA & LMan(22 downto 0) & '0';
       bitB:=SSign OR OR_REDUCE(SMan) OR OR_REDUCE(SExp);
       manB:=bitB & SMan(22 downto 0) & '0';
       t_SManP<=SHR(manB, shiftdistance);
       t_LExpP <= LExp;
       t_LManP <= manA;
       t_LSignP <= LSign;
       t_SSignP <= SSign;

    END IF;
ELSE
t_LExpP <= t_LExpP;
t_LManP <= t_LManP;
t_SManP <= t_SManP;
t_LSignP <= t_LSignP;
t_SSignP <= t_SSignP;
t_RunO <= t_RunO;
END IF;

END PROCESS;

LExpP <= t_LExpP;
LManP <= t_LManP;
SManP <= t_SManP;
LSignP <= t_LSignP;
SSignP <= t_SSignP;
RunO <= t_RunO;

end RTL;

----------------------------------COMPARE MANTISSA--------------------------

library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.">";
use ieee.std_logic_unsigned.SHR;
use ieee.std_logic_unsigned.CONV_INTEGER;
use ieee.std_logic_misc.OR_REDUCE;
use ieee.std_logic_arith.all;


entity CompareMan is
port(
clk: in std_logic;
reset: in std_logic;
Run: in std_logic;
LSign: in std_logic;
LExp: in std_logic_vector(7 downto 0);
LMan: in std_logic_vector(24 downto 0);
SSign: in std_logic;
SMan: in std_logic_vector(24 downto 0);
Exp: out std_logic_vector(7 downto 0);
LMan1: out std_logic_vector(24 downto 0);
SMan1: out std_logic_vector(24 downto 0);
Sign: out std_logic;
AddSub: out std_logic;
RunO: out std_logic
);
end CompareMan;

architecture COMPARE of CompareMan is 

signal t_Exp: std_logic_vector(7 downto 0);
signal t_LMan1, t_SMan1: std_logic_vector(24 downto 0);
signal t_Sign, t_AddSub, t_RunO: std_logic;

BEGIN

process(clk,reset)

BEGIN

IF (clk = '1' and clk'event) THEN
   IF (reset = '1') THEN
   t_Exp <= (others => '0');
   t_LMan1 <= (others => '0');
   t_SMan1 <= (others => '0');
   t_Sign <= '0';
   t_AddSub <= '0';
   t_RunO <= '0';
   ELSE

   t_RunO <= Run;
   t_Exp <= LExp;
          IF (LSign = SSign) THEN
          t_Sign <= LSign;
          t_LMan1 <= LMan;
          t_SMan1 <= SMan;
          t_AddSub <= '0';
          ELSE
              IF (LMan > SMan) THEN
              t_Sign <= LSign;
              t_LMan1 <= LMan;
              t_SMan1 <= SMan;
              t_AddSub <= '1';
              ELSE
              t_Sign <= SSign;
              t_LMan1 <= SMan;
              t_SMan1 <= LMan;
              t_AddSub <= '1';
           END IF; --end if LSign = SSign
      END IF; -- enable
   END IF; --reset
ELSE
t_Exp <= t_Exp;
t_LMan1 <= t_LMan1;
t_SMan1 <= t_SMan1;
t_Sign <= t_Sign;
t_AddSub <= t_AddSub;
t_RunO <= t_RunO;

END IF; --clk
END PROCESS;

Exp <= t_Exp;
LMan1 <= t_LMan1;
SMan1 <= t_SMan1;
Sign <= t_Sign;
AddSub <= t_AddSub;
RunO <= t_RunO;

end COMPARE;

----------------------------------SIMPLE ADD/SUB--------------------------
 
LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_unsigned."-";
use IEEE.std_logic_unsigned.">";
use IEEE.std_logic_unsigned.SHL;
use IEEE.std_logic_arith.CONV_STD_LOGIC_VECTOR;

ENTITY AddSubMan IS
   Port(clk :in std_logic;
	reset :in std_logic;
	Run :in std_logic;
	Sign :in std_logic;
	AddSub :in std_logic;
	Exp :in std_logic_vector(7 downto 0);
	LMan :in std_logic_vector(24 downto 0);
	SMan :in std_logic_vector(24 downto 0);
	UExp :out std_logic_vector( 8 downto 0);
	UMan :out std_logic_vector(25 downto 0);
	RunO :out std_logic);
END AddSubMan;

Architecture RTL of AddSubMan is
begin
process(clk,reset)
   variable NewMan: std_logic_vector(25 downto 0);
   variable manA,manB: std_logic_vector(25 downto 0);
begin

 if(clk ='1' and clk'event) THEN
         IF(reset = '1') THEN
            RunO<='0';
	    manA:=(OTHERS => '0');
	    manB:=(OTHERS => '0');
	    UMan <=(OTHERS => '0');
	    UExp <=(OTHERS => '0');
         ELSE
            RunO <= Run;
		manA:='0' & LMan;
		ManB:='0' & SMan;
		if(AddSub = '0') then --add
		   NewMan:=manA + manB;
		else
		   NewMan:=manA - ManB;
		end if;
		UExp(7 downto 0) <= Exp;
		UMan <= NewMan;
		UExp(8) <=Sign;
         END IF;
      end if;
end process;
end RTL; 


----------------------------------PIPE ADD/SUB--------------------------
 
LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_unsigned."-";
use IEEE.std_logic_unsigned.">";
use IEEE.std_logic_unsigned.SHL;
use IEEE.std_logic_arith.CONV_STD_LOGIC_VECTOR;
use IEEE.numeric_std.all;

ENTITY AddSubPipeMan IS
   Port(clk :in std_logic;
	reset :in std_logic;
	Run :in std_logic;
	Sign :in std_logic;
	AddSub :in std_logic;
	Exp :in std_logic_vector(7 downto 0);
	LMan :in std_logic_vector(24 downto 0);
	SMan :in std_logic_vector(24 downto 0);
	UExp :out std_logic_vector( 8 downto 0);
	manOutA: out std_logic_vector(25 downto 0);
	manOutB: out std_logic_vector(25 downto 0);
	RunO :out std_logic);
END AddSubPipeMan;

Architecture RTL of AddSubPipeMan is

begin
process(clk,reset)
   variable NewMan: std_logic_vector(25 downto 0);
   variable manA,manB: std_logic_vector(25 downto 0);
   variable notB: std_logic_vector(25 downto 0);
   begin

 if(clk ='1' and clk'event) THEN
         IF(reset = '1') THEN
            RunO<='0';
	    manA:=(OTHERS => '0');
	    manB:=(OTHERS => '0');
	    UExp <=(OTHERS => '0');
	    manOutA<=(OTHERS => '0');
	    manOutB<=(OTHERS => '0');
         ELSE
            RunO <= Run;
		manA:='0' & LMan;
		ManB:='0' & SMan;
		if(AddSub = '0') then --add
		  manOutA <= manA;
		  manOutB <= manB;
		else
		  manOutA <= manA;
		  notB:= not manB;
		  manOutB <= std_logic_vector(unsigned(notB + 1 ));
		end if;
		UExp(7 downto 0) <= Exp;
		UExp(8) <=Sign;
         END IF;
      end if;
end process;
end RTL; 


----------------------------------Norm1--------------------------

LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_unsigned."-";
use IEEE.std_logic_unsigned.">";
use IEEE.std_logic_unsigned.SHL;
use IEEE.std_logic_arith.CONV_STD_LOGIC_VECTOR;

Entity Norm1 is
   Port(clk :in std_logic;
	reset :in std_logic;
	Run :in std_logic;
	UMan :in std_logic_vector(25 downto 0);
	UExp :in std_logic_vector(8 downto 0 );
	ExpCor :out std_logic_vector(7 downto 0);
	ShfDst :out std_logic_vector(4 downto 0);
	OMan :out std_logic_vector(25 downto 0);
	OExp :out std_logic_vector(8 downto 0);
	RunO :out std_logic);
end Norm1;

Architecture RTL of Norm1 is 


begin
process(clk,reset)
   variable ExpCorrect: std_logic_vector(7 downto 0);
   variable ShiftDistance: std_logic_vector(4 downto 0);
begin

if(clk ='1' and clk'event) THEN
         IF(reset = '1') THEN
            RunO<='0';
	    ExpCorrect :=(OTHERS => '0');
	    ShiftDistance :=(OTHERS => '0');
	    ExpCor <=(OTHERS => '0');
	    ShfDst <=(OTHERS => '0');
	    OExp <=(OTHERS => '0');
	    OMan <=(OTHERS => '0');
         ELSE
            RunO <= Run;
		OMan <= UMan;
		OExp <=UExp;

		if(UMan(25)='1') then --ovverflow from hidden bit
		   ExpCorrect := "00000001";
		   ShiftDistance:="00000";

		elsif(UMan(24)='1') then --no need to adjust
		   ExpCorrect := "00000000";
		   ShiftDistance:="00001";

		elsif(UMan(23)='1') then --adjust down
		   ExpCorrect := "11111111";
		   ShiftDistance:="00010";

		elsif(UMan(22)='1') then --nadjust down
		   ExpCorrect := "11111110";
		   ShiftDistance:="00011";

		elsif(UMan(21)='1') then --adjust down
		   ExpCorrect := "11111101";
		   ShiftDistance:="00100";

		elsif(UMan(20)='1') then --adjust down
		   ExpCorrect := "11111100";
		   ShiftDistance:="00101";

		elsif(UMan(19)='1') then --adjust down
		   ExpCorrect := "11111011";
		   ShiftDistance:="00110";

		elsif(UMan(18)='1') then --nadjust down
		   ExpCorrect := "11111010";
		   ShiftDistance:="00111";

		elsif(UMan(17)='1') then --adjust down
		   ExpCorrect := "11111001";
		   ShiftDistance:="01000";

		elsif(UMan(16)='1') then --adjust down
		   ExpCorrect := "11111000";
		   ShiftDistance:="01001";

		elsif(UMan(15)='1') then --adjust down
		   ExpCorrect := "11110111";
		   ShiftDistance:="01010";

		elsif(UMan(14)='1') then --nadjust down
		   ExpCorrect := "11110110";
		   ShiftDistance:="01011";

		elsif(UMan(13)='1') then --adjust down
		   ExpCorrect := "11110101";
		   ShiftDistance:="01100";


		elsif(UMan(12)='1') then --adjust down
		   ExpCorrect := "11110100";
		   ShiftDistance:="01101";

		elsif(UMan(11)='1') then --adjust down
		   ExpCorrect := "11110011";
		   ShiftDistance:="01110";

		elsif(UMan(10)='1') then --adjust down
		   ExpCorrect := "11110010";
		   ShiftDistance:="01111";

		elsif(UMan(9)='1') then --nadjust down
		   ExpCorrect := "11110001";
		   ShiftDistance:="10000";

		elsif(UMan(8)='1') then --adjust down
		   ExpCorrect := "11110000";
		   ShiftDistance:="10001";

		elsif(UMan(7)='1') then --adjust down
		   ExpCorrect := "11101111";
		   ShiftDistance:="10010";

		elsif(UMan(6)='1') then --adjust down
		   ExpCorrect := "11101110";
		   ShiftDistance:="10011";

		elsif(UMan(5)='1') then --adjust down
		   ExpCorrect := "11101101";
		   ShiftDistance:="10100";

		elsif(UMan(4)='1') then --nadjust down
		   ExpCorrect := "11101100";
		   ShiftDistance:="10101";

		elsif(UMan(3)='1') then --adjust down
		   ExpCorrect := "11101011";
		   ShiftDistance:="10110";

		elsif(UMan(2)='1') then --adjust down
		   ExpCorrect := "11101010";
		   ShiftDistance:="10111";

		elsif(UMan(1)='1') then --adjust down
		   ExpCorrect := "11101001";
		   ShiftDistance:="11000";

		elsif(UMan(0)='1') then 
		   ExpCorrect := "00000000";
		   ShiftDistance:="00000";

		end if;
ExpCor <= ExpCorrect;
ShfDst <= ShiftDistance;
         end if;
end if;
end process;
end RTL;

----------------------------------Norm2--------------------------

LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_unsigned."-";
use IEEE.std_logic_unsigned.">";
use IEEE.std_logic_unsigned.SHL;
use IEEE.std_logic_arith.CONV_STD_LOGIC_VECTOR;

Entity Norm2 is
   Port(clk :in std_logic;
	reset :in std_logic;
	Run :in std_logic;
	ExpCor :in std_logic_vector(7 downto 0);
	ShfDst :in std_logic_vector(4 downto 0 );
	UExp : in std_logic_vector(8 downto 0);
	UMan :in std_logic_vector(25 downto 0);
	Q :out std_logic_vector(31 downto 0);
	RunO :out std_logic);
end Norm2;

architecture RTL of Norm2 is
begin
   process(clk,reset)
     variable exp: std_logic_vector(7 downto 0);
     variable ManOut,ManA: std_logic_vector(25 downto 0);
     variable RoundMan: std_logic_vector(25 downto 0);	  
     variable QQ: std_logic_vector(31 downto 0);     
begin
if(clk ='1' and clk'event) THEN
         IF(reset = '1') THEN
            RunO<='0';
	    QQ :=(OTHERS => '0');
         ELSE
            RunO <= Run;
		exp:=Uexp(7 downto 0);
		ManA:=UMan;
		exp:=exp + ExpCor;
		ManOut:=SHL(ManA,ShfDst);
		RoundMan:='0' & ManOut(24 downto 0);
		if((RoundMan(1) ='1') AND(RoundMan(2)='1')) then --round mantissaa
		   RoundMan:=RoundMan + "00000000000000000000010";
		end if;
		-- round up and produce carry and add one to exponent
		if(RoundMan(25)='1') then
		   exp:=exp + 1;
		end if;
		QQ(31) := UExp(8);
		QQ(30 downto 23) :=exp;
		QQ(22 downto 0) := RoundMan(24 downto 2);
Q <= QQ;
	end if;
end if;
end process;
end RTL;

---------------------------------------------------------------------------------
-------------Final Register-------------------------------------------------------
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164. all;
entity ALEY_FinalReg is
        port (
		clk: in std_logic;
		reset: in std_logic;
		en:  in std_logic;
	        RunIn: in std_logic;
		SumIn: in std_logic_vector(31 downto 0);
		SumOut: out std_logic_vector(31 downto 0);
		RunO: out std_logic
);

end ALEY_FinalReg;

architecture reg16bit_arch of ALEY_FinalReg is
signal sSumout: std_logic_vector(31 downto 0);
signal sRun: std_logic;

begin
   process(clk)
          begin
      		if (clk ='1' and clk'event)then
			if(reset='1')then
				sSumout <= (others => '0');
				sRun <= '0';
			elsif (en='1')then
				sSumout <= SumIn;
				sRun <= RunIn;
			else
				sSumout <= sSumout;
				sRun <= sRun;
			end if;
		else
			sSumout <= sSumout;
			sRun <= sRun;
		end if;
	end process;
Sumout <= sSumout;
RunO <= sRun;
end reg16bit_arch;

---------------------------------------------------------------------------------
-------------First Slice---------------------------------------------------------
---------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;

ENTITY ALEY_First_BSlice IS
PORT (	
	Op_A	:IN STD_LOGIC;
	Op_B	:IN STD_LOGIC;
	SUM_Q	:OUT STD_LOGIC;
	Carry_Q	:OUT STD_LOGIC
     );

END ALEY_First_BSlice;

ARCHITECTURE BEH_first_BS OF ALEY_First_BSlice IS

CONSTANT My_C: STD_LOGIC:='0';

BEGIN

SUM_Q <= OP_A XOR OP_B XOR My_C;
Carry_Q <= ((OP_A XOR OP_B) AND My_C) OR (OP_A AND OP_B); 
END BEH_first_BS;

---------------------------------------------------------------------------------
-------------Generic Slice-------------------------------------------------------
---------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;

ENTITY ALEY_GEN_BSlice IS
PORT (	
	Op_A	:IN STD_LOGIC;
	Op_B	:IN STD_LOGIC;
	Op_C	:IN STD_LOGIC;
	SUM_Q	:OUT STD_LOGIC;
	Carry_Q	:OUT STD_LOGIC
     );

END ALEY_GEN_BSlice;

ARCHITECTURE BEH_BS OF ALEY_GEN_BSlice IS

BEGIN

SUM_Q <= OP_A XOR OP_B XOR OP_C;
Carry_Q <= ((OP_A XOR OP_B) AND OP_C) OR (OP_A AND OP_B); 

END BEH_BS;


---------------------------------------------------------------------------------
-------------Last Register-------------------------------------------------------
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164. all;
entity ALEY_LastReg is
	generic(bbits: integer:=2; prevbbits: integer:= 2; sumsize: integer:=24);
        port (
		clk: in std_logic;
		reset: in std_logic;
		en:  in std_logic;
		UExp: in std_logic_vector(8 downto 0);
		SumIn: in std_logic_vector(bbits-1 downto 0);
		PrevSum: in std_logic_vector(prevbbits-1 downto 0);
		CarryIn: in std_logic;
		SumOut: out std_logic_vector(sumsize-1 downto 0);
		Carryout: out std_logic;
		RunO: out std_logic;
		OExp: out std_logic_vector(8 downto 0)
);

end ALEY_LastReg;

architecture reg16bit_arch of ALEY_LastReg is
signal sSumout: std_logic_vector(sumsize-1 downto 0);
signal scarryout: std_logic;
signal sUExp: std_logic_vector(8 downto 0);
signal sRun: std_logic;

begin
   process(clk)
          begin
      		if (clk ='1' and clk'event)then
			if(reset='1')then
				sSumout <= (others => '0');
				sCarryout <= '0';
				sUExp <= (others => '0');
				sRun <= '0';
			elsif (en='1')then
				sSumout <= SumIn & PrevSum;
				sCarryout <= CarryIn;
				sUExp <= UExp;
				sRun <= en;
			else
				sSumout <= sSumout;
				sCarryout <= sCarryout;
				sUExp <= sUExp;
				sRun <= sRun;
			end if;
		else
			sSumout <= sSumout;
			sCarryout <= sCarryout;
			sRun <= sRun;
		end if;
	end process;
Sumout <= sSumout;
Carryout <= sCarryout;
RunO <= sRun;
OExp <= sUExp;
end reg16bit_arch;

---------------------------------------------------------------------------------
-------------First Register-------------------------------------------------------
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164. all;
entity ALEY_FirstReg is
	generic(w: integer:= 24; bbits: integer:=2);
        port (
		clk: in std_logic;
		reset: in std_logic;
		en:  in std_logic;
		UExp: in std_logic_vector(8 downto 0);
		InA: in std_logic_vector(w-1 downto 0);
		InB: in std_logic_vector(w-1 downto 0); 
		SumIn: in std_logic_vector(bbits-1 downto 0);
		CarryIn: in std_logic;
                Aout: out std_logic_vector(w-1 downto 0);
		Bout: out std_logic_vector(w-1 downto 0);
		SumOut: out std_logic_vector(bbits-1 downto 0);
		Carryout: out std_logic;
		RunO: out std_logic;
		OExp: out std_logic_vector(8 downto 0)
);

end ALEY_FirstReg;

architecture reg16bit_arch of ALEY_FirstReg is
signal sAout: std_logic_vector(w-1 downto 0);
signal sBout: std_logic_vector(w-1 downto 0);
signal sSumout: std_logic_vector(bbits-1 downto 0);
signal scarryout: std_logic;
signal sUExp: std_logic_vector(8 downto 0);
signal sRun: std_logic;

begin
   process(clk)
          begin
      		if (clk ='1' and clk'event)then
			if(reset='1')then
				sAout <= (others => '0');
				sBout <= (others => '0');
				sSumout <= (others => '0');
				sCarryout <= '0';
				sUExp <= (others => '0');
				sRun <= '0';
			elsif (en='1')then
				sAout <= InA;
				sBout <= InB;
				sSumout <= SumIn;
				sCarryout <= CarryIn;
				sUExp <= UExp;
				sRun <= en;
			else
				sAout <= sAout;
				sBout <= sBout;
				sSumout <= sSumout;
				sCarryout <= sCarryout;
				sUExp <= sUExp;
				sRun <= sRun;
			end if;
		else
			sAout <= sAout;
			sBout <= sBout;
			sSumout <= sSumout;
			sCarryout <= sCarryout;
			sUExp <= sUExp;
			sRun <= sRun;
		end if;
	end process;
Aout <= sAout;
Bout <= sBout;
Sumout <= sSumout;
Carryout <= sCarryout;
RunO <= sRun;
OExp <= sUExp;
end reg16bit_arch;

---------------------------------------------------------------------------------
-------------Generic Register-------------------------------------------------------
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164. all;
entity ALEY_GenReg is
	generic(w: integer:= 24; bbits: integer:=2; prevbbits: integer:= 2; sumsize: integer:=24);
        port (
		clk: in std_logic;
		reset: in std_logic;
		en:  in std_logic;
		UExp: in std_logic_vector(8 downto 0);
		InA: in std_logic_vector(w-1 downto 0);
		InB: in std_logic_vector(w-1 downto 0); 
		SumIn: in std_logic_vector(bbits-1 downto 0);
		PrevSum: in std_logic_vector(prevbbits-1 downto 0);
		CarryIn: in std_logic;
                Aout: out std_logic_vector(w-1 downto 0);
		Bout: out std_logic_vector(w-1 downto 0);
		SumOut: out std_logic_vector(sumsize-1 downto 0);
		Carryout: out std_logic;
		RunO: out std_logic;
		OExp: out std_logic_vector(8 downto 0)
);

end ALEY_GenReg;

architecture reg16bit_arch of ALEY_GenReg is
signal sAout: std_logic_vector(w-1 downto 0);
signal sBout: std_logic_vector(w-1 downto 0);
signal sSumout: std_logic_vector(sumsize-1 downto 0);
signal scarryout: std_logic;
signal sUExp: std_logic_vector(8 downto 0);
signal sRun: std_logic;
begin
   process(clk)
          begin
      		if (clk ='1' and clk'event)then
			if(reset='1')then
				sAout <= (others => '0');
				sBout <= (others => '0');
				sSumout <= (others => '0');
				sCarryout <= '0';
				sUExp <= (others => '0');
				sRun <= '0';
			elsif (en='1')then
				sAout <= InA;
				sBout <= InB;
				sSumout <= SumIn & PrevSum;
				sCarryout <= CarryIn;
				sUExp <= UExp;
				sRun <= en;
			else
				sAout <= sAout;
				sBout <= sBout;
				sSumout <= sSumout;
				sCarryout <= sCarryout;
				sUExp <= sUExp;
				sRun <= sRun;
			end if;
		else
			sAout <= sAout;
			sBout <= sBout;
			sSumout <= sSumout;
			sCarryout <= sCarryout;
			sUExp <= sUExp;
			sRun <= sRun;
		end if;
	end process;
Aout <= sAout;
Bout <= sBout;
Sumout <= sSumout;
Carryout <= sCarryout;
RunO <= sRun;
OExp <= sUExp;
end reg16bit_arch;

-----------------------------------------------------------------
---------------------ALEY_RCA_6B_26bit---------------------------
-----------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;

ENTITY ALEY_RCA_6B IS
generic(W: integer :=26; bbits: integer :=6);
PORT (	
	clk: in std_logic;
	reset: in std_logic;
	en:  in std_logic;
        UExp: in std_logic_vector(8 downto 0);
	Op_A	:IN STD_LOGIC_VECTOR(W-1 downto 0);
	Op_B	:IN STD_LOGIC_VECTOR(W-1 downto 0);
	SUM_Q	:OUT STD_LOGIC_VECTOR(W-1 downto 0);
	Carry_Q	:OUT STD_LOGIC;
	OExp: out std_logic_vector(8 downto 0);
	RunO: out std_logic
     );

END ALEY_RCA_6B;

ARCHITECTURE BEH OF ALEY_RCA_6B IS

SIGNAL s1: std_logic_vector(bbits-1 downto 0);
SIGNAL s2: std_logic_vector(bbits-1 downto 0);
SIGNAL s3: std_logic_vector(bbits-1 downto 0);
SIGNAL s4: std_logic_vector(bbits-1 downto 0);
SIGNAL s5: std_logic_vector(1 downto 0);

SIGNAL Rs1: std_logic_vector(bbits-1 downto 0);
SIGNAL Rs2: std_logic_vector(2*bbits-1 downto 0);
SIGNAL Rs3: std_logic_vector(3*bbits-1 downto 0);
SIGNAL Rs4: std_logic_vector(4*bbits-1 downto 0);
SIGNAL Rs5: std_logic_vector(w-1 downto 0);

SIGNAL c1: std_logic;
SIGNAL c2: std_logic;
SIGNAL c3: std_logic;
SIGNAL c4: std_logic;
SIGNAL c5: std_logic;

SIGNAL RAout1: std_logic_vector(w-1-bbits downto 0);
SIGNAL RAout2: std_logic_vector(w-1-2*bbits downto 0); 
SIGNAL RAout3: std_logic_vector(w-1-3*bbits downto 0);
SIGNAL RAout4: std_logic_vector(w-1-4*bbits downto 0);
SIGNAL RAout5: std_logic_vector(1 downto 0);

SIGNAL RBout1: std_logic_vector(w-1-bbits downto 0);
SIGNAL RBout2: std_logic_vector(w-1-2*bbits downto 0);
SIGNAL RBout3: std_logic_vector(w-1-3*bbits downto 0);
SIGNAL RBout4: std_logic_vector(w-1-4*bbits downto 0);
SIGNAL RBout5: std_logic_vector(1 downto 0);


SIGNAL Rc1: std_logic;
SIGNAL Rc2: std_logic;
SIGNAL Rc3: std_logic;
SIGNAL Rc4: std_logic;
SIGNAL Rc5: std_logic;

SIGNAL Run1: std_logic;
SIGNAL Run2: std_logic;
SIGNAL Run3: std_logic;
SIGNAL Run4: std_logic;
SIGNAL Run5: std_logic;

SIGNAL sUExp1: std_logic_vector(8 downto 0);
SIGNAL sUExp2: std_logic_vector(8 downto 0);
SIGNAL sUExp3: std_logic_vector(8 downto 0);
SIGNAL sUExp4: std_logic_vector(8 downto 0);
SIGNAL sUExp5: std_logic_vector(8 downto 0);

SIGNAL sUExp6: std_logic_vector(8 downto 0);
SIGNAL sUExp7: std_logic_vector(8 downto 0);
SIGNAL sUExp8: std_logic_vector(8 downto 0);
SIGNAL sUExp9: std_logic_vector(8 downto 0);
SIGNAL sUExp10: std_logic_vector(8 downto 0);


COMPONENT ALEY_RCA_GEN_2B IS
generic(BITS2: integer := 2);
PORT (	
	Op_A	:IN STD_LOGIC_VECTOR(BITS2-1 downto 0);
	Op_B	:IN STD_LOGIC_VECTOR(BITS2-1 downto 0);
	Op_C	:IN STD_LOGIC;
	UExp    :in std_logic_vector(8 downto 0);
	SUM_Q	:OUT STD_LOGIC_VECTOR(BITS2-1 downto 0);
	Carry_Q	:OUT STD_LOGIC;
	OExp    :out std_logic_vector(8 downto 0)
     );

END COMPONENT;

COMPONENT ALEY_RCA_First_6B IS
generic(BITS6: integer := 6);
PORT (	
	Op_A	:IN STD_LOGIC_VECTOR(bbits-1 downto 0);
	Op_B	:IN STD_LOGIC_VECTOR(bbits-1 downto 0);
	UExp    :in std_logic_vector(8 downto 0);
	SUM_Q	:OUT STD_LOGIC_VECTOR(bbits-1 downto 0);
	Carry_Q	:OUT STD_LOGIC;
	OExp    :out std_logic_vector(8 downto 0)
     );

END COMPONENT;

COMPONENT ALEY_RCA_GEN_6B IS
generic(BITS6: integer := 6);
PORT (	
	Op_A	:IN STD_LOGIC_VECTOR(bbits-1 downto 0);
	Op_B	:IN STD_LOGIC_VECTOR(bbits-1 downto 0);
	Op_C	:IN STD_LOGIC;
	UExp    :in std_logic_vector(8 downto 0);
	SUM_Q	:OUT STD_LOGIC_VECTOR(bbits-1 downto 0);
	Carry_Q	:OUT STD_LOGIC;
	OExp    :out std_logic_vector(8 downto 0)
     );

END COMPONENT;

COMPONENT ALEY_FirstReg is
	generic(w: integer:= 24; bbits: integer:=2);
        port (
		clk: in std_logic;
		reset: in std_logic;
		en:  in std_logic;
		UExp: in std_logic_vector(8 downto 0);
		InA: in std_logic_vector(w-1 downto 0);
		InB: in std_logic_vector(w-1 downto 0); 
		SumIn: in std_logic_vector(bbits-1 downto 0);
		CarryIn: in std_logic;
                Aout: out std_logic_vector(w-1 downto 0);
		Bout: out std_logic_vector(w-1 downto 0);
		SumOut: out std_logic_vector(bbits-1 downto 0);
		Carryout: out std_logic;
		RunO: out std_logic;
		OExp: out std_logic_vector(8 downto 0)
);

end COMPONENT;

COMPONENT ALEY_GenReg is
	generic(w: integer:= 24; bbits: integer:=2; prevbbits: integer:= 2; sumsize: integer:=24);
        port (
		clk: in std_logic;
		reset: in std_logic;
		en:  in std_logic;
		UExp: in std_logic_vector(8 downto 0);
		InA: in std_logic_vector(w-1 downto 0);
		InB: in std_logic_vector(w-1 downto 0); 
		SumIn: in std_logic_vector(bbits-1 downto 0);
		PrevSum: in std_logic_vector(prevbbits-1 downto 0);
		CarryIn: in std_logic;
                Aout: out std_logic_vector(w-1 downto 0);
		Bout: out std_logic_vector(w-1 downto 0);
		SumOut: out std_logic_vector(sumsize-1 downto 0);
		Carryout: out std_logic;
		RunO: out std_logic;
		OExp: out std_logic_vector(8 downto 0)
);

end COMPONENT;

COMPONENT ALEY_LastReg is
	generic(bbits: integer:=2; prevbbits: integer:= 2; sumsize: integer:=24);
        port (
		clk: in std_logic;
		reset: in std_logic;
		en:  in std_logic;
		UExp: in std_logic_vector(8 downto 0);
		SumIn: in std_logic_vector(bbits-1 downto 0);
		PrevSum: in std_logic_vector(prevbbits-1 downto 0);
		CarryIn: in std_logic;
		SumOut: out std_logic_vector(sumsize-1 downto 0);
		Carryout: out std_logic;
		RunO: out std_logic;
		OExp: out std_logic_vector(8 downto 0)
);
end COMPONENT;

BEGIN

InstALEY_RCA_First_6B: ALEY_RCA_First_6B generic map(bbits)         		    port map(OP_A(5 downto 0), OP_B(5 downto 0), UExp, s1, c1, sUExp1);
InstALEY_RCA_GEN_REG1: ALEY_FirstReg     generic map(w-bbits,bbits) 		    port map(clk, reset, en, sUExp1, OP_A(W-1 downto bbits), OP_B(W-1 downto bbits), s1, c1, RAout1, RBout1, Rs1, Rc1, Run1, sUExp2);

InstALEY_RCA_GEN_6B1: ALEY_RCA_GEN_6B generic map(bbits) 			    port map(RAout1(5 downto 0), RBout1(5 downto 0), Rc1, sUExp2, s2, c2, sUExp3);
InstALEY_RCA_GEN_REG2: ALEY_GenReg    generic map(w-2*bbits,bbits,bbits, 2*bbits)   port map(clk, reset, Run1, sUExp3, RAout1(W-1-bbits downto bbits), RBout1(W-1-bbits downto bbits), s2, Rs1, c2, RAout2, RBout2, Rs2, Rc2, Run2, sUExp4);

InstALEY_RCA_GEN_6B2: ALEY_RCA_GEN_6B generic map(bbits) 			    port map(RAout2(5 downto 0), RBout2(5 downto 0), Rc2, sUExp4, s3, c3, sUExp5);
InstALEY_RCA_GEN_REG3: ALEY_GenReg    generic map(w-3*bbits,bbits,2*bbits, 3*bbits) port map(clk, reset, Run2, sUExp5, RAout2(W-1-2*bbits downto bbits), RBout2(W-1-2*bbits downto bbits), s3, Rs2, c3, RAout3, RBout3, Rs3, Rc3, Run3, sUExp6);

InstALEY_RCA_GEN_6B3: ALEY_RCA_GEN_6B generic map(bbits) 			    port map(RAout3(5 downto 0), RBout3(5 downto 0), Rc3, sUExp6, s4, c4, sUExp7);
InstALEY_RCA_GEN_REG4: ALEY_GenReg    generic map(w-4*bbits,bbits,3*bbits, 4*bbits) port map(clk, reset, Run3, sUExp7, RAout3(W-1-3*bbits downto bbits), RBout3(W-1-3*bbits downto bbits), s4, Rs3, c4, RAout4, RBout4, Rs4, Rc4, Run4, sUExp8);


InstALEY_RCA_Last2_bits: ALEY_RCA_GEN_2B generic map(2) 		            port map(RAout4(1 downto 0), RBout4(1 downto 0), Rc4, sUExp8, s5, c5, sUExp9);
InstALEY_RCA_Last_REG1: ALEY_LastReg  generic map(2,24,26) 			    port map(clk, reset, Run4, sUExp9, s5, Rs4, c5, SUM_Q, Carry_Q, RunO, OExp);

END BEH;



---------------------------------------------------------------------------------
-------------RCA_GEN_2B-------------------------------------------------------
---------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;

ENTITY ALEY_RCA_GEN_2B IS
generic(BITS2: integer := 2);
PORT (	
	Op_A	:IN STD_LOGIC_VECTOR(BITS2-1 downto 0);
	Op_B	:IN STD_LOGIC_VECTOR(BITS2-1 downto 0);
	Op_C	:IN STD_LOGIC;
	UExp    :in std_logic_vector(8 downto 0);
	SUM_Q	:OUT STD_LOGIC_VECTOR(BITS2-1 downto 0);
	Carry_Q	:OUT STD_LOGIC;
	OExp    :out std_logic_vector(8 downto 0)

     );

END ALEY_RCA_GEN_2B;

ARCHITECTURE beh_gen_2B OF ALEY_RCA_GEN_2B IS

SIGNAL s1: std_logic;
SIGNAL s2: std_logic;

SIGNAL c1: std_logic;
SIGNAL c2: std_logic;


COMPONENT ALEY_GEN_BSlice IS
PORT (	
	Op_A	:IN STD_LOGIC;
	Op_B	:IN STD_LOGIC;
	Op_C	:IN STD_LOGIC;
	SUM_Q	:OUT STD_LOGIC;
	Carry_Q	:OUT STD_LOGIC
     );

END COMPONENT;

BEGIN

InstALEY_GEN_BSlice1: ALEY_GEN_BSlice port map(OP_A(0), OP_B(0), OP_C, s1, c1);
InstALEY_GEN_BSlice2: ALEY_GEN_BSlice port map(OP_A(1), OP_B(1), c1, s2, c2);

SUM_Q(0) <= s1;
SUM_Q(1) <= s2;
Carry_Q <= c2;
OExp <=UExp;
END beh_gen_2B;


---------------------------------------------------------------------------------
-------------RCA_First_6B-------------------------------------------------------
---------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;

ENTITY ALEY_RCA_First_6B IS
generic(BITS6: integer := 6);
PORT (	
	Op_A	:IN STD_LOGIC_VECTOR(BITS6-1 downto 0);
	Op_B	:IN STD_LOGIC_VECTOR(BITS6-1 downto 0);
	UExp    :in std_logic_vector(8 downto 0);
	SUM_Q	:OUT STD_LOGIC_VECTOR(BITS6-1 downto 0);
	Carry_Q	:OUT STD_LOGIC;
	OExp    :out std_logic_vector(8 downto 0)
     );

END ALEY_RCA_First_6B;

ARCHITECTURE beh_first_6B OF ALEY_RCA_First_6B IS

SIGNAL s1: std_logic;
SIGNAL s2: std_logic;
SIGNAL s3: std_logic;
SIGNAL s4: std_logic;
SIGNAL s5: std_logic;
SIGNAL s6: std_logic;

SIGNAL c1: std_logic;
SIGNAL c2: std_logic;
SIGNAL c3: std_logic;
SIGNAL c4: std_logic;
SIGNAL c5: std_logic;
SIGNAL c6: std_logic;

COMPONENT ALEY_First_BSlice IS
PORT (	
	Op_A	:IN STD_LOGIC;
	Op_B	:IN STD_LOGIC;
	SUM_Q	:OUT STD_LOGIC;
	Carry_Q	:OUT STD_LOGIC
     );

END COMPONENT;

COMPONENT ALEY_GEN_BSlice IS
PORT (	
	Op_A	:IN STD_LOGIC;
	Op_B	:IN STD_LOGIC;
	Op_C	:IN STD_LOGIC;
	SUM_Q	:OUT STD_LOGIC;
	Carry_Q	:OUT STD_LOGIC
     );

END COMPONENT;

BEGIN

InstALEY_First_BSlice1: ALEY_First_BSlice port map(OP_A(0), OP_B(0), s1, c1);
InstALEY_GEN_BSlice1: ALEY_GEN_BSlice port map(OP_A(1), OP_B(1), c1, s2, c2);
InstALEY_GEN_BSlice2: ALEY_GEN_BSlice port map(OP_A(2), OP_B(2), c2, s3, c3);

InstALEY_GEN_BSlice3: ALEY_GEN_BSlice port map(OP_A(3), OP_B(3), c3, s4, c4);
InstALEY_GEN_BSlice4: ALEY_GEN_BSlice port map(OP_A(4), OP_B(4), c4, s5, c5);
InstALEY_GEN_BSlice5: ALEY_GEN_BSlice port map(OP_A(5), OP_B(5), c5, s6, c6);


SUM_Q(0) <= s1;
SUM_Q(1) <= s2;
SUM_Q(2) <= s3;
SUM_Q(3) <= s4;
SUM_Q(4) <= s5;
SUM_Q(5) <= s6;
Carry_Q <= c6;
OExp <= UExp;
END beh_first_6B;

---------------------------------------------------------------------------------
-------------RCA_GEN_6B-------------------------------------------------------
---------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;

ENTITY ALEY_RCA_GEN_6B IS
generic(BITS6: integer := 6);
PORT (	
	Op_A	:IN STD_LOGIC_VECTOR(BITS6-1 downto 0);
	Op_B	:IN STD_LOGIC_VECTOR(BITS6-1 downto 0);
	Op_C	:IN STD_LOGIC;
	UExp    :in std_logic_vector(8 downto 0);
	SUM_Q	:OUT STD_LOGIC_VECTOR(BITS6-1 downto 0);
	Carry_Q	:OUT STD_LOGIC;
	OExp    :out std_logic_vector(8 downto 0)
     );

END ALEY_RCA_GEN_6B;

ARCHITECTURE beh_gen_6B OF ALEY_RCA_GEN_6B IS

SIGNAL s1: std_logic;
SIGNAL s2: std_logic;
SIGNAL s3: std_logic;
SIGNAL s4: std_logic;
SIGNAL s5: std_logic;
SIGNAL s6: std_logic;

SIGNAL c1: std_logic;
SIGNAL c2: std_logic;
SIGNAL c3: std_logic;
SIGNAL c4: std_logic;
SIGNAL c5: std_logic;
SIGNAL c6: std_logic;

COMPONENT ALEY_GEN_BSlice IS
PORT (	
	Op_A	:IN STD_LOGIC;
	Op_B	:IN STD_LOGIC;
	Op_C	:IN STD_LOGIC;
	SUM_Q	:OUT STD_LOGIC;
	Carry_Q	:OUT STD_LOGIC
     );

END COMPONENT;


BEGIN

InstALEY_GEN_BSlice1: ALEY_GEN_BSlice port map(OP_A(0), OP_B(0), OP_C, s1, c1);
InstALEY_GEN_BSlice2: ALEY_GEN_BSlice port map(OP_A(1), OP_B(1), c1, s2, c2);
InstALEY_GEN_BSlice3: ALEY_GEN_BSlice port map(OP_A(2), OP_B(2), c2, s3, c3);

InstALEY_GEN_BSlice4: ALEY_GEN_BSlice port map(OP_A(3), OP_B(3), c3, s4, c4);
InstALEY_GEN_BSlice5: ALEY_GEN_BSlice port map(OP_A(4), OP_B(4), c4, s5, c5);
InstALEY_GEN_BSlice6: ALEY_GEN_BSlice port map(OP_A(5), OP_B(5), c5, s6, c6);


SUM_Q(0) <= s1;
SUM_Q(1) <= s2;
SUM_Q(2) <= s3;
SUM_Q(3) <= s4;
SUM_Q(4) <= s5;
SUM_Q(5) <= s6;
Carry_Q <= c6;
OExp <= UExp;
END beh_gen_6B;