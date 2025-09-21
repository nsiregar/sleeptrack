require 'rails_helper'

RSpec.describe Sleep, type: :model do
  describe 'columns' do
    it 'has columns' do
      is_expected.to have_db_column(:start).of_type(:datetime)
      is_expected.to have_db_column(:end).of_type(:datetime)
      is_expected.to have_db_column(:duration).of_type(:integer)
    end
  end

  describe 'relations' do
    it { should belong_to(:user).required }
  end

  describe 'validations' do
    subject { FactoryBot.build(:sleep) }

    it { should validate_presence_of(:start) }
  end
end
