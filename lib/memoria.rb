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
  def Memoria.set_value(address, value, qtd)
    case qtd
    when 1
      Simulador.set_value_grid('mem',address,value)
    when 2
      v1 = value.to_i / 256
      Simulador.set_value_grid('mem',address,v1.to_s)
      v2 = value.to_i - v1 * 256
      Simulador.set_value_grid('mem',"#{address.to_i+1}",v2.to_s)
    end
  end
end
