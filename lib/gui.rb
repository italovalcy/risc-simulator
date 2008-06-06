require 'gtk2'  
require 'libglade2'  

class Simulador
  def initialize()
    Gtk.init
    @glade = GladeXML.new('layout.glade', nil, 'simulador')  
    window = @glade['simulador_window']
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
    @glade['simulador_window'].signal_connect("destroy") { Gtk.main_quit }  
    @glade['btn_input_hd'].signal_connect( "clicked" ) { input_hd() }
    @glade['btn_input_net'].signal_connect( "clicked" ) { input_net() }
    @glade['btn_input_key'].signal_connect( "clicked" ) { input_key() }
    @glade['btn_iniciar'].signal_connect("clicked") { iniciar_simulacao() }
    
    # Cria os dialogs
    ajuda_sobre = @glade['ajuda_sobre']
    editar_pref = @glade['editar_pref']
    mem_config = @glade['mem_config']
    
    ajuda_sobre.signal_connect("activate") { @glade['sobre_dialog'].show }
    editar_pref.signal_connect("activate") { @glade['pref_dialog'].show }
    mem_config.signal_connect('activate') { @glade['abrir_mem_arq'].show }
    # Destroi os dialogs
    @glade['btn_fechar_pref'].signal_connect('clicked') { pref_dialog.close }
    @glade['btn_cancel_mem_arq'].signal_connect('clicked') { mem_config.close }
  end

  def set_value_rg(reg,value)
    @glade["rg_#{reg}"].text = value
  end

  def set_value_bus_mem(bus,value)
    @glade["bus_#{bus}_p_mem"].text = value
  end

  def set_value_bus_io(bus,value)
    @glade["bus_#{bus}_p_io"].text = value
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
