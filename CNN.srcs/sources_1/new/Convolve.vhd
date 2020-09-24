library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library xil_defaultlib;
use xil_defaultlib.myPack.all;


entity Convolve is
  Generic(filterSize: integer := 3);
  Port (clk: in std_logic;
        inputReady : in std_logic;
        sentence : in sent_t;
        filters : in filter3_t;
        biases : in word100_t;
        result : out word100_t;
        outputReady : out std_logic;
        convOut : out word100_t);
end Convolve;

architecture Behavioral of Convolve is

component Conv_mul is
  Generic(filterSize: integer := 3);
  Port (clk: in std_logic;
        inputReady : in std_logic;
        sentence, filter : in twod3_t;
        bias: in real;
        result : out real;
        outputReady : out std_logic);
end component;

signal mulInputReady, mulResultReady, mulResultReadyVar : std_logic := '0';
signal subSent, filter : twod3_t;
signal bias, mulOut : real;

type ST_TYPE is (init, waitForInput, conv, waitForConv, stall);
signal state : ST_TYPE := init;
signal inputChecker: std_logic := '0';
signal numberOfMultiplies : integer := 0;
--signal numberOfFilters : integer := 99;
signal numberOfFilters : integer := 0;
signal convIndx, sentIndx: integer;

begin
--filter <= filters(0);
process(clk)
variable tmpNum : integer;
begin
    if (rising_edge(clk)) then
        case state is
            when init =>
                numberOfMultiplies <= 64 - filterSize + 1; 
                numberOfFilters <= 1;
                state <= waitForInput;
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
                sentIndx <= tmpNum;
                subSent(0) <= sentence(tmpNum);
                subSent(1) <= sentence(tmpNum + 1);
                subSent(2) <= sentence(tmpNum + 2);
                if (filterSize = 4) then
                    subSent(3) <= sentence(tmpNum + 3);
                elsif (filterSize = 5) then
                    subSent(3) <= sentence(tmpNum + 3);
                    subSent(4) <= sentence(tmpNum + 4);
                end if;
                filter <= filters(0);
--                filter <= filters(100 - numberOfFilters);
                bias <= biases(100 - numberOfFilters);
                if (numberOfMultiplies = 1 and numberOfFilters = 1) then
                    state <= stall;
--                    state <= init;
                else
                    if (numberOfMultiplies = 1) then
                        numberOfMultiplies <= 64 - filterSize + 1;
                        numberOfFilters <= numberOfFilters - 1;
                    else
                        numberOfMultiplies <= numberOfMultiplies - 1;
                    end if;
                    state <= waitForConv;
                end if;
            when waitForConv =>
                if (mulResultReady = mulResultReadyVar) then
                    state <= waitForConv;
                else
                    mulResultReadyVar <= mulResultReady;
                    tmpNum := 64 - filterSize + 1 - numberOfMultiplies - 1;
                    convIndx <= tmpNum;
                    convOut(tmpNum) <= mulOut;
                    state <= conv;
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
