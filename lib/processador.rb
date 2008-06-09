require 'gui'

class Processador
  def initialize
    @had_hlt_instruction = false
    @instruction = ''
    @op_code = ''
    @t_op1 = ''
    @t_op2 = ''
    @id_op1 = ''
    @id_op2 = ''
    @value_op1 = 0   # 
    @value_op2 = 0   # Os valores estao na base
    @result_op = 0   # decimal
  end
  
  def start
    while (not @had_hlt_instruction)
      fetch_next_instruction()
      decode_instruction()
      fetch_operatings()
      run()
      save()
    end
  end

  def set_ip(value)
    Simulador.set_value_rg("ip",value)
  end

  def get_ip(inc)
    ip_value = Simulador.get_value_rg("ip")
    set_ip(ip_value + inc)
    return ip_value
  end

  def get_clock
    Simulador.wait_clock
  end

  # Entrada:
  #    string - uma string que contem um numero inteiro
  #    tam - tamanho que deve ser retornado, caso a conversao
  #          gere uma outra string de tamanho menor que tam
  #          essa string eh _completada_ com zeros à esquerda
  # Retorno:
  #   Uma string de tamanho tam que representa o inteiro da entrada
  #   na base binaria.
  def convert_to_bin(string,tam)
    return string.to_i.to_s(2).rjust(tam,'0')
  end
  
  def fetch_next_instruction
    get_clock()
    address = get_ip(2)
    @instruction = Memoria.get_value(address,2)
  end

  def decode_instruction
    get_clock()
    code = convert_to_bin(@instruction,16)
    @op_code = code[0..3]
    @t_op1 = code[4..5]
    @t_op2 = code[6..7]
    @id_op1 = code[8..11]
    @id_op2 = code[12..15]
  end

  def fetch_operatings
    cod_reg = {"0000"=>"ax", "0001"=>"bx", "0010"=>"cx", "0011"=>"dx"}
    get_clock()
    case @op_code
      when '0001' # MOV
        case @t_op1
          when "01" # Register
            @value_op1 = Simulador.get_value_rg(cod_reg[@id_op1]).to_i
          when "11" # Memory
            @value_op1 = Memoria.get_value(get_ip(1)).to_i
        end
        case @t_op2
          when "01" # Register
            @value_op2 = Simulador.get_value_rg(cod_reg[@id_op2]).to_i
          when "10" # Value
            @value_op2 = @id_op2.to_i(2)
          when "11" # Memory
            @value_op2 = Memoria.get_value(get_ip(1)).to_i
        end
      when '0010', '0011', '1100', '1101' # ADD, SUB, AND, OR
        @value_op1 = Simulador.get_value_rg(cod_reg[@id_op1]).to_i
        case @t_op2
          when "01" # Register
            @value_op2 = Simulador.get_value_rg(cod_reg[@id_op2]).to_i
          when "10" # Value
            @value_op2 = @id_op2.to_i(2)
        end
      when '0100', '0101' # INC, DEC
        @value_op1 = Simulador.get_value_rg(cod_reg[@id_op1]).to_i
      when '0110' # IN
      when '0111' # OUT
      when '1000', '1001', '1010', '1011' # JMP, JG, JE, JL
        @value_op1 = Simulador.get_value_rg(cod_reg[@id_op1]).to_i
      when '1110' # CMP
        case @t_op1
          when "01" # Register
            @value_op1 = Simulador.get_value_rg(cod_reg[@id_op1]).to_i
          when "10" # Value
            @value_op1 = @id_op1.to_i(2)
        end
        case @t_op2
          when "01" # Register
            @value_op2 = Simulador.get_value_rg(cod_reg[@id_op2]).to_i
          when "10" # Value
            @value_op2 = @id_op2.to_i(2)
        end
      when '1111' # HLT
        # No operators
    end
  end

  def run
    get_clock()
    case @op_code
      when '0001' # MOV
        @result_op = @value_op2
      when '0010' # ADD
        @result_op = @value_op1 + @value_op2
      when '0011' # SUB
        @result_op = @value_op1 - @value_op2
      when '0100' # INC
        @result_op = @value_op1 + 1
      when '0101' # DEC
        @result_op = @value_op1 - 1
      when '0110' # IN
      when '0111' # OUT
      when '1000' # JMP
        set_ip(@value_op1)
      when '1001' # JG
        flags = convert_to_bin(Simulador.get_value_rg("flags"),16)
        result_cmp = flags[14..15]
        if (result_cmp == "01")
          set_ip(@value_op1)
        end
      when '1010' # JE
        flags = convert_to_bin(Simulador.get_value_rg("flags"),16)
        result_cmp = flags[14..15]
        if (result_cmp == "00")
          set_ip(@value_op1)
        end
      when '1011' # JL
        flags = convert_to_bin(Simulador.get_value_rg("flags"),16)
        result_cmp = flags[14..15]
        if (result_cmp == "10")
          set_ip(@value_op1)
        end
      when '1100' # AND
      when '1101' # OR
      when '1110' # CMP
      when '1111' # HLT
    end
  end

  def save
    get_clock()
  end
end
