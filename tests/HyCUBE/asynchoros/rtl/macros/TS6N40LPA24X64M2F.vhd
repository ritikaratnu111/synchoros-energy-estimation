library IEEE, work;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

--! Basic Model of a synchronous SRAM

--! This a simple SRAM model, only used for simulations. 
--! Write enable, sleep mode, shutdown mode and write through. 
entity TS6N40LPA24X64M2F is
    port 
    (
        AA      : in std_logic_vector(4 downto 0);
        D       : in std_logic_vector(63 downto 0);   
        BWEB    : in std_logic_vector(63 downto 0);
        WEB     : in std_logic;
        CLKW    : in std_logic;
        AB      : in std_logic_vector(4 downto 0);  
        REB     : in std_logic;   
        CLKR    : in std_logic;
        PD      : in std_logic;
        AMA     : in std_logic_vector(4 downto 0);
        DM      : in std_logic_vector(63 downto 0);
        BWEBM   : in std_logic_vector(63 downto 0);
        WEBM    : in std_logic;
        AMB     : in std_logic_vector(4 downto 0);
        REBM    : in std_logic;
        BIST    : in std_logic;
        Q       : out std_logic_vector(63 downto 0) 
    );
end TS6N40LPA24X64M2F;

architecture RTL of TS6N40LPA24X64M2F is
  -- tell synthesis tool to ignore code
  type memory_ty is array (natural range <>) of std_logic_vector(63 downto 0);
  shared variable memoryA : memory_ty(31 downto 0) := (others => (others => '0'));
  signal OLDA             : std_logic_vector(63 downto 0);
begin
  
Memory_write_A : process (CLKW,WEB,PD,BWEB)
begin
  if PD = '1' then
    memoryA := (others => (others => 'X'));
    OLDA    <= (others => '0');
  elsif rising_edge(CLKW) then
    if WEB = '0' then
      for i in 0 to 63 loop
        if BWEB(i) = '0' then
          memoryA(to_integer(unsigned(AA)))(i) := D(i);
        end if;
      end loop;
    else
      OLDA <= memoryA(to_integer(unsigned(AA)));
    end if;
  end if;
end process;



  Memory_read_A : process (CLKR, WEB, REB, PD)
  begin
    if rising_edge(CLKR) then 
        if (PD = '1') then
            Q <= (others => '0');
        elsif (REB = '0') and (PD = '0') then  
            Q <= memoryA(to_integer(unsigned(AA)));
        else
          Q <= (others => '0');
        end if;
    end if;

  end process Memory_read_A;
  
end RTL;
