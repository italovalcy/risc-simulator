class Arquivo
  def Arquivo.read(arq)
    r = []
    File.open(arq) do |txt|
      txt.each_line do |line|
        r.push line.chomp
      end
    end
    return r
  end
end
