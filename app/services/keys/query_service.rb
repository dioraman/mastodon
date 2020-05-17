# frozen_string_literal: true

class Keys::QueryService < BaseService
  class Result < ActiveModelSerializers::Model
    attributes :account, :devices

    def initialize(account, devices)
      @account = account
      @devices = devices || []
    end
  end

  class Device < ActiveModelSerializers::Model
    attributes :device_id, :name, :identity_key, :fingerprint_key

    def initialize(attributes = {})
      @device_id       = attributes[:device_id]
      @name            = attributes[:name]
      @identity_key    = attributes[:identity_key]
      @fingerprint_key = attributes[:fingerprint_key]
    end
  end

  def call(account)
    @account = account

    if @account.local?
      query_local_devices!
    else
      query_remote_devices!
    end

    Result.new(@account, @devices)
  end

  private

  def query_local_devices!
    @devices = account.devices.map { |device| Device.new(device) }
  end

  def query_remote_devices!
    # TODO
  end
end
