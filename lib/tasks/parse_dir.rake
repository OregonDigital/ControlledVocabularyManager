namespace :parse_git do
  task :dir, [:arg1] do |t, args|
    new_args = "**" + args[:arg1].to_s + "/**/*"
    Dir.glob(new_args) do |file|
      if File.fnmatch?("*.nt", file)
        file_name = file.to_s.split("/").last.gsub(".nt", "")
        unless file_name.match(/^[a-zA-Z0-9_\-]*$/).present?
          puts file
        end
      end
    end 
  end
end
