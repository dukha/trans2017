module Paperclip
  class Parseyaml < Processor
    @@tempdir = "tmp/paperclip/"
    def initialize file, options = {}, attachment = nil
      #binding.pry
      @file           = file
      
      
      
      @options        = options
      @attachment       = attachment
      puts "init postpostx"
    end
    
    def make
      if not Dir.exists?( @@tempdir) then
        Dir.mkdir(@@tempdir, 777)
      end  
      tempfile_path =  @@tempdir +  Time.now.strftime("%Y%m%d%H%M%S%9N") + ".yml"
      binding.pry
      FileUtils.cp(@file.path, tempfile_path)
      FileUtils.chmod(0777, tempfile_path)
      #binding.pry
      #@file.rewind
      #file_content = File.read(@file.path)
      #@file.rewind
      tempfile_contents = File.read(tempfile_path) 
      puts tempfile_content
      #File.delete(@tempfile_path)
    end
  end
end
