library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library xil_defaultlib;
use xil_defaultlib.myPack.all;


entity SoftMax_layer is
  Port (clk: in std_logic;
        inputReady : in std_logic;
        input : in word_ubt(299 downto 0);
        weight1, weight2: in word_ubt(299 downto 0);
        biases : in word_ubt(1 downto 0);
        prediction : out std_logic;
        outputReady : out std_logic);
end SoftMax_layer;

architecture Behavioral of SoftMax_layer is

component VecMul is
    Port (clk: in std_logic;
        inputReady : in std_logic;
        input, weight1, weight2 : in word_ubt(299 downto 0);
        biases : in word_ubt(1 downto 0);
        oval1, oval2 : out std_logic_vector(31 downto 0);
        outputReady : out std_logic);
end component;

signal oval1, oval2 : std_logic_vector(31 downto 0);
signal vmOutReady : std_logic;

begin

vm: VecMul port map (clk, inputReady, input, weight1, weight2, biases, oval1, oval2, vmOutReady);

end Behavioral;
