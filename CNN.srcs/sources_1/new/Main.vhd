library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library xil_defaultlib;
use xil_defaultlib.myPack.all;

entity Main is
  Port (clk : in std_logic;
        newIn: in std_logic;
        inVec: in std_logic_vector(31 downto 0);
        newOut: out std_logic;
        outVec: out std_logic_vector(31 downto 0));
end Main;

architecture Behavioral of Main is

component CNN is
  Port (clk: in std_logic;
        inputReady : in std_logic;
        addra1 : IN integer;
        dina1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        addra2 : IN integer;
        dina2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        addra3 : IN integer;
        dina3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        newSent : in std_logic;
        sentence : in STD_LOGIC_VECTOR(31 DOWNTO 0);
        sentAddr : in integer;
        --filters1, filters2, filters3 : in filter3_t;
        biases1, biases2, biases3 : in word100_t;
        weight1, weight2: in word_ubt(299 downto 0);
        biases0 : in word_ubt(1 downto 0);
        prediction : out std_logic;
        outputReady : out std_logic;
        convOut : out word100_t);
end component;


signal inputReady : std_logic := '0';
--signal sentence : sent_t;
signal newSent : std_logic := '0';
signal sentence : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal sentAddr : integer;
signal filters1, filters2, filters3 : filter3_t;
signal biases1, biases2, biases3 : word100_t;
signal prediction : std_logic;
signal outputReady : std_logic;
signal convOut : word100_t;
signal weight1, weight2: word_ubt(299 downto 0);
signal biases0 : word_ubt(1 downto 0);

signal addra1 : integer;
signal dina1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal addra2 : integer;
signal dina2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal addra3 : integer;
signal dina3 : STD_LOGIC_VECTOR(31 DOWNTO 0);
--signal clk: std_logic;
signal newInCheck, newOutCheck : std_logic := '0';

signal i,j,k : integer := 0;
type ST_TYPE is (init, getSentnc, getfilt1, getfilt2, getfilt3, getbias1, getbias2, getbias3, getweights, getbias0, waitForCNN);
signal state : ST_TYPE := init;


begin

process(clk)
variable p1, p2 : integer := 0;
variable b1 : std_logic := '0';
begin

    if (rising_edge(clk)) then
        if (newInCheck = not newIn) then
            newInCheck <= newIn;
            case state is
                when init =>
                    state <= getSentnc;
                    i <= 63;
                    j <= 299;
                    
                when getSentnc =>
                    newSent <= '1';
                    sentence <= inVec;
                    sentAddr <= (63-i)*300 + (299-j);
                    if (i = 0 and j = 0) then
                        i <= 99;
                        j <= 2;
                        k <= 299;
                        state <= getfilt1;
                    else
                        if (j = 0) then
                            j <= 299;
                            i <= i-1;
                        else
                            j <= j-1;
                        end if;
                    end if;
                    
                when getfilt1 =>
                    newSent <= '0';
                    addra1 <= (99-i)*3*300 + (2-j)*300 + (299-k);
                    dina1 <= inVec;
                    if (i = 0 and j = 0 and k = 0) then
                        i <= 99;
                        j <= 3;
                        k <= 299;
                        state <= getfilt2;
                    else
                        if (j = 0 and k = 0) then
                            j <= 2;
                            k <= 299;
                            i <= i-1;
                        else
                            if (k = 0) then
                                k <= 299;
                                j <= j-1;
                            else
                                k <= k-1;
                            end if;
                        end if;
                    end if;
                    
                when getfilt2 =>
                    addra2 <= (99-i)*3*300 + (3-j)*300 + (299-k);
                    dina2 <= inVec;
                    if (i = 0 and j = 0 and k = 0) then
                        i <= 99;
                        j <= 4;
                        k <= 299;
                        state <= getfilt3;
                    else
                        if (j = 0 and k = 0) then
                            j <= 2;
                            k <= 299;
                            i <= i-1;
                        else
                            if (k = 0) then
                                k <= 299;
                                j <= j-1;
                            else
                                k <= k-1;
                            end if;
                        end if;
                    end if;
                    
                when getfilt3 =>
                    addra3 <= (99-i)*3*300 + (4-j)*300 + (299-k);
                    dina3 <= inVec;
                    if (i = 0 and j = 0 and k = 0) then
                        i <= 99;
                        j <= 3;
                        k <= 299;
                        state <= getbias1;
                    else
                        if (j = 0 and k = 0) then
                            j <= 4;
                            k <= 299;
                            i <= i-1;
                        else
                            if (k = 0) then
                                k <= 299;
                                j <= j-1;
                            else
                                k <= k-1;
                            end if;
                        end if;
                    end if;
                    
                when getbias1 =>
                    biases1(99-i) <= inVec;
                    if (i = 0) then
                        i <= 99;
                        state <= getbias2;
                    else
                        i <= i-1;
                    end if;
                when getbias2 =>
                    biases2(99-i) <= inVec;
                    if (i = 0) then
                        i <= 99;
                        state <= getbias3;
                    else
                        i <= i-1;
                    end if;
                when getbias3 =>
                    biases3(99-i) <= inVec;
                    if (i = 0) then
                        i <= 599;
                        state <= getweights;
                    else
                        i <= i-1;
                    end if;
                    
                when getweights =>
                    if (b1 = '0') then
                        weight1(p1) <= inVec;
                        p1 := p1 + 1;
                    else
                        weight2(p2) <= inVec;
                        p2 := p2 + 1;
                    end if;
                    b1 := not b1;
                    if (i = 0) then
                        i <= 1;
                        state <= getbias0;
                    else
                        i <= i-1;
                    end if;
                    
                when getbias0 =>
                    biases0(1-i) <= inVec;
                    if (i = 0) then
                        state <= waitForCNN;
                        inputReady <= not inputReady;
                    else
                        i <= i-1;
                    end if;
                    
                when waitForCNN =>
                    if (outputReady = '1') then
                        outVec <= std_logic_vector(unsigned(inVec) + 1);
                        newOut <= not newOutCheck;
                        newOutCheck <= not newOutCheck;
                    end if;
            end case;
            
        end if;
    end if;


end process;


UUT: CNN port map(clk, inputReady, addra1, dina1, addra2, dina2, addra3, dina3, newSent, sentence, sentAddr, biases1, biases2, biases3, weight1, weight2, biases0, prediction, outputReady, convOut);

end Behavioral;
