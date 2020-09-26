library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library xil_defaultlib;
use xil_defaultlib.myPack.all;

entity VecMul is
    Port (clk: in std_logic;
        inputReady : in std_logic;
        input, weight1, weight2 : in word_ubt(299 downto 0);
        biases : in word_ubt(1 downto 0);
        oval1, oval2 : out real;
        outputReady : out std_logic);
end VecMul;

architecture Behavioral of VecMul is

type ST_TYPE is (init, waitForInput, conv);
signal state : ST_TYPE := init;
signal inputChecker, outputReadyVar: std_logic := '0';
signal wordLength : integer := 0;
signal sum1, sum2 : real := 0.0;
signal wtfSig : std_logic := '0';

begin

process(clk)

variable tmpNum1, tmpNum2 : real;
variable tmpLogic : std_logic;

begin
    if (rising_edge(clk)) then
        case state is
            when init =>
                wordLength <= 300 - 1; 
                sum1 <= 0.0;
                sum2 <= 0.0;
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
                tmpNum1 := sum1 + input(299 - wordLength) * weight1(299 - wordLength);
                tmpNum2 := sum2 + input(299 - wordLength) * weight2(299 - wordLength);
                sum1 <= tmpNum1;
                sum2 <= tmpNum2;
                if (wordLength = 0) then
                    tmpLogic := not outputReadyVar;
                    outputReady <= tmpLogic;
                    outputReadyVar <= tmpLogic;
                    tmpNum1 := tmpNum1 + biases(0);
                    tmpNum2 := tmpNum2 + biases(1);
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
