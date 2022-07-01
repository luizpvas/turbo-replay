require "test_helper"

class Turbo::Replay::Message < ActiveSupport::TestCase
  setup do
    Turbo::Replay.configure do |config|
      config.repo = Turbo::Replay::Repo::Memory.new
    end
  end

  test ".get_current_sequence_number - calls the repo with the correct input"

  test ".get_current_sequence_number - returns the value returned from the repo"

  test ".get_after_sequence_number - calls the repo with the correct input"

  test ".get_after_sequence_number - filters out messages before the sequence number"

  test ".get_after_sequence_number - returns :unrecoverable if sequence_number is less than the ooldest message"
  
  test ".insert - calls the repo with the correct input"

  test ".insert - returns the value returned from the repo"
end
