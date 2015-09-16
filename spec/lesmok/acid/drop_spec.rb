require 'lesmok'
describe ::Lesmok::Acid::Drop do

  let(:source_klass) do
    Struct.new(:name, :age, :phone) do
      def bad_bang!
        raise ArgumentError.new("Should not be delegated!!!")
      end
      def bad_params(arg, *args)
        raise ArgumentError.new("Do not delegate with arguments!!!")
      end
      def bad_var=(new_var = nil)
        raise ArgumentError.new("Should NOT delegate to writer methods!!!")
      end
    end
  end
  let(:source) do
    source_klass.new("John Doe", 37, "555-1234-5678")
  end
  let(:drop) do
    described_class.new(source)
  end

  it "refers to the source object" do
    expect(drop.source_object).to be == source
  end

  it "should delegate methods" do
    expect(drop.name).to  be_eql("John Doe")
    expect(drop.age).to   be == 37
    expect(drop.phone).to match(/^555.*/)
  end

  it "should not fails on non-existing methods" do
    expect(drop.nonexistant_random_method).to be_nil
  end

  it "should not delegate bang / mutator methods" do
    expect(drop.bad_bang!).to be == nil
  end

  it "should not delegate writer methods" do
    expect do
      drop.bad_var = "Down, boy!"
    end.to raise_error(NoMethodError)
  end

  it "should not pass on calls with arguments" do
    expect do
      drop.bad_params(:foo, :bar)
    end.to raise_error(NoMethodError)
  end

end
