require "./spec/spec_helper"
require "./lib/six"

describe Six do 
  # define abilities object
  let (:abilities) { Six.new }

  describe "Rules Packs" do 
    let(:rules) { BookRules.new }

    describe "<<" do 
      it { (abilities << rules).should be_true }
      it { lambda { abilities << nil }.should raise_error(Six::InvalidPackPassed) }

      it_should_behave_like :valid_abilities do 
        let (:abilities) { Six.new }
        let (:rules) { BookRules.new }
        let (:rules_key) { rules.object_id.to_s }
        before { abilities << rules }
      end
    end

    describe :add do 
      it { abilities.add(:global, rules).should be_true }
      it { abilities.add(:wrong, nil).should be_false }
    end

    describe :add! do 
      it { abilities.add!(:global, rules).should be_true }
      it { lambda { abilities.add!(:wrong, nil)}.should raise_error(Six::InvalidPackPassed) }
    end

    describe "namespace(pack) usage" do 
      before { abilities.add(:global, rules) }

      describe :use do 
        before { abilities.use(:global) }

        it "should return class object itself when use existing pack" do 
          abilities.use(:global).should == abilities
        end

        describe "should set current role pack with selected" do 
          it { abilities.current_rule_pack.should == :global }
        end

        it "should return false when trying to use unexisting pack" do 
          abilities.use(:noname).should be_false
        end
      end

      describe :use! do 
        it "should not raise error if trying to use existing pack" do
          lambda { abilities.use!(:global)}.should_not raise_error
        end

        it "should raise error if trying to use unexisting pack" do 
          lambda { abilities.use!(:noname)}.should raise_error(Six::NoPackError)
        end
      end
    end

    describe :reset_use do 
      before do 
        abilities.use(:global)
        abilities.reset_use
      end

      it "should set current rule pack variable as nil" do 
        abilities.current_rule_pack.should be_nil
      end
    end

    context "removing pack" do
      before { abilities.add(:global, rules) }

      describe :remove do 
        it { abilities.remove(:global).should be_true }
        it { abilities.remove(:zzz).should be_false }
      end

      describe :remove! do 
        it { abilities.remove!(:global).should be_true }
        it { lambda { abilities.remove!(:zzz)}.should raise_error(Six::NoPackError) }
      end
    end

    describe :valid_rules_object? do 
      let (:invalid_with_allowed) do 
        Class.new { def allowed; nil; end }.new
      end

      let (:invalid_wo_allowed) do 
        Object.new
      end

      it { abilities.valid_rules_object?(BookRules.new).should be_true }
      it { abilities.valid_rules_object?(invalid_with_allowed).should be_false }
      it { abilities.valid_rules_object?(invalid_wo_allowed).should be_false }
    end

    describe :pack_exist? do 
      before { abilities.add(:global, rules) }

      it { abilities.pack_exist?(:global).should be_true }
      it { abilities.pack_exist?(:ufo).should be_false }
    end
  end
end
