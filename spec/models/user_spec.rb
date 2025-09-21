require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'columns' do
    it 'has columns' do
      is_expected.to have_db_column(:name).of_type(:string)
    end
  end

  describe "validations" do
    subject { FactoryBot.build(:user) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'relations' do
    it { should have_many(:sleeps) }
  end
end
