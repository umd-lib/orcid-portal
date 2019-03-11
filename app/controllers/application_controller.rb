# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :fix_cas_session

  def fix_cas_session
    if session[:cas] && !session[:cas].is_a?(HashWithIndifferentAccess)
      session[:cas] = session[:cas].with_indifferent_access
    elsif session[:cas].nil? || session[:cas][:user].nil?
      render status: :unauthorized, text: 'Redirecting to SSO...'
    end
  end
end
