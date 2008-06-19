require 'gtk2'  
require 'libglade2'
require 'arquivo'
require 'processador'

class Simulador
  def initialize()
    @@tam_mem = 64
    @@tam_cache = 16
    @@tam_io = 64
    @thread_proc = nil
    @@count_clock = 0
    # t_config define onde serao aplicadas
    # as configuracoes que um determinado arquivo
    # traz. Seus valores possíveis são: 'mem', 'io'
    @t_config = ''

    Gtk.init
    @@glade = GladeXML.new('layout.glade', nil, 'simulador')  
    window = @@glade['simulador_window']
    initializa_configs()
    make_cache(@@tam_cache)
    make_gridview(@@glade['gridview_mem'],@@tam_mem)
    make_gridview(@@glade['gridview_io'],@@tam_io)
    initialize_registers()
    initialize_bus()
    set_events()
    window.show
  end

  def show
    Gtk.main
  end


  ##
  ## METODOS INTERNOS
  ##
  
  def made_clock
    if (@thread_proc != nil )
      @thread_proc.run
    end
  end

  def make_cache(tam)
    view = @@glade['gridview_cache']
    list = Gtk::ListStore.new(String,String,String)

    # Adiciona elementos a lista
    for i in 0..tam - 1
      iter = list.append
      iter[0] = i.to_s
      iter[1] = "-1"
      iter[2] = "0"
    end

    r1 = Gtk::CellRendererText.new
    r2 = Gtk::CellRendererText.new
    r3 = Gtk::CellRendererText.new
    c1 = Gtk::TreeViewColumn.new("Id",r1, :text => 0)
    c2 = Gtk::TreeViewColumn.new("Addr",r2, :text => 1)
    c3 = Gtk::TreeViewColumn.new("Value",r3, :text => 2)
    
    view.append_column(c1)
    view.append_column(c2)
    view.append_column(c3)
    view.selection.mode = Gtk::SELECTION_NONE
    view.model = list
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
    c1 = Gtk::TreeViewColumn.new("Id",r1, :text => 0)
    c2 = Gtk::TreeViewColumn.new("Value",r2, :text => 1)
    
    view.append_column(c1)
    view.append_column(c2)
    view.selection.mode = Gtk::SELECTION_NONE
    view.model = list
  end

  # De acordo ao valor dos parametros, esta funcao diminui ou aumenta
  # o numero de elementos numa treeview.
  # Entrada:
  #   view - A treeview que se deseja aumentar ou diminuir.
  #   tam_old - o tamanho atual.
  #   tam_new - o novo tamanho que se deseja.
  # Retorno
  #   tam_new - o novo tamanho.
  def resize_gridview(view, tam_old, tam_new)
    list = view.model
    if (tam_old < tam_new )
      for i in tam_old..tam_new - 1
        iter = list.append
        iter[0] = i.to_s
        iter[1] = "0"
      end
    else
      while (tam_old > tam_new)
        tam_old -= 1
        list.remove(list.get_iter(tam_old.to_s))
      end
    end
    return tam_new
  end

  def initializa_configs
    # Configura valores defaults
    @@glade['clock_type'].active = 0
    @@glade['cache_size'].active = 0
    @@glade['cache_mapeamento'].active = 0
    @@glade['cache_atualizacao'].active = 1
    @@glade['cache_habilitado'].active = true
    @@glade['io_size'].value = @@tam_io
    @@glade['mem_size'].value = @@tam_mem
    @@glade['sleep_clock'].value = 1
    buffer = Gtk::TextBuffer.new
    buffer.text = ""
    @@glade['txt_ula'].buffer = buffer
    @@glade['txt_ula'].editable = false
    @@glade['statusbar'].push(1,"Pulsos de clock: 0")
  end

  def initialize_registers()
    ['ax','bx','cx','dx','flags','ip','ri'].each do |rg|
      Simulador.set_value_rg(rg,"0")
    end
  end

  def initialize_bus()
    ['end','con','data'].each do |type|
      Simulador.set_value_bus("mem",type,"0")
      Simulador.set_value_bus("io",type,"0")
    end
  end

  # Ler dados de um arquivo e armazena numa ListStore
  # Entrada:
  #   file_dialog - Dialog que foi usado para carregar o arquivo
  #   name_view - TreeView que sera usada para armazenar os valores do arquivo
  def carregar_arq(file_dialog, name_view)
    if (file_dialog.filename == "")
      return false
    end
    dados = Arquivo.read(file_dialog.filename)
    dados.each do |e|
      line = e.split(':')
      Simulador.set_value_grid(name_view,line[0],line[1])
    end
    return true
  end

  def set_events
    @@glade['simulador_window'].signal_connect("destroy") { Gtk.main_quit }  
    @@glade['btn_sair'].signal_connect("activate") { Gtk.main_quit }  
    @@glade['btn_input_hd'].signal_connect( "clicked" ) { event_input_hd() }
    @@glade['btn_input_net'].signal_connect( "clicked" ) { event_input_net() }
    @@glade['btn_input_key'].signal_connect( "clicked" ) { event_input_key() }
    @@glade['btn_iniciar'].signal_connect("clicked") { iniciar_simulacao() }
    @@glade['btn_stop'].signal_connect("clicked") { finaliza_simulacao() }
    @@glade['btn_abrir_arq'].signal_connect("clicked") do
      carregar_arq(@@glade['abrir_arq'],@t_config)
      @@glade['abrir_arq'].hide
    end
    @@glade['btn_clock'].signal_connect("clicked") { made_clock() }
    @@glade['btn_clear'].signal_connect("clicked") { event_clear() }

    # Torna os dialogs visiveis ao serem chamados
    @@glade['mem_config'].signal_connect("activate") { @@glade['abrir_arq'].show; @t_config = 'mem' }
    @@glade['io_config'].signal_connect("activate") { @@glade['abrir_arq'].show; @t_config = 'io' }
    @@glade['ajuda_sobre'].signal_connect("activate") { @@glade['sobre_dialog'].show }
    @@glade['editar_pref'].signal_connect("activate") { @@glade['pref_dialog'].show }

    # Oculta os dialogs ao serem fechados
    @@glade['sobre_dialog'].signal_connect("delete_event") { @@glade['sobre_dialog'].hide }
    @@glade['sobre_dialog'].signal_connect("response") { |s,r| if (r==Gtk::Dialog::RESPONSE_CANCEL); s.hide; end }
    @@glade['pref_dialog'].signal_connect("delete_event") { @@glade['pref_dialog'].hide }
    @@glade['btn_fechar_pref'].signal_connect("clicked") { event_fechar_pref() }
    @@glade['abrir_arq'].signal_connect("delete_event") { @@glade['abrir_arq'].hide; @t_config = '' }
    @@glade['btn_cancel_arq'].signal_connect("clicked") { @@glade['abrir_arq'].hide; @t_config = '' }
  end


  ##
  ## TRATAMENTO DE EVENTOS
  ##

  def event_fechar_pref
    @@glade['pref_dialog'].hide
    if (! @@glade['mem_size'].text.to_i.equal? @@tam_mem)
      @@tam_mem = resize_gridview(@@glade['gridview_mem'], @@tam_mem, @@glade['mem_size'].text.to_i)
    end
    if (! @@glade['cache_size'].active_text.to_i.equal? @@tam_cache)
      @@tam_cache = resize_gridview(@@glade['gridview_cache'], @@tam_cache, @@glade['cache_size'].active_text.to_i)
    end
    if (! @@glade['io_size'].text.to_i.equal? @@tam_io)
      @@tam_io = resize_gridview(@@glade['gridview_io'], @@tam_io, @@glade['io_size'].text.to_i)
    end
  end

  def event_clear
    initialize_registers()
    initialize_bus()
    @@glade['txt_ula'].buffer.text = ""
    @@count_clock = 0
    @@glade['statusbar'].push(1,"Pulsos de clock: 0")
  end
  
  def event_input_hd
    puts "Evento gerado pelo HD..."
  end

  def event_input_net
    puts "Evento gerando pela Rede..."
  end

  def event_input_key
    puts "Evento gerando pelo Teclado..."
  end


  ##
  ## METODOS ESTATICOS
  ##

  def Simulador.get_value_grid(name, address)
    model = @@glade["gridview_#{name}"].model
    iter = model.get_iter("#{address}")
    if (iter != nil)
      return iter[1]
    else
      return nil
    end
  end
  
  def Simulador.get_block_cache(address)
    result = []
    model = @@glade["gridview_cache"].model
    iter = model.get_iter("#{address}")
    if (iter != nil)
      result.push(iter[1])
      result.push(iter[2])
      return result
    else
      return nil
    end
  end
  
  def Simulador.set_block_cache(address, block)
    model = @@glade["gridview_cache"].model
    iter = model.get_iter("#{address}")
    iter[1] = block[0].to_s
    iter[2] = block[1].to_s
  end
  
  def Simulador.set_value_grid(name, address, value)
    model = @@glade["gridview_#{name}"].model
    iter = model.get_iter("#{address}")
    iter[1] = value.to_s
  end
  
  def Simulador.set_value_rg(reg,value)
    @@glade["rg_#{reg}"].text = value.to_s
  end

  def Simulador.get_value_rg(reg)
    return @@glade["rg_#{reg}"].text
  end

  def Simulador.set_value_bus(type,bus,value)
    @@glade["bus_#{bus}_p_#{type}"].text = value.to_s
  end

  def Simulador.get_value_bus(type,bus)
    return @@glade["bus_#{bus}_p_#{type}"].text
  end

  def Simulador.set_log_ula(value)
    @@glade['txt_ula'].buffer.text = value
  end
  
  def Simulador.get_type_mapping
    return @@glade['cache_mapeamento'].active
  end

  def Simulador.get_type_update_cache
    return @@glade['cache_atualizacao'].active
  end

  def Simulador.get_cache_size
    return @@tam_cache
  end
  
  def Simulador.get_mem_size
    return @@tam_mem
  end

  def Simulador.cache_habilitado
    return @@glade['cache_habilitado'].active?
  end

  def Simulador.get_clock
    if (@@glade['clock_type'].active_text == "Automatico")
      sleep @@glade['sleep_clock'].text.to_i
    else
      Processador.pause
    end
    @@count_clock += 1
    @@glade['statusbar'].push(1,"Pulsos de clock: #{@@count_clock}")
  end



  def iniciar_simulacao
    if (@@glade['clock_type'].active_text == "Manual")
      @@glade['btn_clock'].sensitive = true
    end
    @@glade['btn_stop'].sensitive = true
    @@glade['btn_clear'].sensitive = false
    @@glade['btn_iniciar'].sensitive = false
    @@glade['mem_config'].sensitive = false
    @@glade['io_config'].sensitive = false
    @@glade['editar_pref'].sensitive = false
    event_clear()
    @thread_proc = Thread.new do
      p = Processador.new
      p.start
      finaliza_simulacao()
    end
  end

  def finaliza_simulacao
    @@glade['btn_clear'].sensitive = true
    @@glade['btn_iniciar'].sensitive = true
    @@glade['mem_config'].sensitive = true
    @@glade['io_config'].sensitive = true
    @@glade['editar_pref'].sensitive = true
    @@glade['btn_stop'].sensitive = false
    @@glade['btn_clock'].sensitive = false
    if (@thread_proc != nil )
      @thread_proc.kill
    end
  end
end
