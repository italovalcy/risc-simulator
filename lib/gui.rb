require 'gtk2'  
require 'libglade2'
require 'arquivo'
require 'processador'

class Simulador
  def initialize()
    @made_clock = false
    @tam_mem = 64
    @tam_cache = 16
    @tam_io = 64
    @thread_proc = nil
    # t_config define onde serao aplicadas
    # as configuracoes que um determinado arquivo
    # traz. Seus valores possíveis são: 'mem', 'io'
    @t_config = '' 

    Gtk.init
    @@glade = GladeXML.new('layout.glade', nil, 'simulador')  
    window = @@glade['simulador_window']
    initializa_configs()
    make_gridview(@@glade['gridview_cache'],@tam_cache)
    make_gridview(@@glade['gridview_mem'],@tam_mem)
    make_gridview(@@glade['gridview_io'],@tam_io)
    initialize_registers()
    initialize_bus()
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
	@@glade['cache_atualizacao'].active = 0
    @@glade['io_size'].value = @tam_io
    @@glade['mem_size'].value = @tam_mem
    @@glade['sleep_clock'].value = 1
    buffer = Gtk::TextBuffer.new
    buffer.text = ""
    @@glade['txt_ula'].buffer = buffer
    @@glade['txt_ula'].editable = false
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
  #   view - TreeView que sera usada para armazenar os valores do arquivo
  def carregar_arq(file_dialog, view)
    if (file_dialog.filename == "")
      return false
    end
    dados = Arquivo.read(file_dialog.filename)
    dados.each do |e|
      line = e.split(':')
      gridview_set_value(view,line[0],line[1])
    end
    return true
  end

  def Simulador.get_value_memoria(address)
    model = @@glade['gridview_mem'].model
    iter = model.get_iter("#{address}")
    return iter[1]
  end

  def get_value_cache()
  end

  # Insere valores numa treeview
  # Entrada:
  #   view - a treeview onde deseja-se inserir os valores
  #   address - endereco da linha onde deseja-se inserir
  #   value - valor que deseja-se inserir
  def gridview_set_value(view,address,value)
    iter = view.model.get_iter(address)
    iter[1] = value
  end

  def set_events
    @@glade['simulador_window'].signal_connect("destroy") { Gtk.main_quit }  
    @@glade['btn_sair'].signal_connect("activate") { Gtk.main_quit }  
    @@glade['btn_input_hd'].signal_connect( "clicked" ) { input_hd() }
    @@glade['btn_input_net'].signal_connect( "clicked" ) { input_net() }
    @@glade['btn_input_key'].signal_connect( "clicked" ) { input_key() }
    @@glade['btn_iniciar'].signal_connect("clicked") { iniciar_simulacao() }
    @@glade['btn_stop'].signal_connect("clicked") { finaliza_simulacao() }
    @@glade['btn_abrir_arq'].signal_connect("clicked") do
      carregar_arq(@@glade['abrir_arq'],@@glade["gridview_#{@t_config}"])
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

  def event_fechar_pref
    @@glade['pref_dialog'].hide
    if (! @@glade['mem_size'].text.to_i.equal? @tam_mem)
      @tam_mem = resize_gridview(@@glade['gridview_mem'], @tam_mem, @@glade['mem_size'].text.to_i)
    end
    if (! @@glade['cache_size'].active_text.to_i.equal? @tam_cache)
      @tam_cache = resize_gridview(@@glade['gridview_cache'], @tam_cache, @@glade['cache_size'].active_text.to_i)
    end
    if (! @@glade['io_size'].text.to_i.equal? @tam_io)
      @tam_io = resize_gridview(@@glade['gridview_io'], @tam_io, @@glade['io_size'].text.to_i)
    end
  end

  def event_clear
    initialize_registers()
    initialize_bus()
    @@glade['txt_ula'].buffer.text = ""
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

  def Simulador.get_sleep_clock
    return @@glade['sleep_clock'].text.to_i
  end

  def Simulador.set_log_ula(value)
    @@glade['txt_ula'].buffer.text = value
  end

  def made_clock
    if (@thread_proc != nil )
      @thread_proc.run
    end
  end
  
  def set_made_clock(x)
    @made_clock = x
  end

  def Simulador.automatic_clock?
    return @@glade['clock_type'].active_text == "Automatico"
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
