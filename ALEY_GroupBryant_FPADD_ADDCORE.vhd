library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.">";
use ieee.std_logic_unsigned.SHR;
use ieee.std_logic_unsigned.CONV_INTEGER;
use ieee.std_logic_misc.OR_REDUCE;
use ieee.std_logic_arith.all;

entity ALEY_GroupBryant_FPADD_ADDCORE is
   port(clk: in std_logic;
	reset: in std_logic;
	enR :in std_logic;
	enL: in std_logic;
	IN_A: in std_logic_vector(31 downto 0);
	IN_B: in std_logic_vector(31 downto 0);
	SUM_Q: out std_logic_vector(31 downto 0);
	RunOut: out std_logic);
end ALEY_GroupBryant_FPADD_ADDCORE;

architecture RTL of ALEY_GroupBryant_FPADD_ADDCORE is

COMPONENT CompareExp is
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
End COMPONENT;

COMPONENT ComputeShift IS
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
END COMPONENT;

COMPONENT ShiftMan is
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

end COMPONENT;

COMPONENT CompareMan is
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
end COMPONENT;

COMPONENT AddSubPipeMan IS
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
END COMPONENT;

COMPONENT Norm1 is
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
end COMPONENT;

COMPONENT Norm2 is
   Port(clk :in std_logic;
	reset :in std_logic;
	Run :in std_logic;
	ExpCor :in std_logic_vector(7 downto 0);
	ShfDst :in std_logic_vector(4 downto 0 );
	UExp : in std_logic_vector(8 downto 0);
	UMan :in std_logic_vector(25 downto 0);
	Q :out std_logic_vector(31 downto 0);
	RunO :out std_logic);
end COMPONENT;

COMPONENT ALEY_GroupBryant_RCA_6B IS
generic(W: integer :=24; bbits: integer :=6);
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
END COMPONENT;

COMPONENT ALEY_GroupBryant_RCA_GEN_2B IS
generic(BITS2: integer := 2);
PORT (	
	Op_A	:IN STD_LOGIC_VECTOR(BITS2-1 downto 0);
	Op_B	:IN STD_LOGIC_VECTOR(BITS2-1 downto 0);
	Op_C	:IN STD_LOGIC;
	SUM_Q	:OUT STD_LOGIC_VECTOR(BITS2-1 downto 0);
	Carry_Q	:OUT STD_LOGIC
     );

END COMPONENT;

COMPONENT ALEY_GroupBryant_FinalReg is
        port (
		clk: in std_logic;
		reset: in std_logic;
		en:  in std_logic;
	        RunIn: in std_logic;
		SumIn: in std_logic_vector(31 downto 0);
		SumOut: out std_logic_vector(31 downto 0);
		RunO: out std_logic
);

end COMPONENT;

SIGNAL sLExp, sSexp :std_logic_vector(7 downto 0); -- output signals for CompareExp 
SIGNAL sLMan, sSMan :std_logic_vector(22 downto 0);
SIGNAL sLSign, sSSign :std_logic;
SIGNAL sRunO :std_logic;

SIGNAL sLExpP, sSexpP :std_logic_vector(7 downto 0); -- output signals for ComputeShift 
SIGNAL sLManP, sSManP :std_logic_vector(22 downto 0);
SIGNAL sLSignP, sSSignP :std_logic;
SIGNAL sRunOP :std_logic;
SIGNAL sshiftdistance :std_logic_vector(4 downto 0);

SIGNAL sLExpPP :std_logic_vector(7 downto 0); -- output signals for Shiftman
SIGNAL sLManPP, sSManPP :std_logic_vector(24 downto 0);
SIGNAL sLSignPP, sSSignPP :std_logic;
SIGNAL sRunOPP :std_logic;
--SIGNAL sshiftdistanceP :std_logic_vector(4 downto 0);

SIGNAL sCompExp :std_logic_vector(7 downto 0); -- output signals for CompareMan
SIGNAL sLManPPP, sSManPPP :std_logic_vector(24 downto 0);
SIGNAL sCompSign :std_logic;
SIGNAL sAddSub :std_logic;
SIGNAL sRunOPPP :std_logic;

