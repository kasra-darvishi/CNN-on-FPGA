library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library xil_defaultlib;
use xil_defaultlib.myPack.all;


entity Convolve is
  Generic(filterSize: integer := 3);
  Port (inputReady : in std_logic;
        sentence : in sent_t(63 downto 0, 299 downto 0);
        result : out word_t(99 downto 0);
        outputReady : out std_logic);
end Convolve;

architecture Behavioral of Convolve is

component Conv_mul is
  Generic(filterSize: integer := 3);
  Port (inputReady : in std_logic;
        sentence, filter : in sent_t(filterSize - 1 downto 0, 299 downto 0);
        bias: in real;
        result : out real;
        outputReady : out std_logic);
end component;

signal filters : array_t(99 downto 0, filterSize downto 0, 299 downto 0);
signal biases : word_t(99 downto 0);
signal mulInputReady, mulResultReady : std_logic := '0';
signal subSent, filter : sent_t(filterSize - 1 downto 0, 299 downto 0);
signal bias, mulOut : real;

type ST_TYPE is (init, waitForInput, conv);
signal state : ST_TYPE := init;
signal clk: std_logic;

begin

process(clk)
variable numberOfMultiplies : integer := 0;
variable numberOfFilters : integer := 100;
begin
    if (rising_edge(clk)) then
        case state is
            when init =>
                numberOfMultiplies := 0; 
                state <= waitForInput;
            when waitForInput =>
                numberOfMultiplies := 64 - filterSize + 1;
                state <= conv;
            when conv =>
                if (numberOfMultiplies = 0 and numberOfFilters = 0) then
                    state <= waitForInput;
                else
                    if (numberOfMultiplies = 0) then
                        numberOfMultiplies := 64 - filterSize + 1;
                        numberOfFilters := numberOfFilters - 1;
                    end if;
                    
                    numberOfMultiplies := numberOfMultiplies - 1;
                    state <= conv;
                end if;
            when others =>
                state <= waitForInput;
        end case;
    
    end if;
end process;

mul1: Conv_mul generic map (filterSize) port map (mulInputReady, subSent, filter, bias, mulOut, mulResultReady);

end Behavioral;
