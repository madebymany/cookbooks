
class Chef
    class Resource
      class Template
        def fix_mash_to_hash_and_symbol(mash)
          hash = {}
          mash.each do |key, value| 
            hash[key.to_sym] = value.is_a?(Mash) ? fix_mash_to_hash_and_symbol(value) : value 
          end
          hash
        end
      end
    end
end
