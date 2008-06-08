require 'gtk2'  
require 'libglade2'  

class Simulador
  def initialize()
    @made_clock = false

    Gtk.init
    @@glade = GladeXML.new('layout.glade', nil, 'simulador')  
    window = @@glade['simulador_window']
    set_events()
    window.show
  end

  def show
    Gtk.main
  end
  
  def iniciar_simulacao
    puts "Simulacao iniciada..."
  end

  def set_events
    @@glade['simulador_window'].signal_connect("destroy") { Gtk.main_quit }  
    @@glade['btn_input_hd'].signal_connect( "clicked" ) { input_hd() }
    @@glade['btn_input_net'].signal_connect( "clicked" ) { input_net() }
    @@glade['btn_input_key'].signal_connect( "clicked" ) { input_key() }
    @@glade['btn_iniciar'].signal_connect("clicked") { iniciar_simulacao() }
    @@glade['btn_clock'].signal_connect("clicked") { @made_clock = true }

    # Torna os dialogs visiveis ao serem chamados
    @@glade['mem_config'].signal_connect("activate") { @@glade['abrir_mem_arq'].show }
    @@glade['ajuda_sobre'].signal_connect("activate") { @@glade['sobre_dialog'].show }
    @@glade['editar_pref'].signal_connect("activate") { @@glade['pref_dialog'].show }

    # Oculta os dialogs ao serem fechados
    @@glade['sobre_dialog'].signal_connect("delete_event") { @@glade['sobre_dialog'].hide }
    @@glade['sobre_dialog'].signal_connect("close") { @@glade['sobre_dialog'].hide }
    @@glade['pref_dialog'].signal_connect("delete_event") { @@glade['pref_dialog'].hide }
    @@glade['btn_fechar_pref'].signal_connect("clicked") { @@glade['pref_dialog'].hide }
    @@glade['abrir_mem_arq'].signal_connect("delete_event") { @@glade['abrir_mem_arq'].hide }
    @@glade['btn_cancel_mem_arq'].signal_connect("clicked") { @@glade['abrir_mem_arq'].hide }
  end


  def Simulador.set_value_rg(reg,value)
    @@glade["rg_#{reg}"].text = value
  end

  def Simulador.get_value_rg(reg,value)
    return @@glade["rg_#{reg}"].text
  end


  def Simulador.set_value_bus_mem(bus,value)
    @@glade["bus_#{bus}_p_mem"].text = value
  end

  def Simulador.get_value_bus_mem(bus,value)
    return @@glade["bus_#{bus}_p_mem"].text
  end


  def Simulador.set_value_bus_io(bus,value)
    @@glade["bus_#{bus}_p_io"].text = value
  end

  def Simulador.set_value_bus_io(bus,value)
    return @@glade["bus_#{bus}_p_io"].text
  end

  def Simulador.wait_clock
    if (automatic_clock?)
      sleep 1
    elsif
      while (!made_clock?)
        # Waiting for clock event
      end
      made_clock = false
    end
  end
  
  def made_clock?
    return @made_clock
  end

  def set_made_clock(x)
    @made_clock = x
  end

  def Simulador.automatic_clock?
    return @@glade['clock_type'].get_active_text == "Automatico"
  end


  def input_hd
    puts "Evento gerado pelo HD..."
  end

  def input_net
    puts "Evento gerando pela Rede..."
  end

  def input_key
    puts "Evento gerando pelo Teclado..."
  end
end

w = Simulador.new
w.show
