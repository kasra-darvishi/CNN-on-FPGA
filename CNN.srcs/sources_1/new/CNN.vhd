library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library xil_defaultlib;
use xil_defaultlib.myPack.all;

entity CNN is
  Port (clk: in std_logic;
        inputReady : in std_logic;
        sentence : in sent_t;
        filters1, filters2, filters3 : in filter3_t;
        biases1, biases2, biases3 : in word100_t;
        prediction : out std_logic;
        outputReady : out std_logic;
        convOut : out word100_t);
end CNN;

architecture Behavioral of CNN is

component Convolutional_layer is
  Port (clk: in std_logic;
        inputReady : in std_logic;
        sentence : in sent_t;
        filters1, filters2, filters3 : in filter3_t;
        biases1, biases2, biases3 : in word100_t;
        result : out word_t;
        outputReady : out std_logic;
        convOut : out word100_t);
end component;

component SoftMax_layer is
  Port (clk: in std_logic;
        inputReady : in std_logic;
        input : in word_t;
        prediction : out std_logic;
        outputReady : out std_logic);
end component;

signal convRes : word_t;
signal convResReady : std_logic := '0';

begin

conv: Convolutional_layer port map (clk, inputReady, sentence, filters1, filters2, filters3, biases1, biases2, biases3, convRes, convResReady, convOut);
softmax: SoftMax_layer port map (clk, convResReady, convRes, prediction, outputReady);


end Behavioral;
