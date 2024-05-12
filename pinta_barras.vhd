library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.VGA_PKG.ALL; 

use WORK.RACETRACK_PKG.ALL;

entity pinta_barras is
  Port ( 
    rst: in std_logic;
    clk: in std_logic;
    visible: in std_logic;
    col: in unsigned(10-1 downto 0);
    fila: in unsigned(10-1 downto 0);
    dato_memo_red: in std_logic_vector (15 downto 0);          
    dato_memo_blue: in std_logic_vector (15 downto 0);
    dato_memo_green: in std_logic_vector (15 downto 0);
    dato_memo3_red: in std_logic_vector (15 downto 0);
    dato_memo3_blue: in std_logic_vector (15 downto 0);
    dato_memo3_green: in std_logic_vector (15 downto 0);       
    dato_memo2_verde: in std_logic_vector (31 downto 0);
    dato_memo2_azul: in std_logic_vector (31 downto 0);
    btn_sube: in std_logic;
    btn_baja: in std_logic;
    btn_dcha: in std_logic;
    btn_izq: in std_logic;
    addr_memo_red: out std_logic_vector (9-1 downto 0); 
    addr_memo_blue: out std_logic_vector (9-1 downto 0); 
    addr_memo_green: out std_logic_vector (9-1 downto 0);
    addr_memo3_red: out std_logic_vector (9-1 downto 0);
    addr_memo3_blue: out std_logic_vector (9-1 downto 0); 
    addr_memo3_green: out std_logic_vector (9-1 downto 0);     
    addr_memo2_verde: out std_logic_vector (5-1 downto 0);     
    addr_memo2_azul: out std_logic_vector (5-1 downto 0);      
    rojo: out std_logic_vector(c_nb_red-1 downto 0);
    verde: out std_logic_vector(c_nb_green-1 downto 0);
    azul: out std_logic_vector(c_nb_blue-1 downto 0));
end pinta_barras;

architecture behavioral of pinta_barras is

--señales sincro vga --> pinta barras
  signal col_interna1 : unsigned (3 downto 0);
  signal fila_interna1 : unsigned (3 downto 0);
  signal col_interna1_1 : unsigned (3 downto 0);
  signal fila_interna1_1 : unsigned (3 downto 0);
  signal col_interna2 : unsigned (3 downto 0);
  signal fila_interna2 : unsigned (3 downto 0);
  signal col_interna2_1 : unsigned (3 downto 0);
  signal fila_interna2_1 : unsigned (3 downto 0);
  signal col_cuad : unsigned (5 downto 0);
  signal fila_cuad : unsigned (5 downto 0);
  
--señales pinta barras --> memoria coche 1
  signal dato_coche1_red : std_logic;   
  signal dato_coche1_blue : std_logic;                   
  signal dato_coche1_green : std_logic;                   
  signal color_coche1: unsigned (2 downto 0);
  signal coche1_col: unsigned(5 downto 0);
  signal coche1_fila: unsigned(5 downto 0);
  signal addr_fila_memo1: std_logic_vector (4 downto 0);
  signal dir_memo_coche1: std_logic_vector (3 downto 0);
  signal jug_en_pista : std_logic;
  signal direccion: std_logic_vector (1 downto 0);
    
--pinta barras --> memoria coche 2
  signal dato_coche2_red : std_logic;                     
  signal dato_coche2_blue : std_logic;                    
  signal dato_coche2_green : std_logic;                   
  signal color_coche2: unsigned (2 downto 0);
  signal coche2_col: unsigned (5 downto 0);
  signal coche2_fila: unsigned (5 downto 0);  
  signal addr_fila_memo2: std_logic_vector (4 downto 0);  
  signal dir_memo_coche2: std_logic_vector (3 downto 0);
  signal pista_abajo : std_logic;  
  signal pista_derecha : std_logic;
  signal pista_izquierda : std_logic;
  signal pista_arriba : std_logic;
  signal direccion_2: std_logic_vector (1 downto 0);
  
--pinta barras --> memoria pista carreras --> ampliamos x16, es decir, quitamos los 4 bits menos significativos
  signal pista_col, pista_fila : unsigned (4 downto 0);
  signal dato_pista: std_logic;
  
