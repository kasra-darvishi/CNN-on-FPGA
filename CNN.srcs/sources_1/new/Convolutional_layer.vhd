library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.myPack.all;

entity Convolutional_layer is
  Port (inputReady : in std_logic;
        sentence : in sent_t(63 downto 0)(299 downto 0);
        result : out word_t(299 downto 0);
        outputReady : out std_logic);
end Convolutional_layer;

architecture Behavioral of Convolutional_layer is

component Convolve is
  Generic(filterSize: integer := 3);
  Port (inputReady : in std_logic;
        sentence : in sent_t(63 downto 0)(299 downto 0);
        result : out word_t(99 downto 0);
        outputReady : out std_logic);
end component;

begin


end Behavioral;
