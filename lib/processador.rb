require 'gui'

class Processador
  def initialize
    @had_hlt_instruction = false
  end
  
  def start
    while (not @had_hlt_instruction)
      fetch_next_instruction()
      decode_instruction()
      fetch_operatings()
      run()
      save()
    end
  end

  def wait_clock
    if (Simulador.automatic_clock?)
      sleep 1
    elsif
      while (!Simulador.made_clock?)
        # Waiting for clock event
      end
      Simulador.made_clock = false
    end
  end
  
  def fetch_next_instruction
    wait_clock()
  end

  def decode_instruction
    wait_clock()
  end

  def fetch_operatings
    wait_clock()
  end

  def run
    wait_clock()
  end

  def save
    wait_clock()
  end
end
