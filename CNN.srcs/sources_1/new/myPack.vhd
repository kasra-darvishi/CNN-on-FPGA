library ieee;
use ieee.std_logic_1164.all;

package mypack is
    type word_t is array(299 downto 0) of std_logic_vector(31 downto 0);
    type word100_t is array(99 downto 0) of std_logic_vector(31 downto 0);
    type word_ubt is array(integer range<>) of std_logic_vector(31 downto 0);
    type sent_t is array(63 downto 0) of word_t;
    type twod1_t is array(2 downto 0) of word_t;
    type twod2_t is array(3 downto 0) of word_t;
    type twod3_t is array(4 downto 0) of word_t;
    type filter1_t is array(99 downto 0) of twod1_t;
    type filter2_t is array(99 downto 0) of twod2_t;
    type filter3_t is array(99 downto 0) of twod3_t;
end package;