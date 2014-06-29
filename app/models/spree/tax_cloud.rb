module Spree
	class TaxCloud
		private
		def preference_cache_key(name)
			[self.class.name, name].join('::').underscore
		end
	end
end
