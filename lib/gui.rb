require 'rubygems'
require 'wx'

class SimulatorFrame < Wx::Frame
  MENU_CONF_MEM = 1000
  MENU_SAIR = 1001
  MENU_PREFERENCIAS = 1002
  MENU_SOBRE = 1003

  def initialize()
    super(nil,-1,'Simulador de processadores RISC',
          Wx::Point.new(50,50), Wx::Size.new(800,600))

    panel_main = Wx::Panel.new(self)
    # Layout
    sizer_panel_main = Wx::GridSizer.new(1,2,0,0)
#    sizer_panel_main = Wx::FlexGridSizer.new(2,2,10,10)
#    sizer_panel_main.add_growable_col(1,1) # mescla as celulas da 2a coluna
    panel_main.set_sizer(sizer_panel_main)

    panel1 = Wx::Panel.new(panel_main)
    sizer1 = Wx::GridSizer.new(2,1,0,0)
    panel1.set_sizer(sizer1)

    panel2 = Wx::Panel.new(panel_main)
    sizer2 = Wx::BoxSizer.new(Wx::VERTICAL)
    panel2.set_sizer(sizer2)

    panel_IO = criar_panel_IO(panel_main)
    panel_memoria = criar_panel_memoria(panel_main)
    panel_processador = criar_panel_processador(panel_main)
    
    sizer1.add(panel_IO,2,Wx::ALIGN_CENTER,20)
    sizer1.add(panel_processador,2,Wx::ALIGN_CENTER,20)
    sizer2.add(panel_memoria)

    sizer_panel_main.add(sizer1,2,Wx::ALIGN_CENTER,20)
    sizer_panel_main.add(sizer2,2,Wx::ALIGN_CENTER,20)
    
    barra_menu()
    criar_eventos()

    @teste = 0
  end

  def criar_panel_IO(parent)
    panel_IO = Wx::Panel.new(parent)
    sizer = Wx::BoxSizer.new(Wx::VERTICAL)
    panel_IO.set_sizer(sizer)

    titulo = Wx::StaticText.new(panel_IO,-1,"I/O")
    teste = Wx::TextCtrl.new(panel_IO,-1, "", Wx::DEFAULT_POSITION, Wx::Size.new(300,250))

    sizer.add(titulo,0,Wx::ALIGN_CENTER,0)
    sizer.add(teste,0,Wx::ALIGN_CENTER,0)

    return panel_IO
  end
  
  def criar_panel_processador(parent)
    panel_processador = Wx::Panel.new(parent)
    sizer = Wx::BoxSizer.new(Wx::VERTICAL)
    panel_processador.set_sizer(sizer)

    titulo = Wx::StaticText.new(panel_processador,-1,"Processador")
    teste = Wx::TextCtrl.new(panel_processador,-1, "", Wx::DEFAULT_POSITION, Wx::Size.new(300,250))

    sizer.add(titulo,0,Wx::ALIGN_CENTER,0)
    sizer.add(teste,0,Wx::ALIGN_CENTER,0)


    return panel_processador
  end
  
  def criar_panel_memoria(parent)
    panel_memoria = Wx::Panel.new(parent)
    sizer =  Wx::FlexGridSizer.new(3,2,10,10)
    panel_memoria.set_sizer(sizer)


    
    titulo = Wx::StaticText.new(panel_memoria,-1,"Hierarquia de Memoria")
    #@my_label = Wx::StaticText.new(panel_memoria, -1, 'Aqui sera a memoria cache',Wx::DEFAULT_POSITION, Wx::Size.new(150,150), Wx::ALIGN_CENTER)
	 label_mem =  Wx::StaticText.new(panel_memoria, -1, 'Memória principal',Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::ALIGN_CENTER)
    @my_button = Wx::Button.new(panel_memoria, -1, 'My Button Text')
    @my_grid = Wx::Grid.new(panel_memoria)
    
    @my_grid.create_grid(20,1)
    @my_grid.set_col_label_value(0,'Valor')
    @my_grid.set_default_col_size(100,true)
    #@my_grid.set_margins(15,0)
    @my_grid.set_default_cell_alignment(Wx::ALIGN_CENTRE,Wx::ALIGN_CENTRE)

    sizer.add(titulo,0,Wx::GROW|Wx::ALL,0)
    sizer.add(label_mem, 0, Wx::GROW|Wx::ALL, 2)
    sizer.add(@my_button,0, Wx::GROW|Wx::ALL, 2)
    sizer.add(@my_grid, 0, Wx::GROW|Wx::ALL, 2)
    #sizer.add(@my_label, 0, Wx::GROW|Wx::ALL, 2)

    return panel_memoria
  end
  

  def barra_menu()
    # Cria o menu arquivo
    menu_file = Wx::Menu.new()
    menu_file.append(MENU_CONF_MEM, "&Carregar config. memória", "Teste")
    menu_file.append(MENU_SAIR, "&Sair")
    
    # Cria o menu editar
    menu_edit = Wx::Menu.new()
    menu_edit.append(MENU_PREFERENCIAS, "&Preferências")
    
    # Cria o menu ajuda
    menu_help = Wx::Menu.new()
    menu_help.append(MENU_SOBRE, "&Sobre")

    # Adicionando os menus
    menu_bar = Wx::MenuBar.new()
    menu_bar.append(menu_file, "&Arquivo")
    menu_bar.append(menu_edit, "&Editar")
    menu_bar.append(menu_help, "Aj&uda")

    self.set_menu_bar(menu_bar)
  end

  def criar_eventos()
    evt_menu(MENU_CONF_MEM) { |event| on_file_open(event) }
    evt_menu(MENU_SAIR) { |event| on_quit(event) }
    evt_menu(MENU_PREFERENCIAS) { |event| on_edit_preferences(event) }
    evt_button(@my_button.get_id()) { |event| on_button_click(event)}
  end



  def on_file_open(event)
    # TODO - implementar funçoes do menu Arquivo > "carregar config memoria"
    puts "Arquivo > Carregar config memoria"
  end

  def on_edit_preferences(event)
    puts "Editar > Preferencias"
  end

  def on_button_click(event)
    #@my_label.set_label(@teste.to_s)
    #@my_grid.append_rows()
    @my_grid.set_read_only(@teste,0)
    @my_grid.set_cell_value(@teste,0,"valor #{@teste+1}")
    @teste += 1
    if (@teste % 20 == 0)
      @my_grid.insert_rows(@teste, 20)
    end
  end

  def on_quit(event)
    close(TRUE)
  end

  def on_close(event)
    event.skip()
  end
end

class SimulatorApp < Wx::App
  def on_init
    frame = SimulatorFrame.new
    frame.show()
  end
end

# Executa o loop do programa
SimulatorApp.new.main_loop()
