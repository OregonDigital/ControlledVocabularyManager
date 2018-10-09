require "json"

file_contents = File.read('json-ld.dump')

parsed_json = JSON.parse(file_contents)

values = parsed_json["@graph"]

puts JSON.generate(values)
