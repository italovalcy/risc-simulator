require 'gui'

class Cache

# Retorna o valor contido em alguns endereços do cache
#   address - endereço inicial do cache
#   qtd - quantidade de registros que deve ser lidos a 
#         partir de address

  def Cache.get_value(address, qtd)
    if(Simulador.get_type_mapping ) 
    end
    return Simulador.get_value_memoria(address)
  end

  def get_position(address)
    case (Simulador.get_type_mapping)
      when 0 #mapeamento direto
        return address.to_i.mod Simulador.get_cache_size
      when 1 #mapeamento fully-set
      when 2 #mapeamento 2-set
      when 3 #mapeamento 4-set
    end
  end

  def fetch_value(address)
    pos = get_position(address)
    Simulador.get_value_grid('cache',pos)
  end

  # Armazena o valor de value no cache no endereco address
  def Cache.set_value(address, value)
  end
end
