library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.myPack.all;


entity Convolve is
  Generic(filterSize: integer := 3);
  Port (inputReady : in std_logic;
        sentence : in sent_t(63 downto 0)(299 downto 0);
        result : out word_t(99 downto 0);
        outputReady : out std_logic);
end Convolve;

architecture Behavioral of Convolve is

signal filters : array_t(99 downto 0)(filterSize downto 0)(299 downto 0);
signal intialized: boolean := false;

begin

process(clk)
begin
    if (rising_edge(clk)) then
    
    end if;
end process;


end Behavioral;
