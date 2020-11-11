library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library xil_defaultlib;
use xil_defaultlib.myPack.all;

entity Conv_mul is
  Generic(filterSize: integer := 3);
  Port (clk: in std_logic;
        inputReady : in std_logic;
        sentence, filter : in twod3_t;
        bias: in std_logic_vector(31 downto 0);
        result : out std_logic_vector(31 downto 0);
        outputReady : out std_logic);
end Conv_mul;

architecture Behavioral of Conv_mul is

component BaseMul is
  Port (clk : in std_logic;
        d1, d2 : in std_logic_vector(31 downto 0);
        out1 : out std_logic_vector(63 downto 0));
end component;

type ST_TYPE is (init, waitForInput, conv, wait5, sumState);
signal state : ST_TYPE := init;
signal inputChecker, outputReadyVar: std_logic := '0';
signal wordLength, filterWidth: integer := 0;
signal sum : std_logic_vector(31 downto 0);
signal indx0, indx1, indx2, indx3 : integer;
signal tval0, tval1 : std_logic_vector(31 downto 0);
signal tres1s : std_logic_vector(63 downto 0);
signal tss : signed(63 downto 0);
signal tmpNums, tmpNums2: std_logic_vector(31 downto 0);
signal d1, d2 : std_logic_vector(31 downto 0);
signal out1 : std_logic_vector(63 downto 0);
signal count: integer;

begin

process(clk)

variable tmpNum: std_logic_vector(31 downto 0);
variable tmpLogic : std_logic;
variable tres1 : std_logic_vector(63 downto 0);
variable ts : signed(63 downto 0);

begin
    if (rising_edge(clk)) then
        case state is
            when init =>
                wordLength <= 300 - 1; 
                filterWidth <= filterSize - 1;
                sum <= "00000000000000000000000000000000";
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
                tmpNum := std_logic_vector(ts(31 DOWNTO 0));
                tmpNum := std_logic_vector(signed(tmpNum) + signed(sum));
                sum <= tmpNum;
                if (wordLength = 0 and filterWidth = 0) then
                    tmpLogic := not outputReadyVar;
                    outputReady <= tmpLogic;
                    outputReadyVar <= tmpLogic;
                    tmpNum := std_logic_vector(signed(tmpNum) + signed(bias));
--                    tmpNum := tmpNum + bias;
                    if (tmpNum(31) = '1') then -- if negative
                        tmpNum := "00000000000000000000000000000000";
                    end if;
                    result <= tmpNum;
                    state <= init;
                else
                    if (wordLength = 0) then
                        wordLength <= 300 - 1;
                        filterWidth <= filterWidth - 1;
                    else
                        wordLength <= wordLength - 1;
                    end if;
                    state <= conv;
                end if;
                
            when conv =>
--                tres1 := std_logic_vector(signed(sentence(filterSize - filterWidth - 1)(300 - wordLength - 1)) * signed(filter(filterWidth)(wordLength)));
                d1 <= sentence(filterSize - filterWidth - 1)(300 - wordLength - 1);
                d2 <= filter(filterWidth)(wordLength);
                count <= 4;
                state <= wait5;
                
            when others =>
                state <= init;
        end case;
    
    end if;
end process;

bm: BaseMul port map(clk, d1, d2, out1);

end Behavioral;
