
class Chef
    class Resource
      class Template
        def fix_mash_to_hash(mash, symbolise = false)
          hash = {}
          mash.each do |key, value| 
            new_key = symbolise ? key.to_sym : key
            hash[new_key] = value.is_a?(Mash) ? fix_mash_to_hash(value, symbolise) : value 
          end
          hash
        end
      end
    end
end
