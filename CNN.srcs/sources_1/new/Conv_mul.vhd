library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library xil_defaultlib;
use xil_defaultlib.myPack.all;

entity Conv_mul is
  Generic(filterSize: integer := 3);
  Port (clk: in std_logic;
        inputReady : in std_logic;
        sentence, filter : in twod3_t;
        bias: in real;
        result : out real;
        outputReady : out std_logic);
end Conv_mul;

architecture Behavioral of Conv_mul is

type ST_TYPE is (init, waitForInput, conv);
signal state : ST_TYPE := init;
signal inputChecker, outputReadyVar: std_logic := '0';
signal wordLength, filterWidth: integer := 0;
signal sum : real;
signal indx0, indx1, indx2, indx3 : integer;
signal tval0, tval1 : real;

begin

process(clk)

variable tmpNum: real;
variable tmpLogic : std_logic;

begin
    if (rising_edge(clk)) then
        case state is
            when init =>
                wordLength <= 300 - 1; 
                filterWidth <= filterSize - 1;
                sum <= 0.0;
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
                indx0 <= filterSize - filterWidth - 1;
                indx1 <= 300 - wordLength - 1;
                indx2 <= filterWidth;
                indx3 <= wordLength;
                tval0 <= sentence(filterSize - filterWidth - 1)(300 - wordLength - 1);
                tval1 <= filter(filterWidth)(wordLength);
                tmpNum := sum + sentence(filterSize - filterWidth - 1)(300 - wordLength - 1)*filter(filterWidth)(wordLength);
                sum <= tmpNum;
                if (wordLength = 0 and filterWidth = 0) then
                    tmpLogic := not outputReadyVar;
                    outputReady <= tmpLogic;
                    outputReadyVar <= tmpLogic;
                    result <= tmpNum;
                    state <= init;
                else
                    if (wordLength = 0) then
                        wordLength <= 300 - 1;
                        filterWidth <= filterWidth - 1;
                    else
                        wordLength <= wordLength - 1;
                    end if;
                    state <= conv;
                end if;
            when others =>
                state <= init;
        end case;
    
    end if;
end process;

end Behavioral;
