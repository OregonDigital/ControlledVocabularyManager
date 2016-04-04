module ControlledVocabManager
  class IsoLanguageTranslator
    
    def self.language_list(format = :symbol)
      language_hash = {}
      if(format == :symbol)
        ISO_639::ISO_639_1.each do |array|
          language_hash[array[2].to_sym] = array[3]
        end
      elsif(format == :string)
        ISO_639::ISO_639_1.each do |array|
          language_hash[array[3]] = array[2].to_sym
        end
      end
      language_hash
    end

    def self.sorted_language_list
      language_list.sort_by{|key, value| value}.to_h
    end

    def self.find_by_name(name)
      language_list(:string)[name.capitalize]
    end

    def self.find_by_symbol(symbol)
      language_list(:symbol)[symbol] ||= "Language Not Found"
    end

  end
end