--señales muestreo
  signal conta_muestreo_100ms: unsigned (23 downto 0);
  signal conta_muestreo_100ms_1: unsigned (23 downto 0);
  signal conta_muestreo_500ms: unsigned (25 downto 0);
  signal s_muestreo_100ms: std_logic;                       
  signal s_muestreo_100ms_1: std_logic;                     
  signal s_muestreo_500ms: std_logic;                      
  constant finconta_muestreo_100ms : natural:= 10000000; 
  constant finconta_muestreo_100ms_1 : natural:= 10000001;  
  constant finconta_muestreo_500ms : natural:= 50000000;

--señales FSM coche 2
  type estados is (DERECHA, ARRIBA, ABAJO, IZQUIERDA);
  signal e_act, e_sig : estados;
    
--mejoras
  signal dato_pista_azul : std_logic;
  signal dato_pista_verde: std_logic; 
  signal color_pista: unsigned (1 downto 0);
    
--componentes
component conta_generic
    generic (
      fin_conta: natural := 10**7; 
      n_bits: natural := 24;
      max: unsigned:="1001");
    Port ( 
      clk: in std_logic;
      rst: in std_logic;
      enable: in std_logic;
      up_down: in std_logic;  
      sconta: out STD_LOGIC;
      vconta: out unsigned (n_bits-1 downto 0)); 
end component;

begin

--Contadores

P_muestreo_100ms: conta_generic -- contador de 0,1 segundos    
    generic map (fin_conta=>finconta_muestreo_100ms, n_bits => 24, max=>"100110001001011010000000")
    Port Map (rst=>rst,
              clk=>clk,
              enable=>'1',
              up_down=>'0',
              sconta=>s_muestreo_100ms,
              vconta=>conta_muestreo_100ms);
               
P_muestreo_500ms: conta_generic  -- contador de 0,5 segundos
    generic map (fin_conta=>finconta_muestreo_500ms, n_bits => 26, max=>"10111110101111000010000000")
    Port Map (rst=>rst,
              clk=>clk,
              enable=>'1',
              up_down=>'0',
              sconta=>s_muestreo_500ms,
              vconta=>conta_muestreo_500ms);
              
P_muestreo_100ms_1: conta_generic   --contador de 0,1segundos +1    
    generic map (fin_conta=>finconta_muestreo_100ms_1, n_bits => 24, max=>"100110001001011010000001")
    Port Map ( rst=>rst,
               clk=>clk,
               enable=>'1',
               up_down=>'0',
               sconta=>s_muestreo_100ms_1,
               vconta=>conta_muestreo_100ms_1);            
                 


col_cuad <= col(9 downto 4);
fila_cuad <= fila(9 downto 4);


--Coche 1

p1:process (clk, rst)
begin 
  if rst = '1' then 
    direccion <= "11";
  elsif clk'event and clk='1' then 
    if btn_dcha ='1' then 
      direccion <="11";
    elsif btn_izq ='1' then
      direccion <= "10";
    elsif btn_sube ='1' then
      direccion <= "00";
    elsif btn_baja ='1' then
      direccion <= "01";
    end if;
  end if;
end process;

p2:process (clk)
begin
  if clk'event and clk='1' then 
    case direccion is 
      when "00" =>
        col_interna1_1 <= col (3 downto 0); 
        fila_interna1_1 <= fila (3 downto 0);
      when "01" =>
        col_interna1_1 <= col (3 downto 0);
        fila_interna1_1 <= not (fila (3 downto 0));
      when "10" =>
        col_interna1_1 <= fila (3 downto 0);
        fila_interna1_1 <= col (3 downto 0);
      when "11" =>
        col_interna1_1 <= fila (3 downto 0); 
        fila_interna1_1 <= not (col (3 downto 0));
    end case;
    col_interna1 <= col_interna1_1;
    fila_interna1 <= fila_interna1_1;
  end if;
end process;
    
dir_memo_coche1 <= std_logic_vector(fila_interna1); 

addr_memo_red <= addr_fila_memo1 & dir_memo_coche1;        -- concatenamos la fila interna y la fila de la memo16x16(compuesta de 16 filas internas) para seleccionar 1 de entre 16 imagenes
addr_memo_blue <= addr_fila_memo1 & dir_memo_coche1;       
addr_memo_green <= addr_fila_memo1 & dir_memo_coche1;      

dato_coche1_red <= dato_memo_red(to_integer(col_interna1));
dato_coche1_blue <= dato_memo_blue(to_integer(col_interna1));
dato_coche1_green <= dato_memo_green(to_integer(col_interna1));


--Coche 2

