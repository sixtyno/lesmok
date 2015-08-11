require 'lesmok/liquidations'

describe 'Lesmok liquidations' do

  describe 'Symbols' do
    let(:template){ Liquid::Template.parse("GOT:{{ sym }}") }
    it "should render symbols" do
      text = template.render( 'sym' => :symbol )
      expect(text).to include "GOT:symbol"
    end
  end

  describe 'Structs' do
    let(:anon_klass){ Struct.new(:name, :age) }
    let(:template){ Liquid::Template.parse("{{ user.name }}/{{ user.age }}") }
    it "should handle structs" do
      user = anon_klass.new("OlaNordmann", 77)
      expect(user.age).to eql(77)
      text = template.render( 'user' => user )
      expect(text).to include "OlaNordmann"
      expect(text).to include "77"
    end

  end



end
