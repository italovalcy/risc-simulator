require 'gui'
require 'memoria'

class Barramento
  def initialize
  end

  # Solicita do barramento a leitura do dado
  # no endereço address.
  # Entrada:
  #   type - Tipo de barramento: mem (memoria), io (I/O)
  #   address - Endereço que deseja-se ler
  #   qtd - quantidade de endereços que devem ser lidos
  # Retorno:
  #   Valor contido em address
  def Barramento.read(type,address, qtd)
    # Define o valor do controle
    con = qtd.to_s(2).rjust(2,'0') + "01"
    con = con.to_i(2).to_s

    Simulador.set_value_bus(type,"con",con)
    Simulador.set_value_bus(type,"end",address)
    Simulador.get_clock
    case type
    when 'mem'
      value = Memoria.get_value(address,qtd)
    when 'io'
      value = Simulador.get_value_grid('io',address)
    end
    Simulador.set_value_bus(type,"data",value)
    Simulador.set_value_bus(type,"con","0")
    Simulador.get_clock
    return value
  end

  def Barramento.write(type,address,value,qtd)
    con = qtd.to_s(2).rjust(2,'0') + "10"
    Simulador.set_value_bus(type,"con",con.to_i(2).to_s)
    Simulador.set_value_bus(type,"end",address)
    Simulador.set_value_bus(type,"data",value)
    Simulador.get_clock
    case type
    when 'mem'
      Memoria.set_value(address,value,qtd)
    when 'io'
      Simulador.set_value_grid('io',address,value)
    end
    Simulador.set_value_bus(type,"con","0")
  end
end
