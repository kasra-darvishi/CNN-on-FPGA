library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library xil_defaultlib;
use xil_defaultlib.myPack.all;

entity CNN is
  Port (clk: in std_logic;
        inputReady : in std_logic;
        addra : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        sentence : in sent_t;
        filters1, filters2, filters3 : in filter3_t;
        biases1, biases2, biases3 : in word100_t;
        weight1, weight2: in word_ubt(299 downto 0);
        biases0 : in word_ubt(1 downto 0);
        prediction : out std_logic;
        outputReady : out std_logic;
        convOut : out word100_t);
end CNN;

architecture Behavioral of CNN is

component Convolutional_layer is
  Port (clk: in std_logic;
        inputReady : in std_logic;
        addra : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        sentence : in sent_t;
        filters1, filters2, filters3 : in filter3_t;
        biases1, biases2, biases3 : in word100_t;
        result : out word_ubt(299 downto 0);
        outputReady : out std_logic;
        convOut : out word100_t);
end component;

component SoftMax_layer is
  Port (clk: in std_logic;
        inputReady : in std_logic;
        input : in word_ubt(299 downto 0);
        weight1, weight2: in word_ubt(299 downto 0);
        biases : in word_ubt(1 downto 0);
        prediction : out std_logic;
        outputReady : out std_logic);
end component;

signal convRes : word_ubt(299 downto 0);
signal convResReady : std_logic := '0';

begin

conv: Convolutional_layer port map (clk, inputReady, addra, dina, sentence, filters1, filters2, filters3, biases1, biases2, biases3, convRes, convResReady, convOut);
softmax: SoftMax_layer port map (clk, convResReady, convRes, weight1, weight2, biases0, prediction, outputReady);

end Behavioral;
