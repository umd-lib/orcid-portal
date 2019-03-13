# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :fix_cas_session

  def fix_cas_session
    if session[:cas] && !session[:cas].is_a?(HashWithIndifferentAccess)
      session[:cas] = session[:cas].with_indifferent_access
    elsif session[:cas].nil? || session[:cas][:user].nil?
      head :unauthorized
    end
  end

  def cas_uid
    session[ENV['CAS_SESSION_ATTRIBUTE']]['extra_attributes'][ENV['CAS_UID_ATTRIBUTE']]
  end

  def cas_first_name
    session[ENV['CAS_SESSION_ATTRIBUTE']]['extra_attributes'][ENV['CAS_FIRST_NAME_ATTRIBUTE']]
  end

  def cas_last_name
    session[ENV['CAS_SESSION_ATTRIBUTE']]['extra_attributes'][ENV['CAS_LAST_NAME_ATTRIBUTE']]
  end
end
