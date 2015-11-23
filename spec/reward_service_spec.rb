require File.expand_path('../../lib/rewards_service.rb',  __FILE__)

RSpec.describe RewardsService do
  class EligibilityServiceStub
    class InvalidAccountNumber < StandardError
    end

    def initialize(account_number)
    end

    def eligibility
      true
    end
  end

  before { described_class.eligibility_service = EligibilityServiceStub }

  let(:account_number) { '123' }
  let(:portfolio) { double(channels_subscriptions: ['KIDS', 'MUSIC']) }
  subject { described_class.new(account_number, portfolio) }

  describe '.eligibility_service' do
    it 'works as class accessor' do
      expect(described_class.eligibility_service).to eq EligibilityServiceStub
    end
  end

  describe 'readers' do
    it 'stores account_number' do
      expect(subject.account_number).to eq account_number
    end

    it 'stores portfolio' do
      expect(subject.portfolio).to eq portfolio
    end
  end

  describe '#rewards' do
    context 'Customer is eligible' do
      context 'and there are no channels with reward' do
        let(:portfolio) { double(channels_subscriptions: ['KIDS']) }
        it 'returns empty array' do
          expect(subject.rewards).to be_empty
        end
      end

      context 'and there are some channels with reward' do
        it 'returns array with reward' do
          expect(subject.rewards).to include 'KARAOKE_PRO_MICROPHONE'
        end
      end
    end

    context 'Customer is not eligible' do
      before do
        allow_any_instance_of(EligibilityServiceStub).to receive(:eligibility).and_return false
      end

      it 'returns empty array' do
        expect(subject.rewards).to be_empty
      end
    end

    context 'Service technical failure' do
      context 'on initialization' do
        before { allow(EligibilityServiceStub).to receive(:new).and_raise }

        it 'returns empty array' do
          expect(subject.rewards).to be_empty
        end

        it 'passes status to block' do
          subject.rewards do |status|
            @status = status
          end
          expect(@status).to eq :service_technical_failure
        end
      end

      context 'after initialization' do
        before do
          allow_any_instance_of(EligibilityServiceStub).to receive(:eligibility).and_raise
        end

        it 'returns empty array' do
          expect(subject.rewards).to be_empty
        end

        it 'passes status to block' do
          subject.rewards do |status|
            @status = status
          end
          expect(@status).to eq :service_technical_failure
        end
      end

    end

    context 'The supplied account number is invalid' do
      before { allow(EligibilityServiceStub).to receive(:new).and_raise EligibilityServiceStub::InvalidAccountNumber }

      it 'returns empty array' do
        expect(subject.rewards).to be_empty
      end

      it 'passes status to block' do
        subject.rewards do |status|
          @status = status
        end
        expect(@status).to eq :service_technical_failure
      end
    end
  end
end
