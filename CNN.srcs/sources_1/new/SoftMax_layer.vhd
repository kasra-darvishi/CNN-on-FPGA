library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library xil_defaultlib;
use xil_defaultlib.myPack.all;


entity SoftMax_layer is
  Port (clk: in std_logic;
        inputReady : in std_logic;
        input : in word_t;
        prediction : out std_logic;
        outputReady : out std_logic);
end SoftMax_layer;

architecture Behavioral of SoftMax_layer is

begin


end Behavioral;
