library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library xil_defaultlib;
use xil_defaultlib.myPack.all;

entity VecMul is
    Port (clk: in std_logic;
        inputReady : in std_logic;
        input, weight1, weight2 : in word_ubt(299 downto 0);
        biases : in word_ubt(1 downto 0);
        oval1, oval2 : out std_logic_vector(31 downto 0);
        outputReady : out std_logic);
end VecMul;

architecture Behavioral of VecMul is

component BaseMul is
  Port (clk : in std_logic;
        d1, d2 : in std_logic_vector(31 downto 0);
        out1 : out std_logic_vector(63 downto 0));
end component;

type ST_TYPE is (init, waitForInput, conv, wait5, sumState);
signal state : ST_TYPE := init;
signal inputChecker, outputReadyVar: std_logic := '0';
signal wordLength : integer := 0;
signal sum1, sum2, tval1, tval2, tres, tval12, tval22, tres2 : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
signal wtfSig : std_logic := '0';
signal d1, d2, d12, d22 : std_logic_vector(31 downto 0);
signal out1, out12 : std_logic_vector(63 downto 0);
signal count: integer;

begin

process(clk)

variable tmpNum1, tmpNum2, tmp1,tmp2 : std_logic_vector(31 downto 0);
variable tmpLogic : std_logic;
variable tres1 : std_logic_vector(63 downto 0);
variable ts, ts2 : signed(63 downto 0);

begin
    if (rising_edge(clk)) then
        case state is
            when init =>
                wordLength <= 300 - 1; 
                sum1 <= "00000000000000000000000000000000";
                sum2 <= "00000000000000000000000000000000";
                state <= waitForInput;
                outputReady <= outputReadyVar;
                
            when waitForInput =>
                if (inputReady = inputChecker) then
                    state <= waitForInput;
                else
                    inputChecker <= inputReady;
                    state <= conv;
                end if;
                
            when wait5 =>
                if count > 0 then
                    count <= count -1;
                else
                    state <= sumState;
                end if;
            
            when sumState =>
                ts := shift_right(signed(out1),24);
                tmp1 := std_logic_vector(ts(31 DOWNTO 0));
                tmpNum1 := std_logic_vector(signed(tmp1) + signed(sum1));
                
                ts2 := shift_right(signed(out12),24);
                tmp2 := std_logic_vector(ts2(31 DOWNTO 0));
                tmpNum2 := std_logic_vector(signed(tmp2) + signed(sum2));
                
                sum1 <= tmpNum1;
                sum2 <= tmpNum2;
                if (wordLength = 0) then
                    tmpLogic := not outputReadyVar;
                    outputReady <= tmpLogic;
                    outputReadyVar <= tmpLogic;
                    tmpNum1 := std_logic_vector(signed(tmpNum1) + signed(biases(0)));
                    tmpNum2 := std_logic_vector(signed(tmpNum2) + signed(biases(1)));
                    oval1 <= tmpNum1;
                    oval2 <= tmpNum2;
                    state <= init;
                else
                    wordLength <= wordLength - 1;
                    state <= conv;
                end if;
            
            when conv =>
--                tres1 := std_logic_vector(signed(input(299 - wordLength)) * signed(weight1(299 - wordLength)));
--                tres1 := std_logic_vector(signed(input(299 - wordLength)) * signed(weight2(299 - wordLength)));
                d1 <= input(299 - wordLength);
                d2 <= weight1(299 - wordLength);
                d12 <= input(299 - wordLength);
                d22 <= weight2(299 - wordLength);
                count <= 4;
                state <= wait5;

            when others =>
                state <= init;
        end case;
    end if;
end process;

bm: BaseMul port map(clk, d1, d2, out1);
bm2: BaseMul port map(clk, d12, d22, out12);

end Behavioral;
