require 'gui'
require 'barramento'

class Cache
  # Retorna o valor contido em alguns endereços do cache
  #   address - endereço inicial do cache
  #   qtd - quantidade de registros que deve ser lidos a 
  #         partir de address
  def Cache.get_value(address, qtd)
    result = ''
    if(Simulador.cache_habilitado)
      for i in 0..qtd - 1
        value = fetch_value(address.to_i + i)
        if (value == nil)
          # Cache miss
          value = update_cache(address.to_i + i)
        end
        result = str_concat(result,value)
      end
    else
      result = Barramento.read('mem',address,qtd)
    end
    return result
  end
  
  # Armazena o valor de value no cache no endereco address
  def Cache.set_value(address, value)
  end

  def get_position(address)
    case (Simulador.get_type_mapping)
      when 0 #mapeamento direto
        return address.to_i.mod(Simulador.get_cache_size)
      when 1 #mapeamento fully-set
      when 2 #mapeamento 2-set
      when 3 #mapeamento 4-set
    end
  end

  def str_concat(str1, str2)
    return (str1.to_i)*256 + str2.to_i
  end

  def fetch_value(address)
    pos = get_position(address)
    block = Simulador.get_block_cache(pos)
    if (block[0] == address + i)
      return block[1]
    end
    return nil
  end

  def update_cache(address)
    case Simulador.get_type_update_cache
    when 0 #write back
      pos = get_position(address.to_i)
      block1 = Simulador.get_block_cache(pos)
      pos = get_position(address.to_i+1)
      block2 = Simulador.get_block_cache(pos)
      #levar o que tem no cache para a memoria
      #trazer novos dados da memoria para o cache
    when 1 #write through
      Memoria.get_value(address,4)
      #trazer novos dados da memoria para o cache
    end
  end
end
