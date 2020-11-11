library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity BaseMul is
  Port (clk : in std_logic;
        d1, d2 : in std_logic_vector(31 downto 0);
        out1 : out std_logic_vector(63 downto 0));
end BaseMul;

architecture Behavioral of BaseMul is
signal p1, p2, p3, p4 : std_logic_vector(63 downto 0);

begin

process(clk)
begin

if (rising_edge(clk)) then
    p1 <= std_logic_vector(signed(d1) * signed(d2));
    p2 <= p1;
    p3 <= p2;
    p4 <= p3;
    out1 <= p4;
end if;

end process;


end Behavioral;
