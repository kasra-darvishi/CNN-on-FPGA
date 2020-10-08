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
        addra1 : IN integer;
        dina1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        addra2 : IN integer;
        dina2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        addra3 : IN integer;
        dina3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        newSent : in std_logic;
        sentence : in STD_LOGIC_VECTOR(31 DOWNTO 0);
        sentAddr : in integer;
--        sentence : in sent_t;
        --filters1, filters2, filters3 : in filter3_t;
        biases1, biases2, biases3 : in word100_t;
        weight1, weight2: in word_ubt(299 downto 0);
        biases0 : in word_ubt(1 downto 0);
        prediction : out std_logic;
        outputReady : out std_logic;
        convOut : out word100_t);
end component;

signal clk, output: std_logic;

signal inputReady : std_logic := '0';
--signal sentence : sent_t;
signal newSent : std_logic := '0';
signal sentence : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal sentAddr : integer;
signal filters1, filters2, filters3 : filter3_t;
signal biases1, biases2, biases3 : word100_t;
signal prediction : std_logic;
signal outputReady : std_logic;
signal convOut : word100_t;
signal weight1, weight2: word_ubt(299 downto 0);
signal biases0 : word_ubt(1 downto 0);

signal addra1 : integer;
signal dina1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal addra2 : integer;
signal dina2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal addra3 : integer;
signal dina3 : STD_LOGIC_VECTOR(31 DOWNTO 0);
--signal clk: std_logic;

begin
UUT: CNN port map(clk, inputReady, addra1, dina1, addra2, dina2, addra3, dina3, newSent, sentence, sentAddr, biases1, biases2, biases3, weight1, weight2, biases0, prediction, outputReady, convOut);

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
file test_vector3 : text open read_mode is "Data02.csv";
file test_vector22 : text open read_mode is "Data11.csv";
file test_vector32 : text open read_mode is "Data12.csv";
file test_vector23 : text open read_mode is "Data21.csv";
file test_vector33 : text open read_mode is "Data22.csv";
file test_vector0 : text open read_mode is "Data0.csv";
file test_vector1 : text open read_mode is "Data1.csv";
variable row : line;
variable tmp: std_logic_vector(31 downto 0);
variable p1, p2 : integer := 0;
variable b1 : std_logic := '0';
begin
    newSent <= not newSent;
    l1: for i in 0 to 63 loop
        l2: for j in 0 to 299 loop
            readline(test_vector,row);
            read(row,tmp);
            sentence <= tmp;
            sentAddr <= i*300 + j;
--            sentence(i)(j) <= tmp;
            wait for 20 ns;
        end loop l2;
    end loop l1;
    newSent <= not newSent;
    wait for 30 ns;
    l3: for i in 0 to 99 loop
        l31: for j in 0 to 4 loop
            l4: for k in 0 to 299 loop
                if (j = 4)then
                    readline(test_vector23,row);
                    read(row,tmp);
                    addra3 <= i*5*300 + j*300 + k;
                    dina3 <= tmp;
--                    filters3(i)(j)(k) <= tmp;
                else
                    if (j = 3)then
                        readline(test_vector22,row);
                        read(row,tmp);
                        addra2 <= i*4*300 + j*300 + k;
                        dina2 <= tmp;
--                        filters2(i)(j)(k) <= tmp;
                        readline(test_vector23,row);
                        read(row,tmp);
                        addra3 <= i*5*300 + j*300 + k;
                        dina3 <= tmp;
--                        filters3(i)(j)(k) <= tmp;
                    else
                        readline(test_vector2,row);
                        read(row,tmp);
                        addra1 <= i*3*300 + j*300 + k;
                        dina1 <= tmp;
        --                filters1(i)(j)(k) <= tmp;
                        readline(test_vector22,row);
                        read(row,tmp);
                        addra2 <= i*4*300 + j*300 + k;
                        dina2 <= tmp;
--                        filters2(i)(j)(k) <= tmp;
                        readline(test_vector23,row);
                        read(row,tmp);
                        addra3 <= i*5*300 + j*300 + k;
                        dina3 <= tmp;
--                        filters3(i)(j)(k) <= tmp;
                    end if;
                end if;
                wait for 20 ns;
                if (k = 0) then
                    wait for 60 ns;
                end if;
            end loop l4;
        end loop l31;
--        l311: for j in 0 to 3 loop
--            l41: for k in 0 to 299 loop
--                readline(test_vector22,row);
--                read(row,tmp);
--                filters2(i)(j)(k) <= tmp;
--            end loop l41;
--        end loop l311;
--        l3111: for j in 0 to 4 loop
--            l411: for k in 0 to 299 loop
--                readline(test_vector23,row);
--                read(row,tmp);
--                filters3(i)(j)(k) <= tmp;
--            end loop l411;
--        end loop l3111;
    end loop l3;
    wait for 20 ns;
    l5: for i in 0 to 99 loop
        readline(test_vector3,row);
        read(row,tmp);
        biases1(i) <= tmp;
        readline(test_vector32,row);
        read(row,tmp);
        biases2(i) <= tmp;
        readline(test_vector33,row);
        read(row,tmp);
        biases3(i) <= tmp;
    end loop l5;
    l6: for i in 0 to 599 loop
        readline(test_vector0,row);
        read(row,tmp);
        if (b1 = '0') then
            weight1(p1) <= tmp;
            p1 := p1 + 1;
        else
            weight2(p2) <= tmp;
            p2 := p2 + 1;
        end if;
        b1 := not b1;
    end loop l6;
    l8: for i in 0 to 1 loop
        readline(test_vector1,row);
        read(row,tmp);
        biases0(i) <= tmp;
    end loop l8;
    inputReady <= not inputReady;
    wait for 20 ns;
    wait for 99999999 ms;
end process;


end Behavioral;