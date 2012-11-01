module CacheBuster
  class Fake
    def purge(urls)
    end
  end
end

Whitehall.cache_buster = CacheBuster::Fake.new
