library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.myPack.all;

entity Conv_mul is
  Generic(filterSize: integer := 3);
  Port (inputReady : in std_logic;
        sentence, filter : in sent_t(filterSize - 1 downto 0)(299 downto 0);
        bias: in real;
        result : out real;
        outputReady : out std_logic);
end Conv_mul;

architecture Behavioral of Conv_mul is

begin


end Behavioral;
