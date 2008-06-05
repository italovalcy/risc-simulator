require 'gtk2'  
require 'libglade2'  
  
class SignalHandler  
  def method_missing(method, *args)  
    puts "#{method}: #{args}"   
  end  
end  
sigmap = SignalHandler.new  
  
Gtk.init  
glade = GladeXML.new('layout.glade', nil, 'simulador')  
window = glade['simulador_window']
glade.signal_autoconnect_full { |source, target, signal, handler, data, after| puts "#{handler} enviou o sinal: #{signal}" }

# -- Labels --
rg_ax = glade['rg_ax']
rg_ax.text = "1001"
bus_end_p_mem = glade['bus_end_p_mem']
bus_end_p_mem.text = "1001100110011001"
# -- Fim Labels -- 

# ---- Eventos ----

btn_hd = glade['btn_input_hd']
btn_hd.signal_connect( "clicked" ) { puts "Evento gerando pelo HD..." }

btn_net = glade['btn_input_net']
btn_net.signal_connect( "clicked" ) { puts "Evento gerando pela Rede..." }

btn_teclado = glade['btn_input_key']
btn_teclado.signal_connect( "clicked" ) { puts "Evento gerando pelo Teclado..." }

btn_iniciar = glade['btn_iniciar']
btn_iniciar.signal_connect("clicked") { puts "Simulacao iniciada" }

# -- Fim eventos --


window.signal_connect("destroy") { Gtk.main_quit }  
glade.signal_autoconnect_full { |source, target, signal, handler, data| puts "#{handler} enviou o sinal: #{signal}" }
#  source.signal_connect(signal) { sigmap.send(handler, data); puts "#{handler} #{data}" }
  
window.show  
Gtk.main  
