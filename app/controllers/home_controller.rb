# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @cas_uid = session.to_hash.dig(ENV['CAS_SESSION_ATTRIBUTE'], 'extra_attributes', ENV['CAS_UID_ATTRIBUTE'])
    record = OrcidRecord.find_by(uid: @cas_uid)
    if record
      # Record exists, so just show the "Previously Captured" page
      render 'previously_captured'
    else
      # Record not found, so show "Terms of Service" page
      @first_name = session.to_hash.dig(ENV['CAS_SESSION_ATTRIBUTE'], 'extra_attributes', ENV['CAS_FIRST_NAME_ATTRIBUTE'])
      @last_name = session.to_hash.dig(ENV['CAS_SESSION_ATTRIBUTE'], 'extra_attributes', ENV['CAS_LAST_NAME_ATTRIBUTE'])
      render 'terms_of_service'
    end
  end
end
