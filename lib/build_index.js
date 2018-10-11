var lunr = require('lunr'),
    stdin = process.stdin,
    stdout = process.stdout,
    buffer = []

stdin.resume()
stdin.setEncoding('utf8')

stdin.on('data', function (data) {
  buffer.push(data)
})

stdin.on('end', function () {
  var documents = [
    {"id":"http://opaquenamespace.org/ns/TestVocabulary","title":["Testing Vocabulary","Testing Vocabulary Zulu"],"date":"null","type":["http://purl.org/dc/dcam/VocabularyEncodingScheme","rdf:Property","rdfs:Resource"],"label":"Here is a sample label","comment":"Simple comment","alternateName":"asdf"},
    {"id":"http://opaquenamespace.org/ns/TestVocabulary/TestTerm","date":"null","type":["skos:Concept","rdfs:Resource"],"label":"hello","comment":"Testing 1 2"},
    {"id":"http://opaquenamespace.org/ns/TestVocabulary/TestTerm2","date":"Today","type":["skos:Concept","rdfs:Resource"],"label":["Blah2","Blah"],"comment":"Comment","alternateName":"Alt Name"},
    {"id":"http://opaquenamespace.org/ns/TestVocabulary/ValleyLibrary","date":"null","type":"skos:Geographic"},
    {"id":"http://opaquenamespace.org/ns/TestVocabulary/gumj","date":"null","type":["skos:Concept","rdfs:Resource"],"label":"Gum, Josh"},
    {"id":"http://opaquenamespace.org/ns/TestVocabulary/gumk","date":"null","type":["skos:PersonalName","rdfs:Resource"],"label":"Fictitious name"}
  ]

  stdout.write(JSON.stringify(buffer))

  var idx = lunr(function () {
    this.ref('id')
    this.field('title')
    this.field('date')
    this.field('type')
    this.field('label')
    this.field('comment')
    this.field('publisher')
    this.field('alternateName')

    documents.forEach(function (doc) {
      this.add(doc)
    }, this)
  })

  stdout.write(JSON.stringify(idx))
})
