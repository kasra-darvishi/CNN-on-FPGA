library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library xil_defaultlib;
use xil_defaultlib.mypack.all;


entity genMem is
Generic(memSize: integer := 3;
        len: integer := 17);
port(clk: in std_logic; 
     wr: in std_logic; 
     addr: in std_logic_vector(17 downto 0); 
     data_in: in std_logic_vector(31 downto 0); 
     data_out: out std_logic_vector(31 downto 0)
);
end genMem;

architecture Behavioral of genMem is

signal RAM: word_ubt( 0 to (memSize-1));                     

begin

process(clk)
begin
    if(rising_edge(clk)) then
        if(wr='1') then 
        RAM(to_integer(unsigned(addr(len downto 0)))) <= data_in;
        end if;
    end if;
end process;

data_out <= RAM(to_integer(unsigned(addr(len downto 0))));
 
 
end Behavioral;