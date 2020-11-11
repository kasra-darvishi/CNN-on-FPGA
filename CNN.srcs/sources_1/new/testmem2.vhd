library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library xil_defaultlib;
use xil_defaultlib.mypack.all;


entity testRAM2 is
port(clk: in std_logic; 
     wr: in std_logic; 
     addr: in std_logic_vector(14 DOWNTO 0); 
     data_in: in std_logic_vector(31 downto 0); 
     data_out: out std_logic_vector(31 downto 0)
);
end testRAM2;

architecture Behavioral of testRAM2 is

signal RAM: word_ubt( 0 to (19199));             

begin

process(clk)
begin
    if(rising_edge(clk)) then
        if(wr='1') then 
        RAM(to_integer(unsigned(addr))) <= data_in;
        end if;
    end if;
end process;

data_out <= RAM(to_integer(unsigned(addr)));
 
 
end Behavioral;