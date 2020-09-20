library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library xil_defaultlib;
use xil_defaultlib.myPack.all;

entity Convolutional_layer is
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
end Convolutional_layer;

architecture Behavioral of Convolutional_layer is

component Convolve is
  Generic(filterSize: integer := 3);
  Port (clk: in std_logic;
        inputReady : in std_logic;
        sentence : in sent_t(63 downto 0)(299 downto 0);
        filters : in array_t(99 downto 0)(filterSize downto 0)(299 downto 0);
        biases : in word_t(99 downto 0);
        result : out word_t(99 downto 0);
        outputReady : out std_logic;
        convOut : word_t(61 downto 0));
end component;

signal filterRes1, filterRes2, filterRes3 : word_t(99 downto 0);
signal fOutReady1, fOutReady2, fOutReady3 : std_logic;

begin

f1: Convolve generic map (3) port map (clk, inputReady, sentence, filters1, biases1, filterRes1, fOutReady1, convOut);
--f2: Convolve generic map (4) port map (clk, inputReady, sentence, filters2, biases2, filterRes2, fOutReady2, convOut);
--f3: Convolve generic map (5) port map (clk, inputReady, sentence, filters3, biases3, filterRes3, fOutReady3, convOut);


end Behavioral;