p3:process (clk, rst)
begin 
  if rst = '1' then 
    direccion_2 <= "11";
  elsif clk'event and clk='1' then 
    if e_sig = DERECHA then 
      direccion_2 <="11";
    elsif e_sig = IZQUIERDA then
      direccion_2 <= "10";
    elsif e_sig = ARRIBA then
      direccion_2 <= "00";
    elsif e_sig = ABAJO then
      direccion_2 <= "01";
    end if;
  end if;
end process;

p4:process (clk)
begin
  if clk'event and clk='1' then 
    case direccion_2 is 
      when "00" =>
        col_interna2_1 <= col (3 downto 0); 
        fila_interna2_1 <= fila (3 downto 0);
      when "01" =>
        col_interna2_1 <= col (3 downto 0);
        fila_interna2_1 <= not (fila (3 downto 0));
      when "10" =>
        col_interna2_1 <= fila (3 downto 0);
        fila_interna2_1 <= col (3 downto 0);
      when "11" =>
        col_interna2_1 <= fila (3 downto 0); 
        fila_interna2_1 <= not (col (3 downto 0));
    end case;
    col_interna2 <= col_interna2_1;
    fila_interna2 <= fila_interna2_1;
  end if;
end process;

dir_memo_coche2 <= std_logic_vector(fila_interna2);         

addr_memo3_red <= addr_fila_memo2 & dir_memo_coche2;
addr_memo3_blue <= addr_fila_memo2 & dir_memo_coche2;
addr_memo3_green <= addr_fila_memo2 & dir_memo_coche2;

dato_coche2_red <= dato_memo3_red(to_integer(col_interna2));
dato_coche2_blue <= dato_memo3_blue(to_integer(col_interna2));
dato_coche2_green <= dato_memo3_green(to_integer(col_interna2));


--Pista carreras
--para la pista de carreras tenemos que ampliar la memoria x16 --> quitamos 4 bits menos significativos

pista_col <= col(8 downto 4);
pista_fila <= fila(8 downto 4);

addr_memo2_verde <= std_logic_vector (pista_fila);
addr_memo2_azul <= std_logic_vector (pista_fila);

dato_pista_verde <= dato_memo2_verde(to_integer(pista_col));
dato_pista_azul <= dato_memo2_azul(to_integer(pista_col));


--Mvimiento del coche

jug_en_pista <= pista(to_integer(coche1_fila))(to_integer(coche1_col));

P_pulsa_movimiento_coche1: process (rst, clk)
begin
    if rst='1' then
        coche1_col <= "001101";         
        coche1_fila <= "010111";    
    elsif clk'event and clk='1' then
      if jug_en_pista = '1' then            -- el coche esta dentro de la pista
        if s_muestreo_100ms = '1' then      -- se mueve cada 0,1 segundo
            if btn_dcha = '1' then
                if coche1_col <31 then         -- valor maximo de columna del campo de juego 
                coche1_col <= coche1_col + 1;  
                end if;
            elsif btn_izq = '1' then
                if coche1_col > 0 then         -- valor minimo de columna del campo de juego
                coche1_col <= coche1_col - 1;
                end if;
            elsif btn_sube = '1' then
                if coche1_fila > 0 then        -- valor minimo de fila del campo de juego 
                coche1_fila <= coche1_fila - 1;
                end if;
            elsif btn_baja = '1' then 
                if coche1_fila < 29 then       -- valor maximo de fila del campo de juego
                coche1_fila <= coche1_fila + 1;
                end if;
            end if;
        end if;
      else                                     -- coche fuera de la pista
        if s_muestreo_500ms = '1' then         -- se mueve cada 0,5 segundo
            if btn_dcha = '1' then
                if coche1_col <31 then         -- valor de columna maximo del campo de juego 
                coche1_col <= coche1_col + 1;  
                end if;
            elsif btn_izq = '1' then
                if coche1_col > 0 then         -- valor minimo de columna de campo de juego
                coche1_col <= coche1_col - 1;
                end if;
            elsif btn_sube = '1' then
                if coche1_fila > 0 then        -- valor minimo de fila del campo de juego 
                coche1_fila <= coche1_fila - 1;
                end if;
            elsif btn_baja = '1' then 
                if coche1_fila < 29 then       -- valor maximo de fila del campo de juego
                coche1_fila <= coche1_fila + 1;
                end if;
            end if;
       end if;
      end if;
    end if;
end process;


--Movimiento del coche automático

