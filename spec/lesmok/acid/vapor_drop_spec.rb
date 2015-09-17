require 'lesmok/acid/vapor_drop'
describe ::Lesmok::Acid::VaporDrop do

  let(:source_klass) do
    Struct.new(:name, :age, :phone) do
      include ::Lesmok::Acid::Meltable
      def birth_year
        2015 - age
      end
    end
  end
  let(:source) do
    source_klass.new("John Doe", 37, "555-1234-5678")
  end
  let(:drop) do
    described_class.new(name: 'John', age: 36, phone: 'N/A') do |data|
      source
    end
  end

  it "does not get source prematurely" do
    expect(drop.source_object).to be_nil
  end

  it "returns pre-given data instead of fetching source" do
    expect(drop.name).to  eql("John")
    expect(drop.age).to   eql(36)
    expect(drop.phone).to eql("N/A")
  end

  it "can fetch source liquid object" do
    expect(drop.condensed_acid_drop?).to be_falsey
    expect(drop.condense_acid_drop!).to  be_truthy
    expect(drop.condensed_acid_drop?).to be_truthy
    expect(drop.source_object).to        be_truthy
    expect(drop.source_object.class).to be(::Lesmok::Acid::Drop)
    expect(drop.source_object.source_object).to be == source
  end

  it "will try to fetch source for unknown method calls" do
    expect(drop.condensed_acid_drop?).to be_falsey
    expect(drop.birth_year).to  eql(1978)
    expect(drop.condensed_acid_drop?).to be_truthy
  end

  it "delegates after source has been fetched pre-given data instead of fetching source" do
    expect(drop.name).to  eql("John")
    expect(drop.age).to   eql(36)
    expect(drop.phone).to eql("N/A")
    expect(drop.birth_year).to eql(1978)
    expect(drop.name).to  eql("John Doe")
    expect(drop.age).to   eql(37)
    expect(drop.phone).to eql(source.phone)
  end




end
