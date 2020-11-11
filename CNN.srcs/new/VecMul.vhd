library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all;
library xil_defaultlib;
use xil_defaultlib.myPack.all;

entity VecMul is
    Port (clk: in std_logic;
        inputReady : in std_logic;
        input, weight1, weight2 : in word_ubt(299 downto 0);
        biases : in word_ubt(1 downto 0);
        oval1, oval2 : out std_logic_vector(31 downto 0);
        outputReady : out std_logic);
end VecMul;

architecture Behavioral of VecMul is

type ST_TYPE is (init, waitForInput, conv);
signal state : ST_TYPE := init;
signal inputChecker, outputReadyVar: std_logic := '0';
signal wordLength : integer := 0;
signal sum1, sum2 : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
signal wtfSig : std_logic := '0';

begin

process(clk)

variable tmpNum1, tmpNum2 : std_logic_vector(31 downto 0);
variable tmpLogic : std_logic;
variable tres1 : std_logic_vector(63 downto 0);
variable ts : signed(63 downto 0);

begin
    if (rising_edge(clk)) then
        case state is
            when init =>
                wordLength <= 300 - 1; 
                sum1 <= "00000000000000000000000000000000";
                sum2 <= "00000000000000000000000000000000";
                state <= waitForInput;
                outputReady <= outputReadyVar;
            when waitForInput =>
                if (inputReady = inputChecker) then
                    state <= waitForInput;
                else
                    inputChecker <= inputReady;
                    state <= conv;
                end if;
            when conv =>
                tres1 := std_logic_vector(signed(input(299 - wordLength)) * signed(weight1(299 - wordLength)));
                ts := shift_right(signed(tres1),24);
                tmpNum1 := std_logic_vector(ts(31 DOWNTO 0));
                tmpNum1 := std_logic_vector(signed(tmpNum1) + signed(sum1));
--                tmpNum1 := input(299 - wordLength) * weight1(299 - wordLength);
--                tmpNum1 := tmpNum1 + sum1;
                
                tres1 := std_logic_vector(signed(input(299 - wordLength)) * signed(weight2(299 - wordLength)));
                ts := shift_right(signed(tres1),24);
                tmpNum2 := std_logic_vector(ts(31 DOWNTO 0));
                tmpNum2 := std_logic_vector(signed(tmpNum2) + signed(sum2));
--                tmpNum2 := input(299 - wordLength) * weight2(299 - wordLength);
--                tmpNum2 := tmpNum2 + sum2;
                
                
                sum1 <= tmpNum1;
                sum2 <= tmpNum2;
                if (wordLength = 0) then
                    tmpLogic := not outputReadyVar;
                    outputReady <= tmpLogic;
                    outputReadyVar <= tmpLogic;
                    tmpNum1 := std_logic_vector(signed(tmpNum1) + signed(biases(0)));
                    tmpNum2 := std_logic_vector(signed(tmpNum2) + signed(biases(1)));
--                    tmpNum1 := tmpNum1 + biases(0);
--                    tmpNum2 := tmpNum2 + biases(1);
                    oval1 <= tmpNum1;
                    oval2 <= tmpNum2;
                    state <= init;
                else
                    wordLength <= wordLength - 1;
                    state <= conv;
                end if;
            when others =>
                state <= init;
        end case;
    end if;
end process;



end Behavioral;
