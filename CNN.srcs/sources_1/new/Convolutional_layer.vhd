library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library xil_defaultlib;
use xil_defaultlib.myPack.all;

entity Convolutional_layer is
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
        --filters1, filters2, filters3 : in filter3_t;
        biases1, biases2, biases3 : in word100_t;
        result : out word_ubt(299 downto 0);
        outputReady : out std_logic;
        convOut : out word100_t);
end Convolutional_layer;

architecture Behavioral of Convolutional_layer is

component Convolve_ctrl is
  Generic(filterSize: integer := 3);
  Port (clk: in std_logic;
        inputReady : in std_logic;
        addra : IN integer;
        dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        newSent : in std_logic;
        sentence : in STD_LOGIC_VECTOR(31 DOWNTO 0);
        sentAddr : in integer;
        --filters : in filter3_t;
        biases : in word100_t;
        result : out word_ubt(99 downto 0);
        outputReady : out std_logic);
end component;

signal filterRes1, filterRes2, filterRes3 : word_ubt(99 downto 0);
signal fOutReady1, fOutReady2, fOutReady3 : std_logic;

begin

f1: Convolve_ctrl generic map (3) port map (clk, inputReady, addra1, dina1, newSent, sentence, sentAddr, biases1, filterRes1, fOutReady1);
f2: Convolve_ctrl generic map (4) port map (clk, inputReady, addra2, dina2, newSent, sentence, sentAddr, biases2, filterRes2, fOutReady2);
f3: Convolve_ctrl generic map (5) port map (clk, inputReady, addra3, dina3, newSent, sentence, sentAddr, biases3, filterRes3, fOutReady3);

outputReady <= fOutReady1 and fOutReady2 and fOutReady3;
result <= filterRes3 & filterRes2 & filterRes1;

end Behavioral;
