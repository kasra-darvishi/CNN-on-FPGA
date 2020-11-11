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

component Main is
     Port (clk : in std_logic;
        newIn: in std_logic;
        inVec: in std_logic_vector(31 downto 0);
        newOut: out std_logic;
        outVec: out std_logic_vector(31 downto 0));
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
Signal    newIn:  std_logic;
Signal    inVec:  std_logic_vector(31 downto 0);
Signal    newOut:  std_logic;
Signal    outVec:  std_logic_vector(31 downto 0);
type ST_TYPE is (init, getSentnc, getfilt1, getfilt2, getfilt3, getbias1, getbias2, getbias3, getweights, getbias0, waitForCNN);
signal state2 : ST_TYPE := init;
signal b1_s : std_logic := '0';
signal p1_s, p2_s : integer := 0;

begin
--UUT: CNN port map(clk, inputReady, addra1, dina1, addra2, dina2, addra3, dina3, newSent, sentence, sentAddr, biases1, biases2, biases3, weight1, weight2, biases0, prediction, outputReady, convOut);
m: main port map (clk, newIn, inVec, newOut, outVec); 

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
    newIn <= '0';
    wait for 20ns;
    state2 <= getSentnc;
    l1: for i in 0 to 63 loop
        l2: for j in 0 to 299 loop
            readline(test_vector,row);
            read(row,tmp);
            sentence <= tmp;
            sentAddr <= i*300 + j;
            newIn <= not newIn;
            inVec <= tmp;
--            sentence(i)(j) <= tmp;
            wait for 20 ns;
        end loop l2;
    end loop l1;
    state2 <= getfilt1;
    l3: for i in 0 to 99 loop
        l31: for j in 0 to 2 loop
            l4: for k in 0 to 299 loop
                readline(test_vector2,row);
                read(row,tmp);
                addra1 <= i*3*300 + j*300 + k;
                dina1 <= tmp;
                newIn <= not newIn;
                inVec <= tmp;
                wait for 20 ns;
                if (k = 0) then
                    wait for 60 ns;
                end if;
            end loop l4;
        end loop l31;
    end loop l3;
    state2 <= getfilt2;
    l3f2: for i in 0 to 99 loop
        l31f2: for j in 0 to 3 loop
            l4f2: for k in 0 to 299 loop
                readline(test_vector22,row);
                read(row,tmp);
                addra2 <= i*4*300 + j*300 + k;
                dina2 <= tmp;
                newIn <= not newIn;
                inVec <= tmp;
                wait for 20 ns;
                if (k = 0) then
                    wait for 60 ns;
                end if;
            end loop l4f2;
        end loop l31f2;
    end loop l3f2;
    state2 <= getfilt3;
    l3f3: for i in 0 to 99 loop
        l31f3: for j in 0 to 4 loop
            l4f3: for k in 0 to 299 loop
                readline(test_vector23,row);
                read(row,tmp);
                addra3 <= i*5*300 + j*300 + k;
                dina3 <= tmp;
                newIn <= not newIn;
                inVec <= tmp;
                wait for 20 ns;
                if (k = 0) then
                    wait for 60 ns;
                end if;
            end loop l4f3;
        end loop l31f3;
    end loop l3f3;
    state2 <= getbias1;
    l5: for i in 0 to 99 loop
        readline(test_vector3,row);
        read(row,tmp);
        biases1(i) <= tmp;
        newIn <= not newIn;
        inVec <= tmp;
        wait for 20 ns;
    end loop l5;
    state2 <= getbias2;
    l52: for i in 0 to 99 loop
        readline(test_vector32,row);
        read(row,tmp);
        biases2(i) <= tmp;
        newIn <= not newIn;
        inVec <= tmp;
        wait for 20 ns;
    end loop l52;
    state2 <= getbias3;
    l53: for i in 0 to 99 loop
        readline(test_vector33,row);
        read(row,tmp);
        biases3(i) <= tmp;
        newIn <= not newIn;
        inVec <= tmp;
        wait for 20 ns;
    end loop l53;
    state2 <= getweights;
    l6: for i in 0 to 599 loop
        readline(test_vector0,row);
        read(row,tmp);
        if (b1 = '0') then
            weight1(p1) <= tmp;
            newIn <= not newIn;
            inVec <= tmp;
            weight1(p1) <= tmp;
            p1 := p1 + 1;
            p1_s <= p1;
            wait for 20 ns;
        else
            weight2(p2) <= tmp;
            newIn <= not newIn;
            inVec <= tmp;
            weight2(p2) <= tmp;
            p2 := p2 + 1;
            p2_s <= p2;
            wait for 20 ns;
        end if;
        b1 := not b1;
        b1_s <= b1;
    end loop l6;
    state2 <= getbias0;
    l8: for i in 0 to 1 loop
        readline(test_vector1,row);
        read(row,tmp);
        biases0(i) <= tmp;
        newIn <= not newIn;
            inVec <= tmp;
            wait for 20 ns;
    end loop l8;
    state2 <= waitForCNN;
    inputReady <= not inputReady;
    wait for 20 ns;
    wait for 99999999 ms;
end process;


end Behavioral;