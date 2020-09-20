library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library xil_defaultlib;
use xil_defaultlib.myPack.all;


entity Convolve is
  Generic(filterSize: integer := 3);
  Port (clk: in std_logic;
        inputReady : in std_logic;
        sentence : in sent_t(63 downto 0)(299 downto 0);
        filters : in array_t(99 downto 0)(filterSize downto 0)(299 downto 0);
        biases : in word_t(99 downto 0);
        result : out word_t(99 downto 0);
        outputReady : out std_logic;
        convOut : word_t(61 downto 0));
end Convolve;

architecture Behavioral of Convolve is

component Conv_mul is
  Generic(filterSize: integer := 3);
  Port (clk: in std_logic;
        inputReady : in std_logic;
        sentence, filter : in sent_t(filterSize - 1 downto 0)(299 downto 0);
        bias: in real;
        result : out real;
        outputReady : out std_logic);
end component;

signal mulInputReady, mulResultReady, mulResultReadyVar : std_logic := '0';
signal subSent, filter : sent_t(filterSize - 1 downto 0)(299 downto 0);
signal bias, mulOut : real;

type ST_TYPE is (init, waitForInput, conv, waitForConv);
signal state : ST_TYPE := init;
signal inputChecker: std_logic := '0';
signal numberOfMultiplies : integer := 0;
--signal numberOfFilters : integer := 100;
signal numberOfFilters : integer := 1;

begin

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
                if (numberOfMultiplies = 0 and numberOfFilters = 0) then
                    state <= init;
                else
                    mulInputReady <= not mulInputReady;
                    tmpNum := 64 - filterSize + 1 - numberOfMultiplies;
                    subSent <= sentence(tmpNum to tmpNum + filterSize - 1);
                    filter <= filters(0)(0 to filterSize);
                    bias <= biases(0);
                    if (numberOfMultiplies = 0) then
                        numberOfMultiplies <= 64 - filterSize + 1;
                        numberOfFilters <= numberOfFilters - 1;
                    end if;
                    numberOfMultiplies <= numberOfMultiplies - 1;
                    state <= waitForConv;
                end if;
            when waitForConv =>
                if (mulResultReady = mulResultReadyVar) then
                    state <= waitForConv;
                else
                    state <= conv;
                end if;
            when others =>
                state <= init;
        end case;
    
    end if;
end process;

mul1: Conv_mul generic map (filterSize) port map (clk, mulInputReady, subSent, filter, bias, mulOut, mulResultReady);



end Behavioral;
