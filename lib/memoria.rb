require 'gui'

class Memoria

  # Retorna o valor contido em alguns endereços de memoria
  #   address - endereço inicial de memoria
  #   qtd - quantidade de registros que deve ser lidos a 
  #         partir de address
  def Memoria.get_value(address, qtd)
    return Simulador.get_value_grid('mem', address)
  end

  # Armazena o valor de value na memoria no endereco address
  def Memoria.set_value(address, value)
    Simulador.set_value_grid('mem',address,value)
  end
end
