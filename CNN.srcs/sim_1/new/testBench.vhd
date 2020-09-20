library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
library xil_defaultlib;
use xil_defaultlib.myPack.all;

entity testBench is
--  Port ( );
end testBench;

architecture Behavioral of testBench is

component CNN is
  Port (clk: in std_logic;
        inputReady : in std_logic;
        sentence : in sent_t(63 downto 0, 299 downto 0);
        prediction : out std_logic;
        outputReady : out std_logic);
end component;

signal clk, output: std_logic;

signal inputReady : std_logic;
signal sentence : sent_t(63 downto 0,299 downto 0);
signal prediction : std_logic;
signal outputReady : std_logic;
--signal clk: std_logic;

begin
UUT: CNN port map(clk, inputReady, sentence, prediction, outputReady);


clk_process :process
begin
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
end process;

p_read : process
file test_vector : text open read_mode is "Data00.csv";
variable row : line;
variable tmp: real;
begin
--    readline(test_vector,row);
--    wait for 20 ns;
--    read(row,tmp);
--    wait for 20 ns;
--    whatstheval <= tmp;


    l1: for i in 0 to 63 loop
        l2: for j in 0 to 299 loop
            readline(test_vector,row);
            read(row,tmp);
            sentence(i,j) <= tmp;
        end loop l2;
    end loop l1;
    wait for 20 ns;
end process;


end Behavioral;