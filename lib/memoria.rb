require 'gui'

class Memori
  def get_row_cache(address)
    case Simulador.get_type_mapping
    when '0' # Direto
      i = address.to_i % Simulador.get_cache_size
    when '1' # Full set
    when '2' # 2-set
    when '3' # 4-set
    end
  end

  def containing_in_cache(address)
  end

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
