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
    @value_op1 = ''
    @value_op2 = ''
    @result_op = ''
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

  def get_ip
    ip_value = Simulador.get_value_rg("ip")
    Simulador.set_value_rg("ip",ip_value+2)
    return ip_value
  end

  def get_clock
    Simulador.wait_clock
  end
  
  def fetch_next_instruction
    get_clock()
    address = get_ip
    @instruction = Memoria.get_value(address).to_i
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
    case @op_code
      when '0001' # MOV
      when '0010' # ADD
      when '0011' # SUB
      when '0100' # INC
      when '0101' # DEC
      when '0110' # IN
      when '0111' # OUT
      when '1000' # JMP
      when '1001' # JG
      when '1010' # JE
      when '1011' # JL
      when '1100' # AND
      when '1101' # OR
      when '1110' # CMP
      when '1111' # HLT
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
