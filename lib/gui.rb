require 'gtk2'  
require 'libglade2'  

class Simulador
  def initialize()
    @made_clock = false
    @tam_mem = 64
    @tam_cache = 16

    Gtk.init
    @@glade = GladeXML.new('layout.glade', nil, 'simulador')  
    window = @@glade['simulador_window']
    make_gridview(@@glade['gridview_cache'],@tam_cache)
    make_gridview(@@glade['gridview_mem'],@tam_mem)
    set_events()
    window.show
  end

  def show
    Gtk.main
  end
 
  def make_gridview(view,tam)
    list = Gtk::ListStore.new(String,String)

    # Adiciona elementos a lista
    for i in 0..tam - 1
      iter = list.append
      iter[0] = i.to_s
      iter[1] = "0"
    end

    r1 = Gtk::CellRendererText.new
    r2 = Gtk::CellRendererText.new
    c1 = Gtk::TreeViewColumn.new("",r1, :text => 0)
    c2 = Gtk::TreeViewColumn.new("Value",r2, :text => 1)
    
    view.append_column(c1)
    view.append_column(c2)
    view.selection.mode = Gtk::SELECTION_NONE
    view.model = list
  end

  def resize_gridview(view,tam_new)
    list = view.model
    if (@tam_mem < tam_new )
      for i in @tam_mem..tam_new - 1
        iter = list.append
        iter[0] = i.to_s
        iter[1] = "0"
      end
    else
      while (@tam_mem >= tam_new)
        @tam_mem -= 1
        list.remove(list.get_iter(@tam_mem.to_s))
      end
    end
    @tam_mem = tam_new
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
    @@glade['sobre_dialog'].signal_connect("response") { |s,r| if (r==Gtk::Dialog::RESPONSE_CANCEL); s.hide; end }
    @@glade['pref_dialog'].signal_connect("delete_event") { @@glade['pref_dialog'].hide }
    @@glade['btn_fechar_pref'].signal_connect("clicked") { event_fechar_pref() }
    @@glade['abrir_mem_arq'].signal_connect("delete_event") { @@glade['abrir_mem_arq'].hide }
    @@glade['btn_cancel_mem_arq'].signal_connect("clicked") { @@glade['abrir_mem_arq'].hide }
  end

  def event_fechar_pref
    @@glade['pref_dialog'].hide
    if (@@glade['mem_size'].text.to_i != @tam_mem)
      resize_gridview(@@glade['gridview_mem'],@@glade['mem_size'].text.to_i)
    end
    if (@@glade['cache_size'].active_text.to_i != @tam_mem)
      resize_gridview(@@glade['gridview_cache'], @@glade['cache_size'].active_text.to_i)
    end
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

  def iniciar_simulacao
    puts "Simulacao iniciada..."
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
