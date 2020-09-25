--------------------------------------------------------------
--------------------------------------------------------------
-- Copyright Jordan Aley, Howard University 
-- Adv. Dig. Design. II (496)
-- Dr. Michaela E. Amoo
--RCA
--------------------------------------------------------------
--------------------------------------------------------------


LIBRARY IEEE;
USE work.CLOCKS.all;  		 -- Entity that uses CLOCKS
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_textio.all;
USE std.textio.all;
USE work.txt_util.all;
 
ENTITY tb_ALEY_FLOATADD IS
END;

ARCHITECTURE TESTBENCH OF tb_ALEY_FLOATADD IS

CONSTANT W : integer := 32;

---------------------------------------------------------------
-- COMPONENTS -- Entity In/out Ports
---------------------------------------------------------------

COMPONENT ALEY_FLOATADD
PORT (	
	clk: in std_logic;
	reset: in std_logic;
	enR :in std_logic;
	enL: in std_logic;
	IN_A: in std_logic_vector(31 downto 0);
	IN_B: in std_logic_vector(31 downto 0);
	SUM_Q: out std_logic_vector(31 downto 0);
	RunOut: out std_logic
     );
END COMPONENT;

COMPONENT CLOCK
	port(	CLK: out std_logic);
END COMPONENT;

---------------------------------------------------------------
-- Read/Write FILES
---------------------------------------------------------------


FILE in_file : TEXT open read_mode is 	"ALEY_FP_ADDER_Input.txt";   	-- Inputs (binary)
FILE exo_file : TEXT open read_mode is  	"ALEY_FP_ADDER_EXP_OUTPUT.txt";   	-- Expected output (binary)
FILE out_file : TEXT open  write_mode is  	"ALEY_FP_ADDER_dataout.txt";
FILE xout_file : TEXT open  write_mode is 	"ALEY_FP_ADDER_TestOut.txt";
FILE hex_out_file : TEXT open  write_mode is "ALEY_FP_ADDER_hex_out.txt";

---------------------------------------------------------------
-- SIGNALS 
---------------------------------------------------------------
  SIGNAL IN_A: STD_LOGIC_VECTOR(W-1 downto 0):= (OTHERS=>'X');
  SIGNAL IN_B: STD_LOGIC_VECTOR(W-1 downto 0):= (OTHERS=>'X');

  SIGNAL CLK: STD_LOGIC;
  SIGNAL reset: STD_LOGIC;
  SIGNAL enR: STD_LOGIC;
  SIGNAL enL: STD_LOGIC;

  SIGNAL Sum_Q: STD_LOGIC_VECTOR(W-1 downto 0):= (OTHERS=>'X');
  SIGNAL Exp_Sum_Q : STD_LOGIC_VECTOR(W-1 downto 0):= (OTHERS=>'X');
  SIGNAL RunOut: std_logic:= 'X';
  SIGNAL Exp_RunOut: std_logic:= 'X';

  SIGNAL Test_OutS : STD_LOGIC:= 'X';
  SIGNAL LineNumber: integer:=0;


---------------------------------------------------------------
-- BEGIN 
---------------------------------------------------------------

BEGIN

---------------------------------------------------------------
-- Instantiate Components 
---------------------------------------------------------------


U0: CLOCK port map (CLK );
InstALEY_FLOATADD: ALEY_FLOATADD port map (clk, reset, enR, enL, IN_A, IN_B, Sum_Q, RunOut);

---------------------------------------------------------------
-- PROCESS 
---------------------------------------------------------------
PROCESS
variable in_line, exo_line, out_line, xout_line : LINE;
variable comment, xcomment : string(1 to 128);
variable i : integer range 1 to 128;
variable simcomplete : boolean;

variable vreset: std_logic:='X';
variable venR: std_logic:='X';
variable venL: std_logic:='X';

variable vIN_A   : std_logic_vector(W-1 downto 0):= (OTHERS => 'X');
variable vIN_B   : std_logic_vector(W-1 downto 0):= (OTHERS => 'X');

