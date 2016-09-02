desc "Reconcile differences between git files and the triplestore "
namespace :triplestore_loader do
  task :process => :environment do |t, args|
    write_report = ENV['write_report'] ||= 'true'
    update_triplestore = ENV['update_triplestore'] ||= 'false'
    write_update_file = ENV['write_update_file'] ||= 'false'
    output_dir = ENV['output_dir'] ||= '/tmp'
    file = ENV['file'] ||= ''


    if file.blank?
      puts "Triplestore Loader Rake Task Usage:\n===============================================\n\n"
      puts "Processing arguments:\n"
      puts "write_report=(true|false, default: true) : Write a .log file in the output_dir for differences prior to processing."
      puts "write_update_file=(true|false, default: false) : Write an updated file in the output_dir with updated statements prior to processing."
      puts "update_triplestore=(true|false, default: false) : Update the triplestore to add missing statements that were found in the file during processing."
      puts "output_dir=(full_base_path_to_output_files, default: /tmp) : A directory to write reports, and updated files so as to not pollute the working GIT directory."
      puts "file=(full_path_to_git_master_file, default: '') : The full path to the master .nt file for processing."
      puts "\n\nExamples:"
      puts "Process a single file and only generate a report of the differences."
      puts "rake triplestore_loader:process file=/path/to/git/term.nt\n\n"
      puts "Process a single file, generate the report, generate an updated file, and update the triplestore."
      puts "rake triplestore_loader:process file=/path/to/git/term.nt write_report=true update_triplestore=true write_update_file=true output_dir=/tmp\n\n"
      return
    end

    # Fire up the TriplestoreLoader setting the boolean write* and update* flags appropriately
    loader = TriplestoreLoader.new({ type: Settings.triplestore_adapter.type,
                                     url: Settings.triplestore_adapter.url,
                                     write_report: write_report == 'true',
                                     update_triplestore: update_triplestore == 'true',
                                     write_update_file: write_update_file == 'true',
                                     output_dir: output_dir
                                   })
    loader.process(file)
  end
end
