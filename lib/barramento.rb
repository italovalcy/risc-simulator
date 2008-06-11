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
  # Retorno:
  #   Valor contido em address
  def read(type,address)
    Simulador.set_value_bus(type,"con","1")
    Simulador.set_value_bus(type,"end",address)
    value = Memoria.get_value(address,1)
    Simulador.set_value_bus(type,"data",value)
    return value
  end

  def write(type,address,value)
    Simulador.set_value_bus(type,"con","2")
    Simulador.set_value_bus(type,"end",address)
    Simulador.set_value_bus(type,"data",value)
    Memoria.set_value(address,value)
  end
end
