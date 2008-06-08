require 'gui'

class Processador
  def initialize
    @had_hlt_instruction = false
    @instruction = 0
    @op_code = ''
    @t_op1 = ''
    @t_op2 = ''
    @id_op1 = ''
    @id_op2 = ''
    @value_op1 = 0
    @value_op2 = 0
    @result_op = 0
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

  def get_ip(inc)
    ip_value = Simulador.get_value_rg("ip")
    Simulador.set_value_rg("ip",ip_value + inc)
    return ip_value
  end

  def get_clock
    Simulador.wait_clock
  end
  
  def fetch_next_instruction
    get_clock()
    address = get_ip(2)
    @instruction = Memoria.get_value(address,2).to_i
  end

  def decode_instruction
    get_clock()
    code = @instruction.to_s(2)
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
      when '0110', '0111' # IN, OUT
        @value_op1 = Simulador.get_value_rg(cod_reg[@id_op1]).to_i
        @value_op2 = Simulador.get_value_rg(cod_reg[@id_op2]).to_i
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
    get_clock()
  end

  def run
    get_clock()
  end

  def save
    get_clock()
  end
end
