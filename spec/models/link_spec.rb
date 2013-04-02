require 'spec_helper'

describe Link do

    let(:user) { new_user }
    before do
        @link = Link.new(url: "http://pielab.info",
                         title: "PieLab: Pies of tomorrow, today",
                         description: %{PieLab is an interdisciplinary research                                               
                                        group dedicated to the development of
                                        experimental pies.},
                         datetime: "2013-03-21T03:02:07Z",
                         user_id: user.id)

    end

    subject { @link }

    it { should respond_to(:url) }
    it { should respond_to(:title) }
    it { should respond_to(:description) }
    it { should respond_to(:datetime) }
    it { should respond_to(:user_id) }

    it { should respond_to(:user) }
    its(:user) { should eql(user) }

    it { should be_valid }

    describe "when user_id is not present" do
        before { @link.user_id = nil }
        it { should_not be_valid }
    end

    describe "when url is not present" do
        before { @link.url = nil }
        it { should_not be_valid }
    end

    describe "when title is not present" do
        before { @link.title = nil }
        it { should_not be_valid }
    end

    describe "when datetime is not present" do
        before { @link.datetime = nil }
        it { should_not be_valid }
    end
end
