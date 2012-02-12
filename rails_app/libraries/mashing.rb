
class Chef
    class Recipe
      def fix_mash_to_hash(mash)
        hash = {}
        mash.each { |key, value| hash[key] = value.is_a?(Mash) ? fix_mash_to_hash(value) : value }
        hash
      end
    end
end
