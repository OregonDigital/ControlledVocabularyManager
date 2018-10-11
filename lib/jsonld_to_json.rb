require "json"

file_contents = File.read('json-ld.dump')

parsed_json = JSON.parse(file_contents)

values = parsed_json["@graph"]

index_object = []

values.each do |row|
  json_object = {}
  json_object["id"] = row["@id"]
  json_object["title"] = row["dc:title"].map{ |el| el["@value"] } unless row["dc:title"].nil?
  json_object["date"] = row["dc:date"]
  json_object["type"] = row["@type"]
  json_object["label"] = row["rdfs:label"]["@value"] unless row["rdfs:label"].nil? || row["rdfs:label"].is_a?(Array)
  json_object["label"] = row["rdfs:label"].map{ |el| el["@value"] } unless row["rdfs:label"].nil? || !row["rdfs:label"].is_a?(Array)
  json_object["comment"] = row["rdfs:comment"]["@value"] unless row["rdfs:comment"].nil?
  json_object["publisher"] = row["dc:publisher"]["@value"] unless row["rdfs:publisher"].nil?
  json_object["alternateName"] = row["schema:alternateName"]["@value"] unless row["schema:alternateName"].nil?
  index_object << JSON.generate(json_object)
end

puts [index_object]
