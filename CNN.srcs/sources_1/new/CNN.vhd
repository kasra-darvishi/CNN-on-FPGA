library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library xil_defaultlib;
use xil_defaultlib.myPack.all;

entity CNN is
  Port (clk: in std_logic;
        inputReady : in std_logic;
        sentence : in sent_t(63 downto 0)(299 downto 0);
        filters1 : in array_t(99 downto 0)(filterSize downto 0)(299 downto 0);
        filters2 : in array_t(99 downto 0)(filterSize downto 0)(299 downto 0);
        filters3 : in array_t(99 downto 0)(filterSize downto 0)(299 downto 0);
        biases1 : in word_t(99 downto 0);
        biases2 : in word_t(99 downto 0);
        biases3 : in word_t(99 downto 0);
        prediction : out std_logic;
        outputReady : out std_logic;
        convOut : word_t(61 downto 0));
end CNN;

architecture Behavioral of CNN is

component Convolutional_layer is
  Port (clk: in std_logic;
        inputReady : in std_logic;
        sentence : in sent_t(63 downto 0)(299 downto 0);
        filters1 : in array_t(99 downto 0)(filterSize downto 0)(299 downto 0);
        filters2 : in array_t(99 downto 0)(filterSize downto 0)(299 downto 0);
        filters3 : in array_t(99 downto 0)(filterSize downto 0)(299 downto 0);
        biases1 : in word_t(99 downto 0);
        biases2 : in word_t(99 downto 0);
        biases3 : in word_t(99 downto 0);
        result : out word_t(299 downto 0);
        outputReady : out std_logic;
        convOut : word_t(61 downto 0));
end component;

component SoftMax_layer is
  Port (clk: in std_logic;
        inputReady : in std_logic;
        input : in word_t(299 downto 0);
        prediction : out std_logic;
        outputReady : out std_logic);
end component;

signal convRes : word_t(299 downto 0);
signal convResReady : std_logic := '0';

begin

conv: Convolutional_layer port map (clk, inputReady, sentence, filters1, filters2, filters3, biases1, biases2, biases3, convRes, convResReady, convOut);
softmax: SoftMax_layer port map (clk, convResReady, convRes, prediction, outputReady);


end Behavioral;
