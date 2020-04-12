
# migrate image tags

["*markdown", "*md"].each do |r|
  Dir.glob(r).each do |fname|
    string = File.read(fname)
    new_file = ""
    
    string.each_line do |line|
      if line.match(/{% img/) || line.match(/{%img/)
        if line.match(/(\/.*\.JPG)/)
          img_fname = line.match(/(\/.*\.JPG)/)[1]
          img_label = line.match(/['"](.*)['"]/)[1]

          puts "fname: #{img_fname} label: #{img_label}."
          new_file << "![/assets/#{img_fname}][#{img_label}]\n"
        elsif line.match(/(\/.*\.gif)/)
          img_fname = line.match(/(\/.*\.gif)/)[1]
          puts line
          img_label = line.match(/['"](.*)['"]/)[1]

          puts "fname: #{img_fname} label: #{img_label}."
          new_file << "![/assets/#{img_fname}][#{img_label}]\n"
        elsif line.match(/(\/.*\.png)/)
          img_fname = line.match(/(\/.*\.png)/)[1]
          puts line
          img_label = line.match(/['"](.*)['"]/)
          if img_label
            img_label = line.match(/['"](.*)['"]/)[1]
          else
            img_label = "label"
          end

          puts "fname: #{img_fname} label: #{img_label}."
          new_file << "![/assets/#{img_fname}][#{img_label}]\n"
        end
      else
        new_file << line
      end
    end

    File.write(fname, new_file, mode: 'w+')
  end
end


