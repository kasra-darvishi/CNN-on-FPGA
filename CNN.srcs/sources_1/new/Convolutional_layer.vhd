library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library xil_defaultlib;
use xil_defaultlib.myPack.all;

entity Convolutional_layer is
  Port (clk: in std_logic;
        inputReady : in std_logic;
        sentence : in sent_t;
        filters1, filters2, filters3 : in filter3_t;
        biases1, biases2, biases3 : in word100_t;
        result : out word_t;
        outputReady : out std_logic;
        convOut : out word100_t);
end Convolutional_layer;

architecture Behavioral of Convolutional_layer is

component Convolve is
  Generic(filterSize: integer := 3);
  Port (clk: in std_logic;
        inputReady : in std_logic;
        sentence : in sent_t;
        filters : in filter3_t;
        biases : in word100_t;
        result : out word100_t;
        outputReady : out std_logic;
        convOut : out word100_t);
end component;

signal filterRes1, filterRes2, filterRes3 : word100_t;
signal fOutReady1, fOutReady2, fOutReady3 : std_logic;

begin

f1: Convolve generic map (3) port map (clk, inputReady, sentence, filters1, biases1, filterRes1, fOutReady1, convOut);
--f2: Convolve generic map (4) port map (clk, inputReady, sentence, filters2, biases2, filterRes2, fOutReady2, convOut);
--f3: Convolve generic map (5) port map (clk, inputReady, sentence, filters3, biases3, filterRes3, fOutReady3, convOut);


end Behavioral;
