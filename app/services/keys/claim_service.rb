# frozen_string_literal: true

class Keys::ClaimService < BaseService
  class Result < ActiveModelSerializers::Model
    attributes :account, :device_id, :key_id,
               :key, :signature

    def initialize(account, device_id, key_attributes = {})
      @account   = account
      @device_id = device_id
      @key_id    = key_attributes[:key_id]
      @key       = key_attributes[:key]
      @signature = key_attributes[:signature]
    end
  end

  def call(account_id, device_id)
    @account   = Account.find(account_id)
    @device_id = device_id

    if @account.local?
      claim_local_key!
    else
      claim_remote_key!
    end
  rescue ActiveRecord::RecordNotFound
    nil
  end

  private

  def claim_local_key!
    device = @account.devices.find_by(device_id: @device_id)
    key    = nil

    ApplicationRecord.transaction do
      key = device.one_time_keys.order(Arel.sql('random()')).first!
      key.destroy!
    end

    @result = Result.new(@account, @device_id, key)
  end

  def claim_remote_key!
    # TODO
  end
end
