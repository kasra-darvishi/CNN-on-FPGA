library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all;
library xil_defaultlib;
use xil_defaultlib.myPack.all;


entity Convolve is
  Generic(filterSize: integer := 3);
  Port (clk: in std_logic;
        inputReady : in std_logic;
        addra : IN integer;
        dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        sentence : in sent_t;
        --filters : in filter3_t;
        biases : in word100_t;
        result : out word_ubt(99 downto 0);
        outputReady : out std_logic);
end Convolve;

architecture Behavioral of Convolve is

component Conv_mul is
  Generic(filterSize: integer := 3);
  Port (clk: in std_logic;
        inputReady : in std_logic;
        sentence, filter : in twod3_t;
        bias: in std_logic_vector(31 downto 0);
        result : out std_logic_vector(31 downto 0);
        outputReady : out std_logic);
end component;

COMPONENT filter_mem
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

COMPONENT testRAM is
port(clk: in std_logic; 
     wr: in std_logic; 
     addr: in std_logic_vector(17 downto 0); 
     data_in: in std_logic_vector(31 downto 0); 
     data_out: out std_logic_vector(31 downto 0)
);
end COMPONENT;


signal memEnable : std_logic := '1';
signal memWriteEn : STD_LOGIC_VECTOR(0 DOWNTO 0) := "1";
signal memAddr : STD_LOGIC_VECTOR(17 DOWNTO 0);
signal dinaSig : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal douta : STD_LOGIC_VECTOR(31 DOWNTO 0);

signal mulInputReady, mulResultReady, mulResultReadyVar : std_logic := '0';
signal subSent, filter : twod3_t;
signal bias, mulOut, maxVal : std_logic_vector(31 downto 0);

type ST_TYPE is (init, waitForInput, conv, waitForConv, stall, loadData, readFilter, twoClockWait);
signal state : ST_TYPE := init;
signal inputChecker, outputReadyVar : std_logic := '0';
signal numberOfMultiplies,numberOfFilters : integer := 0;
--signal convIndx, sentIndx, fIndx: integer;

signal p1, p2, op1, op2, counter : integer := 0;

begin

process(clk)
variable tmpNum : integer;
variable tmpVal : std_logic_vector(31 downto 0);
variable tmpAddrs : std_logic_vector(17 downto 0);
variable tmpLogic : std_logic;
begin
    if (rising_edge(clk)) then
        case state is
            when init =>
                memAddr <= std_logic_vector(to_unsigned(addra, memAddr'length));
                dinaSig <= dina;
                numberOfMultiplies <= 64 - filterSize + 1; 
                numberOfFilters <= 100;
                state <= waitForInput;
                memWriteEn <= "1";
                maxval <= "10011100000000000000011010001110"; -- -99.99999
                outputReady <= outputReadyVar;
            when waitForInput =>
                if (inputReady = inputChecker) then
                    state <= waitForInput;
                    memAddr <= std_logic_vector(to_unsigned(addra, memAddr'length));
                    dinaSig <= dina;
                    memWriteEn <= "1";
                else
                    memWriteEn <= "0";
                    inputChecker <= inputReady;
                    state <= readFilter;
                end if;
            when readFilter =>
                filter(op1)(op2) <= douta;
                op1 <= p1;
                op2 <= p2;
                if (p1 = filterSize and p2 = 0) then
                    p1 <= 0;
                    p2 <= 0;
                    op1 <= 0;
                    op2 <= 0;
                    state <= conv;
                else
                    state <= twoClockWait;
                    tmpNum := (100 - numberOfFilters)*filterSize*300;
                    memAddr <= std_logic_vector(to_unsigned(tmpNum + p1*300 + p2, memAddr'length));
--                    filter(p1)(p2) <= douta;
                    if (p2 = 299)then
                        p1 <= p1 + 1;
                        p2 <= 0;
                    else
                        p2 <= p2 + 1;
                    end if;
                end if;
                
            when conv =>
                mulInputReady <= not mulInputReady;
                tmpNum := 64 - filterSize + 1 - numberOfMultiplies;
--                sentIndx <= tmpNum;
                subSent(0) <= sentence(tmpNum);
                subSent(1) <= sentence(tmpNum + 1);
                subSent(2) <= sentence(tmpNum + 2);
                if (filterSize = 4) then
                    subSent(3) <= sentence(tmpNum + 3);
                elsif (filterSize = 5) then
                    subSent(3) <= sentence(tmpNum + 3);
                    subSent(4) <= sentence(tmpNum + 4);
                end if;
                tmpNum := 100 - numberOfFilters;
--                filter <= filters(tmpNum);
                bias <= biases(tmpNum);
                state <= waitForConv;
            when waitForConv =>
                if (mulResultReady = mulResultReadyVar) then
                    state <= waitForConv;
                else
                    if (signed(maxVal) < signed(mulOut)) then
                        maxVal <= mulOut;
                        tmpVal := mulOut;
                    else
                        tmpVal := maxVal;
                    end if;
                    mulResultReadyVar <= mulResultReady;
                    if (numberOfMultiplies = 1 and numberOfFilters = 1) then
                        tmpLogic := not outputReadyVar;
                        outputReady <= tmpLogic;
                        outputReadyVar <= tmpLogic;
                        result(100 - numberOfFilters) <= tmpVal;
                        numberOfMultiplies <= 64 - filterSize;
                        numberOfFilters <= numberOfFilters - 1;
                        maxVal <= "10011100000000000000011010001110"; -- -99.99999
                        state <= stall;
    --                    state <= init;
                    elsif (numberOfMultiplies = 1) then
                        result(100 - numberOfFilters) <= tmpVal;
                        numberOfMultiplies <= 64 - filterSize;
                        numberOfFilters <= numberOfFilters - 1;
                        maxVal <= "10011100000000000000011010001110"; -- -99.99999
                        state <= readFilter;
                    else
                        numberOfMultiplies <= numberOfMultiplies - 1;
                        state <= conv;
                    end if;
                end if;
            when twoClockWait =>
                if (counter = 0) then
                    counter <= counter + 1;
                    state <= twoClockWait;
                else
                    counter <= 0;
                    state <= readFilter;
                end if;
            when stall =>
                state <= stall;
            when others =>
                state <= init;
        end case;
    
    end if;
end process;

mul1: Conv_mul generic map (filterSize) port map (clk, mulInputReady, subSent, filter, bias, mulOut, mulResultReady);
--mem : filter_mem PORT MAP (clk, memEnable, memWriteEn, memAddr, dinasig, douta);
testmem : testRAM PORT MAP (clk, memWriteEn(0), memAddr, dinasig, douta);
  
end Behavioral;
