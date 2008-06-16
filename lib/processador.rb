require 'gui'
require 'barramento'

class Processador
  def initialize
    @had_hlt_instruction = false
    @inst1 = ''
    @inst2 = ''
    @op_code = ''
    @t_op1 = ''
    @t_op2 = ''
    @id_op1 = ''
    @id_op2 = ''
    @value_op1 = 0   # 
    @value_op2 = 0   # Os valores estao na base
    @result_op = 0   # decimal
    @sleep_clock = Simulador.get_sleep_clock
    @count_clock = 0
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
    ip_value = Simulador.get_value_rg("ip").to_i
    set_ip(ip_value + inc)
    return ip_value
  end

  def get_clock
    if (Simulador.automatic_clock?)
      sleep @sleep_clock
    elsif
      Thread.stop
    end
    @count_clock += 1
    Simulador.inc_clock(@count_clock)
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
    Simulador.set_value_bus('mem','con','0')
    Simulador.set_value_bus('io','con','0')
    address = get_ip(2)
    @inst1 = Barramento.read("mem",address)
    Simulador.set_value_rg("ri",@inst1)
    Simulador.set_log_ula("Buscou instrução:\n" + @inst1)
    @inst2 =  Barramento.read("mem",address + 1)
  end

  def decode_instruction
    get_clock()
    Simulador.set_value_bus('mem','con','0')
    code1 = convert_to_bin(@inst1,8)
    code2 = convert_to_bin(@inst2,8)
    @op_code = code1[0..3]
    @t_op1 = code1[4..5]
    @t_op2 = code1[6..7]
    @id_op1 = code2[0..3]
    @id_op2 = code2[4..7]
    Simulador.set_log_ula("Decodificou instrução\n" +
                          "Op-code: #{@op_code}\n"+
                          "Tipo op1: #{@t_op1}\tTipo op2: #{@t_op2}\n" +
                          "ID op1: #{@id_op1}\tID op2: #{@id_op2}")
  end

  def fetch_operatings
    cod_reg = {"0000"=>"ax", "0001"=>"bx", "0010"=>"cx", "0011"=>"dx"}
    log_op1 = ''
    log_op2 = ''
    case @op_code
      when '0001' # MOV
        get_clock()
        case @t_op1
          when "01" # Register
            log_op1 = "Op1: #{cod_reg[@id_op1]}"
          when "11" # Memory
            address = get_ip(1)
            @id_op1 = Barramento.read("mem",address).to_i
            log_op1 = "Op1: [#{@id_op1}]"
        end
        case @t_op2
          when "01" # Register
            @value_op2 = Simulador.get_value_rg(cod_reg[@id_op2]).to_i
            log_op2 = "Op2: #{cod_reg[@id_op2]}"
          when '10' # Value
            @value_op2 = Barramento.read("mem",get_ip(1)).to_i
            log_op2 = "Op2: #{@value_op2}"
          when '11'  # Memory
            address = get_ip(1)
            @id_op2 = Barramento.read("mem",address).to_i
            @value_op2 = Barramento.read("mem",@id_op2).to_i
            log_op2 = "Op2: [#{@id_op2}]"
        end
      when '0010', '0011', '1100', '1101', '1110'  # ADD, SUB, AND, OR, CMP
        get_clock()
        @value_op1 = Simulador.get_value_rg(cod_reg[@id_op1]).to_i
        log_op1 = "Op1: #{cod_reg[@id_op1]}"
        @value_op2 = Simulador.get_value_rg(cod_reg[@id_op2]).to_i
        log_op2 = "Op2: #{cod_reg[@id_op2]}"
      when '0110' # IN
        get_clock()
        log_op1 = "Op1: #{cod_reg[@id_op1]}"
        @value_op2 = Simulador.get_value_rg(cod_reg[@id_op2]).to_i
        log_op2 = "Op2: [#{@value_op2}]"
      when '0111' # OUT
        get_clock()
        @value_op1 = Simulador.get_value_rg(cod_reg[@id_op1]).to_i
        log_op1 = "Op1: [#{@value_op1}]"
        @value_op2 = Simulador.get_value_rg(cod_reg[@id_op2]).to_i
        log_op2 = "Op2: #{cod_reg[@id_op2]}"
      when '1000', '1001', '1010', '1011', '0100', '0101' # JMP, JG, JE, JL, INC, DEC
        get_clock()
        @value_op1 = Simulador.get_value_rg(cod_reg[@id_op1]).to_i
        log_op1 = "Op1: #{cod_reg[@id_op1]}"
      when '1111' # HLT
        # No operators
    end
    if (@op_code != '1111')
      Simulador.set_log_ula("Buscou operandos:\n" +
                          "#{log_op1}\t#{log_op2}")
    end
  end

  def run
    log_run = ''
    case @op_code
      when '0001', '0111' # MOV, OUT
        get_clock()
        @result_op = @value_op2
        log_run = "result_tmp = #{@value_op2}"
      when '0010' # ADD
        get_clock()
        @result_op = @value_op1 + @value_op2
        log_run = "result_tmp = #{@value_op1} + #{@value_op2}"
      when '0011' # SUB
        get_clock()
        @result_op = @value_op1 - @value_op2
        log_run = "result_tmp = #{@value_op1} - #{@value_op2}"
      when '0100' # INC
        get_clock()
        @result_op = @value_op1 + 1
        log_run = "result_tmp = #{@value_op1} + 1"
      when '0101' # DEC
        get_clock()
        @result_op = @value_op1 - 1
        log_run = "result_tmp = #{@value_op1} - 1"
      when '0110' # IN
        get_clock()
        @result_op = Barramento.read('io',@value_op2)
        log_run = "result_tmp = #{@result_op}"
      when '1000' # JMP
        get_clock()
        set_ip(@value_op1)
        log_run = "IP <- #{@value_op1}"
      when '1001' # JG
        get_clock()
        flags = convert_to_bin(Simulador.get_value_rg("flags"),16)
        result_cmp = flags[14..15]
        if (result_cmp == "01")
          set_ip(@value_op1)
          log_run = "IP <- #{@value_op1}"
        end
      when '1010' # JE
        get_clock()
        flags = convert_to_bin(Simulador.get_value_rg("flags"),16)
        result_cmp = flags[14..15]
        if (result_cmp == "00")
          set_ip(@value_op1)
          log_run = "IP <- #{@value_op1}"
        end
      when '1011' # JL
        get_clock()
        flags = convert_to_bin(Simulador.get_value_rg("flags"),16)
        result_cmp = flags[14..15]
        if (result_cmp == "10")
          set_ip(@value_op1)
          log_run = "IP <- #{@value_op1}"
        end
      when '1100' # AND
        get_clock()
        @result_op = @value_op1 and @value_op2
        log_run = "result_tmp = #{@value_op1} AND #{@value_op2}"
      when '1101' # OR
        get_clock()
        @result_op = @value_op1 or @value_op2
        log_run = "result_tmp = #{@value_op1} OR #{@value_op2}"
      when '1110' # CMP
        get_clock()
        flags = convert_to_bin(Simulador.get_value_rg("flags"),16)
        if (@value_op1 == @value_op2)
          flags[14..15] = '00'
        elsif (@value_op1 > @value_op2)
          flags[14..15] = '01'
        else
          flags[14..15] = '10'
        end
        @result_op = flags.to_i(2)
        log_run = "result_tmp = #{@value_op1} CMP #{@value_op2}"
      when '1111' # HLT
        get_clock()
        @had_hlt_instruction = true
        log_run = "HLT"
    end
    if (@op_code != '0110')
      Simulador.set_value_bus('io','con','0')
    end
    Simulador.set_value_bus('mem','con','0')
    Simulador.set_log_ula("Executou:\n#{log_run}")
  end

  def save
    cod_reg = {"0000"=>"ax", "0001"=>"bx", "0010"=>"cx", "0011"=>"dx"}
    case @op_code
      when '0001' # MOV
        get_clock()
        case @t_op1
          when '01' # Register
            Simulador.set_value_rg(cod_reg[@id_op1],@result_op)
            Simulador.set_log_ula("Salvou:\n"+
                                  "#{cod_reg[@id_op1]} <- result_tmp (#{@result_op})")
          when '11' # Memory
            Memoria.set_value(@id_op1,@result_op)
            Simulador.set_log_ula("Salvou:\n [#{@id_op1}] <- result_tmp (#{@result_op})")
        end
      when '0010', '0011', '0100', '0101', '1100', '1101' # ADD, SUB, INC, DEC, AND, OR
        get_clock()
        Simulador.set_value_rg(cod_reg[@id_op1], @result_op)
        Simulador.set_log_ula("Salvou:\n #{cod_reg[@id_op1]} <- result_tmp (#{@result_op})")
      when '0110' # IN
        get_clock()
        Simulador.set_value_bus('io','con','0')
        Simulador.set_value_rg(cod_reg[@id_op1], @result_op)
        Simulador.set_log_ula("Salvou:\n #{cod_reg[@id_op1]} <- result_tmp (#{@result_op})")
      when '0111' # OUT
        get_clock()
        Barramento.write("io",@value_op1.to_s,@result_op.to_s)
        Simulador.set_log_ula("Salvou:\n [#{@value_op1}] <- result_tmp (#{@result_op})")
      when '1000','1001', '1010', '1011' # JMP, JG, JE, JL
        # Nada a ser feito
      when '1110' # CMP
        get_clock()
        Simulador.set_value_rg("flags",@result_op)
        Simulador.set_log_ula("Salvou:\n Flags <- result_tmp (#{@result_op})")
      when '1111' # HLT
        # Nada a ser feito
    end
  end
end
