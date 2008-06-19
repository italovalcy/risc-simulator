require 'gui'
require 'barramento'

class Cache
  # Retorna o valor contido em alguns endereços do cache
  #   address - endereço inicial do cache
  #   qtd - quantidade de registros que deve ser lidos a 
  #         partir de address
  def get_value(address, qtd)
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
  def set_value(address, value)
    b = []
    b.push(address)
    b.push(value)
    if ( Simulador.get_type_update_cache == 0 ) # Write back
      Simulador.set_block_cache(get_position(address),b)
    else # Write Througt
      Simulador.set_block_cache(get_position(address),b)
      Barramento.write('mem',address,value)
    end
  end

  def get_position(address)
    case (Simulador.get_type_mapping)
      when 0 #mapeamento direto
        return address.to_i % Simulador.get_cache_size
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
    if (block[0].to_i == address.to_i)
      return block[1]
    end
    return nil
  end

  def update_cache(address)
    if ( Simulador.get_type_update_cache == 0 ) # Write back
      write_back_mem(address)
    end
    load_cache_with_mem(address)
    return Simulador.get_block_cache(get_position(address))[1]
  end

  def write_back_mem(address)
    cont = 0
    addr_to_send = ''
    data_to_send = ''
    for i in 0..3
      pos = get_position(address.to_i + i)
      block = Simulador.get_block_cache(pos)
      if (block[0] != "-1")
        if (cont == 0)
          addr_to_send = block[0]
          data_to_send = block[1]
          cont = 1
        elsif (cont == 1)
          data_to_send = str_concat(data_to_send, block[0])
          Barramento.write('mem',addr_to_send,data_to_send,2)
          cont = 0
        end
      else
        if (cont == 1)
          Barramento.write('mem',addr_to_send,data_to_send,1)
          cont = 0
        end
      end
    end
    if (cont == 1)
      Barramento.write('mem',addr_to_send,data_to_send,1)
    end
  end

  def load_cache_with_mem(address)
    # TODO: Ir na memoria e buscar 4 endereços. Atentar-se para o caso em que 
    # estes endereços possam ser inválidos. Ex: address == tam_mem, daí os próximos
    # tres não serão válidos; possível solução: os próximos três serem os três primeiros
    # daí é como se a memoria fosse um vetor circular....
    cont = 0
    i = 0
    addr_to_get = -1
    while (i < Simulador.get_mem_size and i < 4)
      if (cont == 0)
        addr_to_get = address.to_i + i
        cont = 1
      elsif (cont == 1)
        b = []
        value = Barramento.read('mem',addr_to_get,2).to_i
        value1 = value/256
        b.push(addr_to_get)
        b.push(value1)
        Simulador.set_block_cache(get_position(addr_to_get), b)
        b.clear
        b.push(addr_to_get + 1)
        b.push(value - value1*256)
        Simulador.set_block_cache(get_position(addr_to_get + 1), b)
        b.clear
        cont = 0
      end
      i += 1
    end
    while (i < 4)
      if (cont == 0)
        addr_to_get = i
        cont = 1
      elsif (cont == 1)
        b = []
        value = Barramento.read('mem',addr_to_get,2).to_i
        b.push(addr_to_get)
        b.push(value/256)
        Simulador.set_block_cache(get_position(addr_to_get), b)
        b.clear
        b.push(addr_to_get + 1)
        b.push(value - value1*256)
        Simulador.set_block_cache(get_position(addr_to_get + 1), b)
        b.clear
        cont = 0
      end
      i += 1
    end
  end
end
