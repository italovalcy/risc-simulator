require 'gui'

class Memoria
  # Retorna o valor contido em alguns endereços de memoria
  #   address - endereço inicial de memoria
  #   qtd - quantidade de registros que deve ser lidos a 
  #         partir de address
  def Memoria.get_value(address, qtd)
    result = 0
    case qtd
    when 1
      result = Simulador.get_value_grid('mem',address)
    when 2
      r1 = Simulador.get_value_grid('mem',address).to_i
      r2 = Simulador.get_value_grid('mem',address.to_i + 1).to_i
      result = r1*256 + r2
    end
    return result.to_s
  end

  # Armazena o valor de value na memoria no endereco address
  def Memoria.set_value(address, value)
    Simulador.set_value_grid('mem',address,value)
  end
end
