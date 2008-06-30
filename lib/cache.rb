require 'gui'
require 'barramento'

class Cache
  def initialize
    @qtd_to_update = 4
  end
  # Retorna o valor contido em alguns endereços do cache
  #   address - endereço inicial do cache
  #   qtd - quantidade de registros que deve ser lidos a 
  #         partir de address
  def get_value(address, qtd)
    address = address.to_i
    result = ''
    if(Simulador.cache_habilitado)
      for i in 0..qtd - 1
        value = fetch_value(address + i)
        if (value == nil)
          # Cache miss
          value = update_cache(address + i)
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
        pos = address % Simulador.get_cache_size
        return Simulador.get_block_cache(pos)[1]
      when 1 #mapeamento fully-set
        pos =  (rand*100).to_i % Simulador.get_cache_size
        if ( Simulador.get_type_update_cache == 0 ) # Write back
          write_back_mem_fullyset(address,pos)
        end
        load_cache_with_mem_fullyset(address,pos)
        return Simulador.get_block_cache(pos.to_s)[1]
      when 2 #mapeamento 2-set
        positions_to_update = compute_positions_to_update(address, 2)
        if ( Simulador.get_type_update_cache == 0 ) # Write back
          write_back_mem_n_set(address, positions_to_update,2)
        end
        load_cache_with_mem_n_set(address, positions_to_update, 2)
        return Simulador.get_block_cache(positions_to_update[0])[1]
      when 3 #mapeamento 4-set
        positions_to_update = compute_positions_to_update(address, 4)
        if ( Simulador.get_type_update_cache == 0 ) # Write back
          write_back_mem_n_set(address, positions_to_update, 4)
        end
        load_cache_with_mem_n_set(address, positions_to_update, 4)
        return Simulador.get_block_cache(positions_to_update[0])[1]
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
    pos = address % Simulador.get_cache_size
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

  def set_value_fullyset(address, value)
    b = []
    b.push(address)
    b.push(value)
    pos = -1
    for i in 0..(Simulador.get_cache_size - 1)
      block = Simulador.get_block_cache(i.to_s)
      if (block[0].to_i == address)
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
    pos_ini = (address % (Simulador.get_cache_size / n))*n
    pos = pos_ini + ((rand*100).to_i % n)
    for i in pos_ini..(pos_ini + n - 1)
      block = Simulador.get_block_cache(i.to_s)
      if (block[0].to_i == address)
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

  def str_concat(str1, str2)
    return (str1.to_i)*256 + str2.to_i
  end

  def fetch_value_directmap(address)
    pos = address % Simulador.get_cache_size
    block = Simulador.get_block_cache(pos)
    if (block[0].to_i == address)
      return block[1]
    end
    return nil
  end

  def fetch_value_fullyset(address)
    for i in 0..(Simulador.get_cache_size - 1)
      block = Simulador.get_block_cache(i.to_s)
      if (block[0].to_i == address)
        return block[1]
      end
    end
    return nil
  end
  
  def fetch_value_n_set(address,n)
    pos_ini = (address % (Simulador.get_cache_size / n))*n
    for i in pos_ini..(pos_ini + n - 1)
      block = Simulador.get_block_cache(i)
      if (block[0].to_i == address)
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
      pos = address % Simulador.get_cache_size
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
          if (block[0].to_i == addr_to_send.to_i + 1)
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

  def write_back_mem_n_set(address, vet_pos,n)
    cont = 0
    addr_to_send = ''
    data_to_send = ''
    for i in 0..(@qtd_to_update - 1)
      block = Simulador.get_block_cache(vet_pos[i])
      if (block[0] != "-1")
        if (cont == 0)
          addr_to_send = block[0]
          data_to_send = block[1]
          cont = 1
        elsif (cont == 1)
          if (block[0].to_i == addr_to_send.to_i + 1)
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
        addr_to_get = address + i
        cont = 1
      elsif (cont == 1)
        b = []
        value = Barramento.read('mem',addr_to_get,2).to_i
        value1 = value/256
        b.push(addr_to_get)
        b.push(value1)
        pos = addr_to_get % Simulador.get_cache_size
        Simulador.set_block_cache(pos, b)
        b.clear
        b.push(addr_to_get + 1)
        b.push(value - value1*256)
        pos = (addr_to_get + 1) % Simulador.get_cache_size
        Simulador.set_block_cache(pos, b)
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
        pos = addr_to_get % Simulador.get_cache_size
        Simulador.set_block_cache(pos, b)
        b.clear
        b.push(addr_to_get + 1)
        b.push(value - value1*256)
        pos = (addr_to_get + 1) % Simulador.get_cache_size
        Simulador.set_block_cache(pos, b)
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
        addr_to_get = address + i
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
  
  def load_cache_with_mem_n_set(address, vet_pos, n)
    cont = 0
    i = 0
    addr_to_get = -1
    while (i < Simulador.get_mem_size and i < @qtd_to_update)
      if (cont == 0)
        addr_to_get = address + i
        cont = 1
      elsif (cont == 1)
        b = []
        value = Barramento.read('mem',addr_to_get,2).to_i
        value1 = value/256
        b.push(addr_to_get)
        b.push(value1)
        Simulador.set_block_cache(vet_pos[i - 1], b)
        b.clear
        b.push(addr_to_get + 1)
        b.push(value - value1*256)
        Simulador.set_block_cache(vet_pos[i], b)
        b.clear
        cont = 0
      end
      i += 1
    end
    while (i < @qtd_to_update)
      if (cont == 0)
        addr_to_get = i
        cont = 1
      elsif (cont == 1)
        b = []
        value = Barramento.read('mem',addr_to_get,2).to_i
        b.push(addr_to_get)
        b.push(value/256)
        Simulador.set_block_cache(vet_pos[i - 1], b)
        b.clear
        b.push(addr_to_get + 1)
        b.push(value - value1*256)
        Simulador.set_block_cache(vet_pos[i], b)
        b.clear
        cont = 0
      end
      i += 1
    end
  end

  def compute_positions_to_update(address, n)
    vet_pos = []
    for i in 0..(@qtd_to_update - 1)
      random =  (rand*100).to_i % n
      pos_ini = ((address + i) % (Simulador.get_cache_size / n))*n
      vet_pos.push(pos_ini + random)
    end
    return vet_pos
  end
end
