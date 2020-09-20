library ieee;
use ieee.std_logic_1164.all;

package mypack is
    type word_t is array(integer range<>) of real;
    type sent_t is array(integer range<>, integer range<>) of real;
    type array_t is array(integer range<>, integer range<>, integer range<>) of real;
end package;