variable vSum_Q : std_logic_vector(W-1 downto 0):= (OTHERS => 'X');
variable vRunOut : std_logic:= 'X';

variable vExp_Sum_Q : std_logic_vector(W-1 downto 0):= (OTHERS => 'X');
variable vExp_RunOut : std_logic:= 'X';

variable vTest_OutS : std_logic:= 'X';

variable vlinenumber: integer;


BEGIN

simcomplete := false;

while (not simcomplete) LOOP
  
	if (not endfile(in_file) ) then
		readline(in_file, in_line);
	else
		simcomplete := true;
	end if;

	if (not endfile(exo_file) ) then
		readline(exo_file, exo_line);
	else
		simcomplete := true;
	end if;
	
	if (in_line(1) = '-') then  --Skip comments
		next;
	elsif (in_line(1) = '.')  then  --exit Loop
	  Test_OutS <= 'Z';
		simcomplete := true;
	elsif (in_line(1) = '#') then        --Echo comments to out.txt
	  i := 1;
	  while in_line(i) /= '.' LOOP
		comment(i) := in_line(i);
		i := i + 1;
	  end LOOP;

	elsif (exo_line(1) = '-') then  --Skip comments
		next;
	elsif (exo_line(1) = '.')  then  --exit Loop
	  	  Test_OutS  <= 'Z';
		   simcomplete := true;
	elsif (exo_line(1) = '#') then        --Echo comments to out.txt
	     i := 1;
	   while exo_line(i) /= '.' LOOP
		 xcomment(i) := exo_line(i);
		 i := i + 1;
	   end LOOP;

	
	  write(out_line, comment);
	  writeline(out_file, out_line);
	  
	  write(xout_line, xcomment);
	  writeline(xout_file, xout_line);

	  
	ELSE      --Begin processing

		read(in_line, vreset );
		reset  <= vreset;
		read(in_line, venR );
		enR  <= venR;
		read(in_line, venL );
		enL  <= venL;

		read(in_line, vIN_A );
		IN_A  <= vIN_A;

		read(in_line, vIN_B );
		IN_B  <= vIN_B;
	
		read(exo_line, vexp_Sum_Q );
		exp_Sum_Q  <= vexp_Sum_Q;

		read(exo_line, vexp_RunOut );
		exp_RunOut  <= vexp_RunOut;
    vlinenumber :=LineNumber;
    
    write(out_line, vlinenumber);
    write(out_line, STRING'("."));
    write(out_line, STRING'("    "));

	

    CYCLE(1,CLK);
   
      
    if (Exp_Sum_Q = Sum_Q) AND (Exp_RunOut = RunOut) then
      Test_OutS <= '0';
    else
      Test_OutS <= 'X';
    end if;

          		
		write(out_line, vSum_Q, left, 32);
		write(out_line, STRING'("       "));                           --ht is ascii for horizontal tab

		write(out_line,vTest_OutS, left, 5);                           --ht is ascii for horizontal tab
		write(out_line, STRING'("       "));                           --ht is ascii for horizontal tab
		write(out_line, vexp_Sum_Q, left, 32);
		write(out_line, STRING'("       "));                           --ht is ascii for horizontal tab
		writeline(out_file, out_line);
		print(xout_file,    str(LineNumber)& "." & "    " &    str(Sum_Q) & "       " &   str(Exp_Sum_Q)  & "     " & str(Test_OutS));
	
	END IF;
	LineNumber<= LineNumber+1;

	END LOOP;
	WAIT;
	
	END PROCESS;

END TESTBENCH;

---------------------------------------------------------------
-- Configurations
---------------------------------------------------------------

CONFIGURATION cfg_tb_ALEY_FLOATADD OF tb_ALEY_FLOATADD IS
	FOR TESTBENCH
		FOR InstALEY_FLOATADD: ALEY_FLOATADD
			 use entity work.ALEY_FLOATADD;		
		END FOR;
	END FOR;
END;