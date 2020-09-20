library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library xil_defaultlib;
use xil_defaultlib.myPack.all;

entity Convolutional_layer is
  Port (inputReady : in std_logic;
        sentence : in sent_t(63 downto 0, 299 downto 0);
        result : out word_t(299 downto 0);
        outputReady : out std_logic);
end Convolutional_layer;

architecture Behavioral of Convolutional_layer is

component Convolve is
  Generic(filterSize: integer := 3);
  Port (inputReady : in std_logic;
        sentence : in sent_t(63 downto 0, 299 downto 0);
        result : out word_t(99 downto 0);
        outputReady : out std_logic);
end component;

signal filterRes1, filterRes2, filterRes3 : word_t(99 downto 0);
signal fOutReady1, fOutReady2, fOutReady3 : std_logic;

begin

f1: Convolve generic map (3) port map (inputReady, sentence, filterRes1, fOutReady1);
f2: Convolve generic map (4) port map (inputReady, sentence, filterRes2, fOutReady2);
f3: Convolve generic map (5) port map (inputReady, sentence, filterRes3, fOutReady3);


end Behavioral;
