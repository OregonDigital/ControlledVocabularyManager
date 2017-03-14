require 'csv'
require 'rdf'

desc "Transforms CSV to JSONLD for ingest. Use `rake transform:csv_to_jsonld[path_to_csv, path`"
namespace :transform do
  task :csv_to_jsonld, [:csv_path, :text_path] => :environment do |t, args|
    @row_hash = {
      "@context": {
        "dc": "http://purl.org/dc/terms/",
        "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
        "skos": "http://www.w3.org/2004/02/skos/core#",
        "xsd": "http://www.w3.org/2001/XMLSchema#"
      },
      "@graph": [],
    } 
    @csv_headers = ["id:id_hash", "vocabulary:uri", "label:string", "combined_dates:datetime"]

    check_args(args) 
    @array_hash = extract_headers(@csv_headers, args)
    @jsonld2 = build_graph(args, @array_hash, @csv_headers)

    File.open(args[:text_path], 'w') { |file| file.write(@jsonld)}
  end
end

def check_args(args)
  unless args[:csv_path] 
    puts "Must provide full path to csv file. (e.g. /Users/username/Desktop/my_csv.csv"
    exit
  end

  unless args[:text_path] 
    puts "Must provide full path to empty text file. (e.g. /Users/username/Desktop/my_text_file.txt"
    exit
  end
end

def extract_headers(csv_headers, args)
  @first_row = CSV.open(args[:csv_path], &:readline)
  @array_hash = Hash.new

  @first_row.each_with_index do |header, index|
    unless @csv_headers.include?(header)
      puts "Your CSV File format is improper. '#{header}' is not a header in your file."
      puts "Please format your CSV file with the headers as such.  'id:id_hash' | 'vocabulary:uri' | 'label:string' | 'combined_dates:datetime'"
      exit
    end
    @array_hash[header.split(":").first] = index
  end
  @array_hash
end

def build_graph(args, array_hash, headers)
  @graph = RDF::Graph.new
  CSV.foreach(args[:csv_path]) do |row| 
    if row.include?("label:string")
      next
    end
    unless row[array_hash["id"]].nil?
      @id = send(headers.first.split(":").last, nil, array_hash, @graph, row)
      headers.each do |header|
        send(header.split(":").last, @id, array_hash, @graph, row)
      end
      types(@id, array_hash, @graph, row)
    end
  end
  puts @graph.dump(:jsonld)
end

def string(id, array_hash, graph, row)
  graph << RDF::Statement.new(id, RDF::RDFS.label, row[array_hash["label"]]) 
end

def datetime(id, array_hash, graph, row)
  graph << RDF::Statement.new(id, RDF::Vocab::DC.date, row[array_hash["combined_dates"]]) 
  graph << RDF::Statement.new(id, RDF::DC.issued, Date.today) 
end

def id_hash(id, array_hash, graph, row)
  if row[array_hash["id"]].nil?
    o = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
    string = (0...7).map { o[rand(o.length)] }.join
    row[array_hash["id"]] = string
    return string
  end
  return uri(id, array_hash, graph, row) 
end

def uri(id, array_hash, graph, row)
  RDF::URI("#{row[array_hash["vocabulary"]]}#{row[array_hash["id"]]}")
end

def types(id, array_hash, graph, row)
  @graph << RDF::Statement.new(id, RDF.type, RDF::URI("http://www.w3.org/2004/02/skos/core#CorporateName")) 
  @graph << RDF::Statement.new(id, RDF.type, RDF::URI("http://www.w3.org/2000/01/rdf-schema#Resource")) 
end
