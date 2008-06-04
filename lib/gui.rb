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
    sizer_panel_main = Wx::FlexGridSizer.new(2,2,10,10)
    sizer_panel_main.add_growable_col(1,1) # mescla as celulas da 2a coluna
    panel_main.set_sizer(sizer_panel_main)

    panel_IO = criar_panel_IO(panel_main)
    panel_memoria = criar_panel_memoria(panel_main)
    panel_processador = criar_panel_processador(panel_main)

    sizer_panel_main.add(panel_IO, 0, Wx::GROW|Wx::ALL, 2)
    sizer_panel_main.add(panel_memoria,0, Wx::GROW|Wx::ALL, 2)
    sizer_panel_main.add(panel_processador, 0, Wx::GROW|Wx::ALL, 2)

    barra_menu()
    criar_eventos()

    @teste = 0
  end

  def criar_panel_IO(parent)
    panel_IO = Wx::Panel.new(parent)
    sizer = Wx::BoxSizer.new(Wx::VERTICAL)
    panel_IO.set_sizer(sizer)

    titulo = Wx::StaticText.new(panel_IO,-1,"I/O")

    sizer.add(titulo,0,Wx::ALIGN_CENTER,0)

    return panel_IO
  end
  
  def criar_panel_memoria(parent)
    panel_memoria = Wx::Panel.new(parent)
    sizer =  Wx::FlexGridSizer.new(2,2,10,10)
    panel_memoria.set_sizer(sizer)

    titulo = Wx::StaticText.new(panel_memoria,-1,"Hierarquia de Memoria")

    sizer.add(titulo,0,Wx::ALIGN_CENTER,0)
    
    @my_label = Wx::StaticText.new(panel_memoria, -1, 'My Label Text',Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::ALIGN_CENTER)
	 label_mem =  Wx::StaticText.new(panel_memoria, -1, 'Memória principal',Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::ALIGN_CENTER)
    @my_button = Wx::Button.new(panel_memoria, -1, 'My Button Text')
    @my_grid = Wx::Grid.new(panel_memoria)
    
    @my_grid.create_grid(20,1)
    @my_grid.set_col_label_value(0,'Valor')
    @my_grid.set_default_col_size(100,true)
	 @my_grid.set_margins(15,0)
	 @my_grid.set_default_cell_alignment(Wx::ALIGN_CENTRE,Wx::ALIGN_CENTRE)

    sizer.add(@my_label, 0, Wx::GROW|Wx::ALL, 2)
    sizer.add(label_mem, 0, Wx::ALIGN_RIGHT, 2)
    sizer.add(@my_button,0, Wx::GROW|Wx::ALL, 2)
    sizer.add(@my_grid, 0, Wx::ALIGN_RIGHT, 2)

    return panel_memoria
  end
  
  def criar_panel_processador(parent)
    panel_processador = Wx::Panel.new(parent)
    sizer = Wx::BoxSizer.new(Wx::VERTICAL)
    panel_processador.set_sizer(sizer)

    titulo = Wx::StaticText.new(panel_processador,-1,"Processador")

    sizer.add(titulo,0,Wx::ALIGN_CENTER,0)

    return panel_processador
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
    @my_label.set_label(@teste.to_s)
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