SIGNAL sUExp :std_logic_vector(8 downto 0); --output signals for addsubpipe
SIGNAL sManOutA :Std_logic_vector(25 downto 0);
SIGNAL sManOutB :Std_logic_vector(25 downto 0);
SIGNAL sRunOPPPP: std_logic;

SIGNAL sNewManPart :std_logic_vector(25 downto 0); --output signals for RCA_6B
SIGNAL carryout: std_logic;
SIGNAL sRunOPPPPP: std_logic;
SIGNAL sUExpP: std_logic_vector(8 downto 0);

SIGNAL sNewManFront :std_logic_vector(1 downto 0); --output signals for carry add
SIGNAL carryoutP: std_logic;
SIGNAL sRunOPPPPPP: std_logic;


SIGNAL sExpCor :std_logic_vector(7 downto 0); --output signals for norm1
SIGNAL sShftDst :Std_logic_vector(4 downto 0);
SIGNAL sOMan :std_logic_vector(25 downto 0);
SIGNAL sOExp :Std_logic_vector(8 downto 0);

SIGNAL sUMan :Std_logic_vector(25 downto 0);

SIGNAL sQ :Std_logic_vector(31 downto 0);
SIGNAL sRunQ :Std_logic;

SIGNAL finalSUm :Std_logic_vector(31 downto 0);
SIGNAL finalRun :Std_logic;

begin

InstALEY_GroupBryant_COMPARE_EXP: CompareExp     			port map(clk, reset, EnR, EnL, IN_A, IN_B, sLExp, sSExp, sLMan, sSMan, sLSign, sSSign, sRunO );
InstALEY_GroupBryant_COMPUTE_SHIFT: ComputeShift 			port map(clk, reset, sRunO, sLExp, sSExp, sLMan, sSMan, sLSign, sSSign, sLExpP, sSExpP, sLManP, sSManP, sLSignP, sSSignP, sshiftdistance, sRunOP  );
InstALEY_GroupBryant_Shift_MANTISSA: ShiftMan    			port map(clk, reset, sRunOP, sshiftdistance, sLExpP, sSExpP, sLManP, sSManP, sLSignP, sSSignP, sLExpPP, sLManPP, sSManPP, sLSignPP, sSSignPP, sRunOPP ); 
InstALEY_GroupBryant_Compare_MAN: CompareMan     			port map(clk, reset, sRunOPP, sLSignPP, sLExpPP, sLManPP, sSSignPP, sSManPP, sCompExp, sLManPPP, sSManPPP, sCompSign, sAddSub, sRunOPPP );
InstALEY_GroupBryant_SIMPLEADDSUB: AddSubPipeMan 			port map(clk, reset, sRunOPPP, sCompSign, sAddSub, sCompExp, sLManPPP, sSManPPP, sUExp, sManOutA, sManOutB, sRunOPPPP);

InstALEY_GroupBryant_RCA_6B_ADDER: ALEY_GroupBryant_RCA_6B   generic map(26, 6) port map(clk, reset, sRunOPPPP, sUExp, sManOutA(25 downto 0), sManOutB(25 downto 0), sNewManPart(25 downto 0), carryout, sUExpP, sRunOPPPPP);

InstALEY_GroupBryant_NORM1: Norm1                			port map(clk, reset, sRunOPPPPP, sNewManPart, sUExpP, sExpCor, sShftDst, sOMan, sOExp, sRunOPPPPPP );
InstALEY_GroupBryant_NORM2: Norm2		     			port map(clk, reset, sRunOPPPPPP, sExpCor, sShftDst, sOExp, sOMan, sQ, sRunQ );

InstALEY_GroupBryant_FinalReg: ALEY_GroupBryant_FinalReg			port map(clk, reset, sRunQ, sRunQ, sQ, finalSum, finalRun);

with finalRun select
 SUM_Q <= finalSum when '1',
          (others => '1') when '0',
	  (others => 'X') when others;
RunOut <= finalRun;

end RTL;