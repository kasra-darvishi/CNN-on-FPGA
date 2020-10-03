library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all;
library xil_defaultlib;
use xil_defaultlib.myPack.all;


entity Convolve is
  Generic(filterSize: integer := 3);
  Port (clk: in std_logic;
        inputReady : in std_logic;
        sentence : in sent_t;
        filters : in filter3_t;
        biases : in word100_t;
        result : out word_ubt(99 downto 0);
        outputReady : out std_logic);
end Convolve;

architecture Behavioral of Convolve is

component Conv_mul is
  Generic(filterSize: integer := 3);
  Port (clk: in std_logic;
        inputReady : in std_logic;
        sentence, filter : in twod3_t;
        bias: in std_logic_vector(31 downto 0);
        result : out std_logic_vector(31 downto 0);
        outputReady : out std_logic);
end component;

signal mulInputReady, mulResultReady, mulResultReadyVar : std_logic := '0';
signal subSent, filter : twod3_t;
signal bias, mulOut, maxVal : std_logic_vector(31 downto 0);

type ST_TYPE is (init, waitForInput, conv, waitForConv, stall);
signal state : ST_TYPE := init;
signal inputChecker, outputReadyVar : std_logic := '0';
signal numberOfMultiplies,numberOfFilters : integer := 0;
--signal convIndx, sentIndx, fIndx: integer;

begin
--filter <= filters(0);
process(clk)
variable tmpNum : integer;
variable tmpVal : std_logic_vector(31 downto 0);
variable tmpLogic : std_logic;
begin
    if (rising_edge(clk)) then
        case state is
            when init =>
                numberOfMultiplies <= 64 - filterSize + 1; 
                numberOfFilters <= 100;
                state <= waitForInput;
                maxval <= "10011100000000000000011010001110"; -- -99.99999
                outputReady <= outputReadyVar;
            when waitForInput =>
                if (inputReady = inputChecker) then
                    state <= waitForInput;
                else
                    inputChecker <= inputReady;
                    state <= conv;
                end if;
            when conv =>
                mulInputReady <= not mulInputReady;
                tmpNum := 64 - filterSize + 1 - numberOfMultiplies;
--                sentIndx <= tmpNum;
                subSent(0) <= sentence(tmpNum);
                subSent(1) <= sentence(tmpNum + 1);
                subSent(2) <= sentence(tmpNum + 2);
                if (filterSize = 4) then
                    subSent(3) <= sentence(tmpNum + 3);
                elsif (filterSize = 5) then
                    subSent(3) <= sentence(tmpNum + 3);
                    subSent(4) <= sentence(tmpNum + 4);
                end if;
                tmpNum := 100 - numberOfFilters;
--                fIndx <= tmpNum;
                filter <= filters(tmpNum);
                bias <= biases(tmpNum);
                state <= waitForConv;
            when waitForConv =>
                if (mulResultReady = mulResultReadyVar) then
                    state <= waitForConv;
                else
                    if (signed(maxVal) < signed(mulOut)) then
                        maxVal <= mulOut;
                        tmpVal := mulOut;
                    else
                        tmpVal := maxVal;
                    end if;
                    mulResultReadyVar <= mulResultReady;
                    if (numberOfMultiplies = 1 and numberOfFilters = 1) then
                        tmpLogic := not outputReadyVar;
                        outputReady <= tmpLogic;
                        outputReadyVar <= tmpLogic;
                        result(100 - numberOfFilters) <= tmpVal;
                        numberOfMultiplies <= 64 - filterSize;
                        numberOfFilters <= numberOfFilters - 1;
                        maxVal <= "10011100000000000000011010001110"; -- -99.99999
                        state <= stall;
    --                    state <= init;
                    elsif (numberOfMultiplies = 1) then
                        result(100 - numberOfFilters) <= tmpVal;
                        numberOfMultiplies <= 64 - filterSize;
                        numberOfFilters <= numberOfFilters - 1;
                        maxVal <= "10011100000000000000011010001110"; -- -99.99999
                        state <= conv;
                    else
                        numberOfMultiplies <= numberOfMultiplies - 1;
                        state <= conv;
                    end if;
                end if;
            when stall =>
                state <= stall;
            when others =>
                state <= init;
        end case;
    
    end if;
end process;

mul1: Conv_mul generic map (filterSize) port map (clk, mulInputReady, subSent, filter, bias, mulOut, mulResultReady);

end Behavioral;
