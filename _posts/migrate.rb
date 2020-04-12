# migrate image tags

["*markdown", "*md"].each do |r|
  Dir.glob(r).each do |fname|
    string = File.read(fname)

    string.each_line do |line|
      puts line
      if line.match(/\{\%img\s+(\w+)\s+\'(.*)\'\%\}/)
      end
    end
  end
end




