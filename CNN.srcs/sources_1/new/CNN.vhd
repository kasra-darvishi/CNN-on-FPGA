library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.myPack.all;

entity CNN is
  Port (inputReady : in std_logic;
        sentence : in sent_t(63 downto 0)(299 downto 0);
        prediction : out std_logic;
        outputReady : out std_logic);
end CNN;

architecture Behavioral of CNN is

component Convolutional_layer is
  Port (inputReady : in std_logic;
        sentence : in sent_t(63 downto 0)(299 downto 0);
        result : out word_t(299 downto 0);
        outputReady : out std_logic);
end component;

component SoftMax_layer is
  Port (inputReady : in std_logic;
        input : in word_t(299 downto 0);
        prediction : out std_logic;
        outputReady : out std_logic);
end component;

begin




end Behavioral;
