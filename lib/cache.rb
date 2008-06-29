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
    case (Simulador.get_type_mapping)
      when 0 #mapeamento direto
        set_value_directmap(address,value)
      when 1 #mapeamento fully-set
        set_value_fullyset(address, value)
      when 2 #mapeamento 2-set
        set_value_n_set(address, value, 2)
      when 3 #mapeamento 4-set
        set_value_n_set(address, value, 4)
    end
  end

  def update_cache(address)
    case (Simulador.get_type_mapping)
      when 0 #mapeamento direto
        if ( Simulador.get_type_update_cache == 0 ) # Write back
          write_back_mem_directmap(address)
        end
        load_cache_with_mem_directmap(address)
        return Simulador.get_block_cache(get_position(address))[1]
      when 1 #mapeamento fully-set
        pos =  (rand*100).to_i % Simulador.get_cache_size
        if ( Simulador.get_type_update_cache == 0 ) # Write back
          write_back_mem_fullyset(address,pos)
        end
        load_cache_with_mem_fullyset(address,pos)
        return Simulador.get_block_cache(pos.to_s)[1]
      when 2 #mapeamento 2-set
        pos = address.to_i % (Simulador.get_cache_size / 2)
        if ( Simulador.get_type_update_cache == 0 ) # Write back
          write_back_mem_n_set(address,pos,2)
        end
        load_cache_with_mem_n_set(address,pos,2)
        return Simulador.get_block_cache(pos.to_s)[1]
      when 3 #mapeamento 4-set
        pos = address.to_i % (Simulador.get_cache_size / 4)
        if ( Simulador.get_type_update_cache == 0 ) # Write back
          write_back_mem_n_set(address,pos,4)
        end
        load_cache_with_mem_n_set(address,pos,4)
        return Simulador.get_block_cache(pos.to_s)[1]
    end
  end

  def fetch_value(address)
    case (Simulador.get_type_mapping)
      when 0 #mapeamento direto
        return fetch_value_directmap(address)
      when 1 #mapeamento fully-set
        return fetch_value_fullyset(address)
      when 2 #mapeamento 2-set
        return fetch_value_n_set(address,2)
      when 3 #mapeamento 4-set
        return fetch_value_n_set(address,4)
    end
  end

  def set_value_directmap(address, value)
    b = []
    b.push(address)
    b.push(value)
    if ( Simulador.get_type_update_cache == 0 ) # Write back
      old_block = Simulador.get_block_cache(get_position(address))[0]
      if (old_block[0]!=address.to_s && old_block[0]!="-1")
        Barramento.write('mem',block[0],block[1])
      end
      Simulador.set_block_cache(pos,b)
    else # Write Througt
      Simulador.set_block_cache(get_position(address),b)
      Barramento.write('mem',address,value)
    end
  end

  def set_value_fullyset(address, value)
    b = []
    b.push(address)
    b.push(value)
    pos = -1
    for i in 0..(Simulador.get_cache_size - 1)
      block = Simulador.get_block_cache(i.to_s)
      if (block[0].to_i == address.to_i)
        pos = i
        break
      end
    end
    if (pos == -1)
      pos =  (rand*100).to_i % Simulador.get_cache_size
    end
    if ( Simulador.get_type_update_cache == 0 ) # Write back
      old_block = Simulador.get_block_cache(pos)[0]
      if (old_block[0]!=address.to_s && old_block[0]!="-1")
        Barramento.write('mem',block[0],block[1])
      end
      Simulador.set_block_cache(pos,b)
    else # Write Througt
      Simulador.set_block_cache(pos,b)
      Barramento.write('mem',address,value)
    end
  end
  
  def set_value_n_set(address, value,n)
    b = []
    b.push(address)
    b.push(value)
    pos = address.to_i % (Simulador.get_cache_size / n) 
    set = pos
    for i in set..set+(n-1)
      block = Simulador.get_block_cache(i.to_s)
      if (block[0].to_i == address.to_i)
        pos = i
        break
      end
    end
    if ( Simulador.get_type_update_cache == 0 ) # Write back
      old_block = Simulador.get_block_cache(pos)[0]
      if (old_block[0]!=address.to_s && old_block[0]!="-1")
        Barramento.write('mem',block[0],block[1])
      end
      Simulador.set_block_cache(pos,b)
    else # Write Througt
      Simulador.set_block_cache(pos,b)
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

  def fetch_value_directmap(address)
    pos = get_position(address)
    block = Simulador.get_block_cache(pos)
    if (block[0].to_i == address.to_i)
      return block[1]
    end
    return nil
  end

  def fetch_value_fullyset(address)
    for i in 0..(Simulador.get_cache_size - 1)
      block = Simulador.get_block_cache(i.to_s)
      if (block[0].to_i == address.to_i)
        return block[1]
      end
    end
    return nil
  end
  
  def fetch_value_n_set(address,n)
    pos = address.to_i % (Simulador.get_cache_size / n)
    for i in pos..pos+(n-1)
      block = Simulador.get_block_cache(i.to_s)
      if (block[0].to_i == address.to_i)
        return block[1]
      end 
    end
    return nil
  end

  def write_back_mem_directmap(address)
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
          data_to_send = str_concat(data_to_send, block[1])
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

  def write_back_mem_fullyset(address,position)
    cont = 0
    addr_to_send = ''
    data_to_send = ''
    for i in 0..3
      pos = (position + i) % Simulador.get_cache_size
      block = Simulador.get_block_cache(pos)
      if (block[0] != "-1")
        if (cont == 0)
          addr_to_send = block[0]
          data_to_send = block[1]
          cont = 1
        elsif (cont == 1)
          if (block[0].to_i == address.to_i + i)
            data_to_send = str_concat(data_to_send, block[1])
            Barramento.write('mem',addr_to_send,data_to_send,2)
            cont = 0
          else
            Barramento.write('mem',addr_to_send,data_to_send,1)
            addr_to_send = block[0]
            data_to_send = block[1]
            cont = 1
          end
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

  def write_back_mem_n_set(address,pos,n)
    cont = 0
    addr_to_send = ''
    data_to_send = ''
    for i in pos..pos+(n-1)
      block = Simulador.get_block_cache(i)
      if (block[0] != "-1")
        if (cont == 0)
          addr_to_send = block[0]
          data_to_send = block[1]
          cont = 1
        elsif (cont == 1)
          if (block[0].to_i == address.to_i + i)
            data_to_send = str_concat(data_to_send, block[1])
            Barramento.write('mem',addr_to_send,data_to_send,2)
            cont = 0
          else
            Barramento.write('mem',addr_to_send,data_to_send,1)
            addr_to_send = block[0]
            data_to_send = block[1]
            cont = 1
          end
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

  def load_cache_with_mem_directmap(address)
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
  
  def load_cache_with_mem_fullyset(address,pos)
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
        Simulador.set_block_cache(pos % Simulador.get_cache_size, b)
        pos += 1
        b.clear
        b.push(addr_to_get + 1)
        b.push(value - value1*256)
        Simulador.set_block_cache(pos % Simulador.get_cache_size, b)
        pos += 1
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
        Simulador.set_block_cache(pos % Simulador.get_cache_size, b)
        pos += 1
        b.clear
        b.push(addr_to_get + 1)
        b.push(value - value1*256)
        Simulador.set_block_cache(pos % Simulador.get_cache_size, b)
        pos += 1
        b.clear
        cont = 0
      end
      i += 1
    end
  end
  
  def load_cache_with_mem_n_set(address,pos,n)
    cont = 0
    i = 0
    addr_to_get = -1
    while (i < Simulador.get_mem_size and i < n)
      if (cont == 0)
        addr_to_get = address.to_i + i
        cont = 1
      elsif (cont == 1)
        b = []
        value = Barramento.read('mem',addr_to_get,2).to_i
        value1 = value/256
        b.push(addr_to_get)
        b.push(value1)
        Simulador.set_block_cache(pos, b)
        pos += 1
        b.clear
        b.push(addr_to_get + 1)
        b.push(value - value1*256)
        Simulador.set_block_cache(pos, b)
        pos += 1
        b.clear
        cont = 0
      end
      i += 1
    end
    while (i < n)
      if (cont == 0)
        addr_to_get = i
        cont = 1
      elsif (cont == 1)
        b = []
        value = Barramento.read('mem',addr_to_get,2).to_i
        b.push(addr_to_get)
        b.push(value/256)
        Simulador.set_block_cache(pos, b)
        pos += 1
        b.clear
        b.push(addr_to_get + 1)
        b.push(value - value1*256)
        Simulador.set_block_cache(pos, b)
        pos += 1
        b.clear
        cont = 0
      end
      i += 1
    end
  end
end