P_posicion_coche2_sec: process (clk, rst)
begin
    if rst ='1' then
        coche2_col <= "001101";     
        coche2_fila <= "011011"; 
    elsif clk'event and clk='1' then
        if s_muestreo_100ms = '1' then
            case e_act is 
            when DERECHA =>
                coche2_col <= coche2_col + 1;
            when ARRIBA =>
                coche2_fila <= coche2_fila - 1;
            when ABAJO =>
                coche2_fila <= coche2_fila + 1;
            when IZQUIERDA =>
                coche2_col <= coche2_col - 1;
            end case;
       end if;
   end if;
end process;
          
P_fsm_sec: Process (clk, rst)
begin
    if rst = '1' then
        e_act <= DERECHA;
    elsif clk'event and clk='1' then
        if s_muestreo_100ms_1 = '1' then
          e_act <= e_sig;
        end if;
   end if;
end process;

pista_abajo <= pista(to_integer(coche2_fila+1))(to_integer(coche2_col));
pista_derecha <= pista(to_integer(coche2_fila))(to_integer(coche2_col+1));
pista_izquierda <= pista(to_integer(coche2_fila))(to_integer(coche2_col-1));
pista_arriba <= pista(to_integer(coche2_fila-1))(to_integer(coche2_col));

P_fsm_comb: Process (e_act, coche2_fila, coche2_col)
begin
e_sig<=e_act;
  case e_act is 
    when ABAJO =>
        if pista_izquierda = '1' then
            e_sig <= IZQUIERDA;
        elsif pista_abajo = '1' then
            e_sig <= ABAJO;
        elsif pista_derecha = '1' then
            e_sig <= DERECHA;
        elsif pista_arriba = '1' then 
            e_sig <= ARRIBA;
        end if;
    when DERECHA =>
        if pista_abajo = '1' then
            e_sig <= ABAJO;
        elsif pista_derecha = '1' then
            e_sig <= DERECHA;
        elsif pista_arriba = '1' then
            e_sig <= ARRIBA;
        elsif pista_izquierda = '1' then 
            e_sig <= IZQUIERDA;
        end if;
    when ARRIBA =>
        if pista_derecha = '1' then
            e_sig <= derecha;
        elsif pista_arriba = '1' then
            e_sig <= ARRIBA;
        elsif pista_izquierda = '1' then
            e_sig <= IZQUIERDA;
        elsif pista_abajo = '1' then 
            e_sig <= ABAJO;
        end if;
    when IZQUIERDA =>
        if pista_arriba = '1' then
            e_sig <= ARRIBA;
        elsif pista_izquierda = '1' then
            e_sig <= IZQUIERDA;
        elsif pista_abajo = '1' then
            e_sig <= ABAJO;
        elsif pista_derecha = '1' then 
            e_sig <= DERECHA;
        end if;
  end case;
end process;


--Pintar pista y coche

color_coche1 <= "000" when (dato_coche1_red ='0') and (dato_coche1_blue ='0') and (dato_coche1_green ='0') else
                "001" when (dato_coche1_red ='0') and (dato_coche1_blue ='0') and (dato_coche1_green ='1') else 
                "010" when (dato_coche1_red ='0') and (dato_coche1_blue ='1') and (dato_coche1_green ='0') else
                "011" when (dato_coche1_red ='0') and (dato_coche1_blue ='1') and (dato_coche1_green ='1') else
                "100" when (dato_coche1_red ='1') and (dato_coche1_blue ='0') and (dato_coche1_green ='0') else
                "101" when (dato_coche1_red ='1') and (dato_coche1_blue ='0') and (dato_coche1_green ='1') else
                "110" when (dato_coche1_red ='1') and (dato_coche1_blue ='1') and (dato_coche1_green ='0') else
                "111" when (dato_coche1_red ='1') and (dato_coche1_blue ='1') and (dato_coche1_green ='1');
                
color_coche2 <= "000" when (dato_coche2_red ='0') and (dato_coche2_blue ='0') and (dato_coche2_green ='0') else
                "001" when (dato_coche2_red ='0') and (dato_coche2_blue ='0') and (dato_coche2_green ='1') else 
                "010" when (dato_coche2_red ='0') and (dato_coche2_blue ='1') and (dato_coche2_green ='0') else
                "011" when (dato_coche2_red ='0') and (dato_coche2_blue ='1') and (dato_coche2_green ='1') else
                "100" when (dato_coche2_red ='1') and (dato_coche2_blue ='0') and (dato_coche2_green ='0') else
                "101" when (dato_coche2_red ='1') and (dato_coche2_blue ='0') and (dato_coche2_green ='1') else
                "110" when (dato_coche2_red ='1') and (dato_coche2_blue ='1') and (dato_coche2_green ='0') else
                "111" when (dato_coche2_red ='1') and (dato_coche2_blue ='1') and (dato_coche2_green ='1');

