class RewardsService
  class << self
    attr_accessor :eligibility_service
  end

  attr_reader :account_number, :portfolio

  # accepts account_number and portfolio object
  # portfolio object should responce to `channels_subscriptions`
  def initialize(account_number, portfolio)
    @account_number, @portfolio = account_number, portfolio
  end

  # returns array of relevant rewards
  # accepts optional block, and passes error symbol in it.
  def rewards
    if eligibility_service_instance.eligibility
      portfolio.channels_subscriptions.map { |channel| rewards_repository[channel] }.compact
    else
      []
    end

  rescue eligibility_service::InvalidAccountNumber
    yield(:account_number_is_invalid) if block_given?
    []
  rescue
    yield(:service_technical_failure) if block_given?
    []
  end

  private

  def eligibility_service
    self.class.eligibility_service
  end

  def eligibility_service_instance
    eligibility_service.new(account_number)
  end

  def rewards_repository
    {
      'SPORTS' => 'CHAMPIONS_LEAGUE_FINAL_TICKET',
      'MUSIC' => 'KARAOKE_PRO_MICROPHONE',
      'MOVIES' => 'PIRATES_OF_THE_CARIBBEAN_COLLECTION'
    }
  end
end
