library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


use IEEE.NUMERIC_STD.ALL;


entity conta_generic is
  generic ( 
    fin_conta: natural := 10**7;                -- frecuencia inicial es 100MHz --> nueva frecuencia 10*10e6
    n_bits: natural := 24;                      
    max: unsigned:="1001");
  Port ( 
    clk: in std_logic;
    rst: in std_logic;
    enable: in std_logic;                    
    up_down: in std_logic;                      -- SW OFF = ascendente, SW ON= descendente
    sconta: out std_logic;                      -- una señal/pulso cada periodo: si es s1dec --> un pulso cada decima de segundo; si es s1seg --> un pulso cada segundo. 
    vconta: out unsigned (n_bits-1 downto 0));   
end conta_generic;

architecture Behavioral of conta_generic is

-- señales para el contador
    signal counter: unsigned (n_bits-1 downto 0);  
    signal s_conta : std_logic;
   
begin

--CONTADOR

contador_generico: process (clk, rst)      
begin
    if rst ='1' then
        counter <= (others=>'0');
    elsif clk'event and clk='1' then
        if enable='1' then 
            if up_down ='0' then   
                if s_conta='1' then
                counter<=(others=>'0');
                else
                counter<=counter + 1;
                end if;
            else   -- si up_down esta en 1 
                if s_conta='1' then
                counter<=max;
                else
                counter<=counter-1;
                end if;
            end if;
        end if;
    end if;
end process;

s_conta<= '1' when counter = fin_conta-1 and enable ='1' and up_down='0' else
          '1' when counter = 0 and enable ='1' and up_down ='1' else '0';  
sconta<=s_conta;
vconta<=counter;

end Behavioral;