color_pista <= "00" when (dato_pista_verde ='0') and (dato_pista_azul ='0') else
               "01" when (dato_pista_verde = '0' )and (dato_pista_azul ='1') else 
               "10" when (dato_pista_verde ='1') and (dato_pista_azul='0') else
               "11" when (dato_pista_verde ='1')and (dato_pista_azul='1');
                                 
P_pinta: Process (visible, col, fila, col_interna1, fila_interna1, fila_cuad, col_cuad, color_coche1, color_coche2, color_pista)
begin -- begin negro 
    rojo <= (others => '0');
    verde <= (others => '0');
    azul <= (others => '0');
    if visible ='1' then
      if col < 513 then
        if (fila_cuad = coche1_fila) and (col_cuad = coche1_col) then  -- pintar coche 1
          addr_fila_memo1 <= "11110";                                  -- fila de imagen 15 es un coche
          if color_coche1 = "000" then
            rojo <= "0000";
            azul <= "0000";
            verde <= "0000";
          elsif color_coche1 = "001" then
            rojo <= "0000";
            azul <= "0000";
            verde <= "1111";
          elsif color_coche1 = "010" then
            rojo <= "0000";
            azul <= "1111";
            verde <= "0000";
          elsif color_coche1 = "011" then
            rojo <= "0000";
            azul <= "1111";
            verde <= "1111";
          elsif color_coche1 = "100" then
            rojo <= "1111";
            azul <= "0000";
            verde <= "0000";
          elsif color_coche1 = "101" then
            rojo <= "1111";
            azul <= "0000";
            verde <= "1111";
          elsif color_coche1 = "110" then
            rojo <= "1111";
            azul <= "1111";
            verde <= "0000";
          else --pinta pista
            if color_pista = "00" then
              rojo <= "1111";
              azul <= "0000";
              verde <= "0000";
            elsif color_pista = "01" then
              rojo <= "0000";
              verde <= "0000";
              azul <= "1111";
            elsif color_pista = "10" then
              rojo <= "0000";
              azul <= "0000";
              verde <= "1111";
            else -- dato_pista_verde = 1 y dato_pista_azul = 1
              rojo <= "1111";
              verde <= "1111";
              azul <= "1111";
            end if;
          end if;
        elsif (fila_cuad = coche2_fila) and (col_cuad = coche2_col) then  -- pintar coche 2
          addr_fila_memo2 <= "11110";                                   -- fila imagen 15 es un coche
          if color_coche2 = "000" then
            rojo <= "0000";
            azul <= "0000";
            verde <= "0000";
          elsif color_coche2 = "001" then
            rojo <= "0000";
            azul <= "0000";
            verde <= "1111";
          elsif color_coche2 = "010" then
            rojo <= "0000";
            azul <= "1111";
            verde <= "0000";
          elsif color_coche2 = "011" then
            rojo <= "0000";
            azul <= "1111";
            verde <= "1111";
          elsif color_coche2 = "100" then
            rojo <= "1111";
            azul <= "0000";
            verde <= "0000";
          elsif color_coche2 = "101" then
            rojo <= "1111";
            azul <= "0000";
            verde <= "1111";
          elsif color_coche2 = "110" then
            rojo <= "1111";
            azul <= "1111";
            verde <= "0000";
          else -- pinta pista
            if color_pista = "00" then
              rojo <= "1111";
              azul <= "0000";
              verde <= "0000";
            elsif color_pista = "01" then
              rojo <= "0000";
              verde <= "0000";
              azul <= "1111";
            elsif color_pista = "10" then
              rojo <= "0000";
              azul <= "0000";
              verde <= "1111";
            else -- dato_pista_verde = 1 y dato_pista_azul = 1
              rojo <= "1111";
              verde <= "1111";
              azul <= "1111";
            end if;
          end if;
        else --pinta pista
          if color_pista = "00" then
            rojo <= "1111";
            azul <= "0000";
            verde <= "0000";
          elsif color_pista = "01" then
            rojo <= "0000";
            verde <= "0000";
            azul <= "1111";
          elsif color_pista = "10" then
            rojo <= "0000";
            azul <= "0000";
            verde <= "1111";
          else -- dato_pista_verde = 1 y dato_pista_azul = 1
            rojo <= "1111";
            verde <= "1111";
            azul <= "1111";
          end if;
        end if;
      end if;
    end if;
end process;

end Behavioral;
