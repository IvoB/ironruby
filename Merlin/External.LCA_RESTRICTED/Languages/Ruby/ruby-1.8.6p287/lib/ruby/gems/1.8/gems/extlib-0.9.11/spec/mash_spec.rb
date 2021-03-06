require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

class AwesomeHash < Hash
end

describe Mash do
  before(:each) do
    @hash = { "mash" => "indifferent", :hash => "different" }
    @sub  = AwesomeHash.new("mash" => "indifferent", :hash => "different")
  end

  describe "#initialize" do
    it 'converts all keys into strings when param is a Hash' do
      mash = Mash.new(@hash)

      mash.keys.any? { |key| key.is_a?(Symbol) }.should be(false)
    end

    it 'converts all pure Hash values into Mashes if param is a Hash' do
      mash = Mash.new :hash => @hash

      mash["hash"].should be_an_instance_of(Mash)
      # sanity check
      mash["hash"]["hash"].should == "different"
    end

    it 'doesn not convert Hash subclass values into Mashes' do
      mash = Mash.new :sub => @sub
      mash["sub"].should be_an_instance_of(AwesomeHash)
    end

    it 'converts all value items if value is an Array' do
      mash = Mash.new :arry => { :hash => [@hash] }

      mash["arry"].should be_an_instance_of(Mash)
      # sanity check
      mash["arry"]["hash"].first["hash"].should == "different"

    end

    it 'delegates to superclass constructor if param is not a Hash' do
      mash = Mash.new("dash berlin")

      mash["unexisting key"].should == "dash berlin"
    end
  end # describe "#initialize"



  describe "#update" do
    it 'converts all keys into strings when param is a Hash' do
      mash = Mash.new(@hash)
      mash.update("starry" => "night")

      mash.keys.any? { |key| key.is_a?(Symbol) }.should be(false)
    end

    it 'converts all Hash values into Mashes if param is a Hash' do
      mash = Mash.new :hash => @hash
      mash.update(:hash => { :hash => "is buggy in Ruby 1.8.6" })

      mash["hash"].should be_an_instance_of(Mash)
    end
  end # describe "#update"



  describe "#[]=" do
    it 'converts key into string' do
      mash = Mash.new(@hash)
      mash[:hash] = { "starry" => "night" }

      mash.keys.any? { |key| key.is_a?(Symbol) }.should be(false)
    end

    it 'converts all Hash value into Mash' do
      mash = Mash.new :hash => @hash
      mash[:hash] = { :hash => "is buggy in Ruby 1.8.6" }

      mash["hash"].should be_an_instance_of(Mash)
    end
  end # describe "#[]="



  describe "#key?" do
    before(:each) do
      @mash = Mash.new(@hash)
    end

    it 'converts key before lookup' do
      @mash.key?("mash").should be(true)
      @mash.key?(:mash).should be(true)

      @mash.key?("hash").should be(true)
      @mash.key?(:hash).should be(true)

      @mash.key?(:rainclouds).should be(false)
      @mash.key?("rainclouds").should be(false)
    end

    it 'is aliased as include?' do
      @mash.include?("mash").should be(true)
      @mash.include?(:mash).should be(true)

      @mash.include?("hash").should be(true)
      @mash.include?(:hash).should be(true)

      @mash.include?(:rainclouds).should be(false)
      @mash.include?("rainclouds").should be(false)
    end

    it 'is aliased as member?' do
      @mash.member?("mash").should be(true)
      @mash.member?(:mash).should be(true)

      @mash.member?("hash").should be(true)
      @mash.member?(:hash).should be(true)

      @mash.member?(:rainclouds).should be(false)
      @mash.member?("rainclouds").should be(false)
    end
  end # describe "#key?"


  describe "#dup" do
    it 'returns instance of Mash' do
      Mash.new(@hash).dup.should be_an_instance_of(Mash)
    end

    it 'preserves keys' do
      mash = Mash.new(@hash)
      dup  = mash.dup

      mash.keys.sort.should == dup.keys.sort
    end

    it 'preserves value' do
      mash = Mash.new(@hash)
      dup  = mash.dup

      mash.values.sort.should == dup.values.sort
    end
  end



  describe "#to_hash" do
    it 'returns instance of Mash' do
      Mash.new(@hash).to_hash.should be_an_instance_of(Hash)
    end

    it 'preserves keys' do
      mash = Mash.new(@hash)
      converted  = mash.to_hash

      mash.keys.sort.should == converted.keys.sort
    end

    it 'preserves value' do
      mash = Mash.new(@hash)
      converted = mash.to_hash

      mash.values.sort.should == converted.values.sort
    end
  end



  describe "#delete" do
    it 'converts Symbol key into String before deleting' do
      mash = Mash.new(@hash)

      mash.delete(:hash)
      mash.key?("hash").should be(false)
    end

    it 'works with String keys as well' do
      mash = Mash.new(@hash)

      mash.delete("mash")
      mash.key?("mash").should be(false)
    end
  end



  describe "#except" do
    it "converts Symbol key into String before calling super" do
      mash = Mash.new(@hash)

      hashless_mash = mash.except(:hash)
      hashless_mash.key?("hash").should be(false)
    end

    it "works with String keys as well" do
      mash = Mash.new(@hash)

      mashless_mash = mash.except("mash")
      mashless_mash.key?("mash").should be(false)
    end

    it "works with multiple keys" do
      mash = Mash.new(@hash)

      mashless = mash.except("hash", :mash)
      mashless.key?(:hash).should be(false)
      mashless.key?("mash").should be(false)
    end

    it "should return a mash" do
      mash = Mash.new(@hash)

      hashless_mash = mash.except(:hash)
      hashless_mash.class.should be(Mash)
    end
  end



  describe "#merge" do
    before(:each) do
      @mash = Mash.new(@hash).merge(:no => "in between")
    end

    it 'returns instance of Mash' do
      @mash.should be_an_instance_of(Mash)
    end

    it 'merges in give Hash' do
      @mash["no"].should == "in between"
    end
  end



  describe "#fetch" do
    before(:each) do
      @mash = Mash.new(@hash).merge(:no => "in between")
    end

    it 'converts key before fetching' do
      @mash.fetch("no").should == "in between"
    end

    it 'returns alternative value if key lookup fails' do
      @mash.fetch("flying", "screwdriver").should == "screwdriver"
    end
  end


  describe "#default" do
    before(:each) do
      @mash = Mash.new(:yet_another_technical_revolution)
    end

    it 'returns default value unless key exists in mash' do
      @mash.default("peak oil is now behind, baby").should == :yet_another_technical_revolution
    end

    it 'returns existing value if key is Symbol and exists in mash' do
      @mash.update(:no => "in between")
      @mash.default(:no).should == "in between"
    end
  end


  describe "#values_at" do
    before(:each) do
      @mash = Mash.new(@hash).merge(:no => "in between")
    end

    it 'is indifferent to whether keys are strings or symbols' do
      @mash.values_at("hash", :mash, :no).should == ["different", "indifferent", "in between"]
    end
  end


  describe "#stringify_keys!" do
    it 'returns the mash itself' do
      mash = Mash.new(@hash)

      mash.stringify_keys!.object_id.should == mash.object_id
    end
  end
end
