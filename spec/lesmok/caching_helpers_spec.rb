require 'lesmok'
describe ::Lesmok::Caching::Helpers do

  describe described_class::ExpiryCalculation do
    it "should calculate expiry" do
      exp = described_class.calculate_expiry
      expect(exp).to be >= 300
      expect(exp).to be <= 315

      expect(described_class.calculate_expiry(nil, 10, nil)).to be == 600
    end
  end

end
