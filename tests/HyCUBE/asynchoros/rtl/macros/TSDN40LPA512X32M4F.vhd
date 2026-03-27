library IEEE, work;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

--! Basic Model of a synchronous SRAM

--! This a simple SRAM model, only used for simulations. 
--! Write enable, sleep mode, shutdown mode and write through. 
entity TSDN40LPA512X32M4F is
    port 
    (
        AA     : in std_logic_vector(8 downto 0);
        DA     : in std_logic_vector(31 downto 0);   
        BWEBA  : in std_logic_vector(31 downto 0);
        WEBA   : in std_logic;
        CEBA   : in std_logic;   
        CLKA   : in std_logic;
        AB     : in std_logic_vector(8 downto 0);  
        DB     : in std_logic_vector(31 downto 0);   
        BWEBB  : in std_logic_vector(31 downto 0);   
        WEBB   : in std_logic;
        CEBB   : in std_logic;
        CLKB   : in std_logic;
        PD     : in std_logic;
        AMA    : in std_logic_vector(8 downto 0);
        DMA    : in std_logic_vector(31 downto 0);
        BWEBMA : in std_logic_vector(31 downto 0);
        WEBMA  : in std_logic;
        CEBMA  : in std_logic;
        AMB    : in std_logic_vector(8 downto 0);
        DMB    : in std_logic_vector(31 downto 0);
        BWEBMB : in std_logic_vector(31 downto 0);
        WEBMB  : in std_logic;
        CEBMB  : in std_logic;
        BIST   : in std_logic;
        CLKM   : in std_logic;
        QA     : out std_logic_vector(31 downto 0); 
        QB     : out std_logic_vector(31 downto 0)
    );
end TSDN40LPA512X32M4F;

architecture RTL of TSDN40LPA512X32M4F is
  -- tell synthesis tool to ignore code
  type memory_ty is array (natural range <>) of std_logic_vector(31 downto 0);
  shared variable memoryA : memory_ty(511 downto 0) := (others => (others => '0'));
  shared variable memoryB : memory_ty(511 downto 0) := (others => (others => '0'));
  signal OLDA             : std_logic_vector(31 downto 0);
  signal OLDB             : std_logic_vector(31 downto 0);
begin
  
  Memory_write_A : process (CLKA, CEBA, PD)
  begin
    if (PD = '1') then
      memoryA := (others => (others => 'X'));
      OLDA    <= (others => '0');
    elsif rising_edge(CLKA) then
        if (WEBA = '0') and (CEBA='0') then
          memoryA(to_integer(unsigned(AA))) := DA;
        else
          OLDA <= memoryA(to_integer(unsigned(AA)));
        end if;
    end if;
  end process Memory_write_A;


  Memory_write_B : process (CLKB, CEBB, PD)
  begin
    if (PD = '1') then
      memoryB := (others => (others => 'X'));
      OLDB    <= (others => '0');
      elsif rising_edge(CLKB) then
        if (WEBB = '0') and (CEBA='0') then
          memoryB(to_integer(unsigned(AB))) := DB;
        else
          OLDB <= memoryB(to_integer(unsigned(AB)));
        end if;
    end if;
  end process Memory_write_B;


  Memory_read_A : process (CLKA, CEBA, WEBA, PD)
  begin
    if rising_edge(CLKA) then 
        if (PD = '1') then
          QA <= (others => '0');
        elsif (CEBA = '0') and (PD = '0') then  
            QA <= memoryA(to_integer(unsigned(AA)));
        else
            QA <= (others => '0');
        end if;
    end if;
  end process Memory_read_A;
  
  Memory_read_B : process (CLKB, CEBB, WEBB, PD)
  begin
    if rising_edge(CLKB) then 
        if (PD = '1') then
          QB <= (others => '0');
        elsif (CEBB = '1') and (PD = '0') then 
            QB <= memoryB(to_integer(unsigned(AB)));
        else
              QB <= (others => '0');
        end if;
    end if;
  end process Memory_read_B;
end RTL;
