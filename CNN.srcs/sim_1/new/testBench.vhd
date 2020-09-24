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
        sentence : in sent_t;
        filters1, filters2, filters3 : in filter3_t;
        biases1, biases2, biases3 : in word100_t;
        prediction : out std_logic;
        outputReady : out std_logic;
        convOut : out word100_t);
end component;

signal clk, output: std_logic;

signal inputReady : std_logic := '0';
signal sentence : sent_t;
signal filters1, filters2, filters3 : filter3_t;
signal biases1, biases2, biases3 : word100_t;
signal prediction : std_logic;
signal outputReady : std_logic;
signal convOut : word100_t;
--signal clk: std_logic;

begin
UUT: CNN port map(clk, inputReady, sentence, filters1, filters2, filters3, biases1, biases2, biases3, prediction, outputReady, convOut);


clk_process :process
begin
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
end process;

p_read : process
file test_vector : text open read_mode is "Data00.csv";
file test_vector2 : text open read_mode is "Data01.csv";
variable row : line;
variable tmp: real;
begin
    l1: for i in 0 to 63 loop
        l2: for j in 0 to 299 loop
            readline(test_vector,row);
            read(row,tmp);
            sentence(i)(j) <= tmp;
        end loop l2;
    end loop l1;
    wait for 20 ns;
    l3: for i in 0 to 2 loop
        l4: for j in 0 to 299 loop
            readline(test_vector2,row);
            read(row,tmp);
            filters1(0)(i)(j) <= tmp;
        end loop l4;
    end loop l3;
    wait for 20 ns;
    inputReady <= not inputReady;
    wait for 20 ns;
    wait for 99999999 us;
end process;


end Behavioral;