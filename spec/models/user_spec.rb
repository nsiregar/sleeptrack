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
    it { should have_many(:follows) }
    it { should have_many(:followings) }
  end

  describe '#follow user' do
    let(:user_1) { create :user }
    context 'follow other user' do
      let(:user_2) { create :user }

      it 'should allowed' do
        user_1.follows.create!(followable_id: user_2.id, followable_type: user_2.class.name)

        expect(user_1.following_users.first).to eq user_2
        expect(user_2.followers.first).to eq user_1
      end

      context 'when already follow the user' do
        it 'should not allowed' do
          user_1.follow_user(user_2)

          expect do
            user_1.follow_user(user_2)
          end.to raise_error ActiveRecord::RecordNotUnique
        end
      end
    end

    context 'follow it self' do
      it 'should not allowed' do
        user_1 = create :user

        user_1.follows.create(followable_id: user_1.id, followable_type: user_1.class.name)

        expect(user_1.follows.first).not_to be_valid
        expect(user_1.follows.first.errors[:base]).to include 'unable follow it self'
      end
    end
  end

  describe '#unfollow user' do
  end
end
