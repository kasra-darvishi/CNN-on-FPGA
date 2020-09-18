package mypack is
    type word_t is array(integer range<>) of std_logic_vector(63 downto 0);
    type sent_t is array(integer range<>) of word_t;
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity SoftMax_layer is
  Port (inputReady : in std_logic;
        sentence : in sent_t(63 downto 0)(99 downto 0);
        prediction : out std_logic;
        outputReady : out std_logic);
end SoftMax_layer;

architecture Behavioral of SoftMax_layer is

begin


end Behavioral;
