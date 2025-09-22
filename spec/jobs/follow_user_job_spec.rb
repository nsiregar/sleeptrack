require 'rails_helper'

RSpec.describe FollowUserJob, type: :job do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:followable_user) { create(:user) }

  it "queues the job" do
    expect {
      described_class.perform_later(user, followable_user)
    }.to have_enqueued_job(described_class)
  end

  it "executes perform" do
    expect_any_instance_of(User).to receive(:follow_user).with(followable_user)
    perform_enqueued_jobs { described_class.perform_later(user, followable_user) }
  end
end
