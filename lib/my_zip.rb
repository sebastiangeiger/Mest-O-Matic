class MyZip
  class << self
    def unzip_file (file, destination)
      file = file.path if file.is_a? File or file.is_a? Tempfile
      Zip::Archive.open(file) do |ar| #TODO: Clean up empty folders? Against Shadrack style submissions
        ar.each do |zf|
          file_name = File.join(destination,zf.name)
          if zf.directory?
            FileUtils.mkdir_p(file_name)
          else
            dirname = File.dirname(file_name)
            FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
            open(file_name, 'wb') {|f| f << zf.read}
          end
        end
      end#close_file
      destination
    end

    def zip_file(folder, zipped_file)
      FileUtils.rm(zipped_file) if File.exists?(zipped_file) #start with a blank slate
      zip_root = File.basename(zipped_file, ".*")
      Zip::Archive.open(zipped_file, Zip::CREATE) do |ar| 
        ar.add_dir(zip_root)
        Dir.glob("#{folder}/**/*").each do |path|
          zip_path = File.join(zip_root, remove_root_path(path, folder)) 
          if File.directory?(path)
            ar.add_dir(zip_path) 
          else
            ar.add_file(zip_path, path) 
          end
        end
      end
    end

    def remove_root_path(path, root)
      roots = []
      paths = []
      roots = root.split("/").reject{|p| p.empty?} if root
      paths = path.split("/").reject{|p| p.empty?} if path
      while paths.first.eql?(roots.shift) do
        paths.shift
      end
      return paths.join("/")
    end
  end
end
