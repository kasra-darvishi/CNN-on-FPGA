library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library xil_defaultlib;
use xil_defaultlib.myPack.all;

entity Conv_mul is
  Generic(filterSize: integer := 3);
  Port (clk: in std_logic;
        inputReady : in std_logic;
        sentence, filter : in sent_t(filterSize - 1 downto 0)(299 downto 0);
        bias: in real;
        result : out real;
        outputReady : out std_logic);
end Conv_mul;

architecture Behavioral of Conv_mul is

type ST_TYPE is (init, waitForInput, conv);
signal state : ST_TYPE := init;
signal inputChecker: std_logic := '0';
signal wordLength, filterWidth, outputReadyVar: integer := 0;
signal sum : real;

begin

process(clk)
variable tmpNum: integer;
variable tmpLogic : std_logic;
begin
    if (rising_edge(clk)) then
        case state is
            when init =>
                wordLength <= 300; 
                filterWidth <= filterSize;
                sum <= 0.0;
                state <= waitForInput;
            when waitForInput =>
                if (inputReady = inputChecker) then
                    state <= waitForInput;
                else
                    inputChecker <= inputReady;
                    state <= conv;
                end if;
            when conv =>
                if (wordLength = 0 and filterWidth = 0) then
                    tmpLogic := not outputReadyVar;
                    outputReady <= tmpLogic;
                    outputReadyVar <= tmpLogic;
                    state <= init;
                else
                    sum <= sum + sentence(filterSize - filterWidth)(300 - wordLength)*filter(filterWidth - 1)(wordLength - 1);
                    if (wordLength = 0) then
                        wordLength <= 300;
                        filterWidth <= filterWidth - 1;
                    end if;
                    wordLength <= wordLength - 1;
                    state <= conv;
                end if;
            when others =>
                state <= init;
        end case;
    
    end if;
end process;

end Behavioral;
