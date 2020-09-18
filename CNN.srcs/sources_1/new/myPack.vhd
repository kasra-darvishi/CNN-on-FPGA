library ieee;
use ieee.std_logic_1164.all;

package mypack is
    type word_t is array(integer range<>) of real;
    type sent_t is array(integer range<>) of word_t;
    type array_t is array(integer range<>) of sent_t;
end package;