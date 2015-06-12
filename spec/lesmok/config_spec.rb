require 'lesmok'
describe ::Lesmok::Config do

  it "should lookup cache with fallback" do
    config = described_class.new
    dummy_cache = double
    config.cache = dummy_cache

    expect(config.cache).to be == dummy_cache
    expect(config.find_cache_store).to            be == dummy_cache
    expect(config.find_cache_store(nil)).to       be == dummy_cache
    expect(config.find_cache_store(:default)).to  be == dummy_cache
    expect(config.find_cache_store(:unknown)).to  be == dummy_cache
  end

  it "should allow caching to be toggled dynamically" do
    config = described_class.new
    cache_level = 1
    config.caching_enabled = proc { cache_level > 1 }
    expect(config.caching?).to be false
    cache_level = 2
    expect(config.caching?).to be true
    cache_level = 0
    expect(config.caching?).to be false

  end

end
