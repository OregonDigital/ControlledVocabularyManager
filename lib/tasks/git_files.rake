namespace :git_files do
  desc "Duplicate a file, after fixing its ID, prepares a new file for injecting into triplestore"
  task fix: :environment do
    include GitInterface

    source_file = ENV['source_file'] ||= nil
    replacement_character = ENV['replacement_character'] ||= '-'
    find_string = ENV['find_string'] ||= nil

    if source_file.nil?
      puts "Missing source_file parameter. (ie. rake git_files:fix source_file=./path/to/git_dir/vocab/term.nt)"
      return
    end

    file_string = File.read(source_file)

    # TODO: eliminate this hack to fix some invalid statements
    file_string.gsub!("https://schema.org/alternateName", "http://schema.org/alternateName") if file_string.include? "https://schema.org/alternateName"

    lines = file_string.split("\n")
    # grab the "subject" of the first statement of the file to use for capture matching the uri
    # (ie. <http://opaquenamespace.org/ns/workType/Altai/rays>)
    # matches[1] = "<http://opaquenamespace.org/ns/workType/"
    # matches[2] = "Altai/rays"
    # matches[3] = ">"
    matches = /(<http:\/\/opaquenamespace.org\/ns\/\w+\/)(.+)(>)/.match(lines.first.split(' ').first)

    if find_string.nil?
      # substitute non-word non-dash characters with the replacement_character
      # Altai/rays becomes Altai-rays
      fixed_id = matches[2].gsub(/[^a-zA-Z0-9_\-]/, replacement_character)
    else
      fixed_id = matches[2].gsub(find_string, replacement_character)
    end

    modified_lines = []

    # iterate through each line, split on spaces, reform the first part (subject) to replace the old
    # id (match[2]) with the new fixed_id.. rejoin the parts with a space character and append to new array
    lines.each do |line|
      parts = line.split(' ')
      parts[0] = [matches[1], fixed_id, matches[3]].join('')
      modified_lines << "#{parts.join(' ')}\n"
    end

    file_parts = source_file.split('/')
    original_file_name = file_parts.pop()

    # create a path to the new file
    # original: ./opaquenamespace-data/workType/Altai%2ftamga.nt
    # fixed: ./opaquenamespace-data/workType/Altai-tamga.nt
    new_file_name = "#{file_parts.join('/')}/#{fixed_id}.nt"

    # write the new ntriples file
    File.open(new_file_name, "w") do |f|
      f.write(modified_lines.join(''))
    end

    File.open("/tmp/#{fixed_id}.nt.log", "w") do |f|
      f.write "====Original====\n"
      f.write lines.join("\n")
      f.write "\n\n====Modified====\n"
      f.write modified_lines.join('')
      f.write "\n====Original:#{original_file_name}, Modified:#{fixed_id}.nt, Wrote File:#{new_file_name}"
    end
    puts "Finished processing #{new_file_name}, see /tmp/#{fixed_id}.nt.log for details"
  end

  desc "Inspect directory and sub-directories for ntriples with disallowed IDs"
  task inspect: :environment do
    directory = ENV["directory"] ||= nil

    if directory.nil?
      puts "Missing directory parameter. (ie. task git_files:inspect directory=./path/to/git_dir/)"
      return
    end

    paths = File.join(directory, "/**/*")
    Dir.glob(paths) do |file_path|
      if File.fnmatch?("*.nt", file_path)
        file_name = file_path.to_s.split("/").last.gsub(".nt", "")
        unless file_name.match(/^[a-zA-Z0-9_\-]*$/).present?
          puts file_path
        end
      end
    end
  end
end
