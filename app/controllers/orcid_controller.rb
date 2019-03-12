# frozen_string_literal: true

require 'net/http'
require 'json'

# Handles interaction with Orcid API
class OrcidController < ApplicationController
  # Requests an authorization code from ORCID
  def auth_code_request
    url_encode_callback_url = ERB::Util.url_encode(ENV['AUTH_CODE_CALLBACK_URL'])

    # Construct the ORCID URL to redirect the user to
    orcid_url = ENV['ORCID_AUTHORIZE_ACCESS_URL'] +
                "?client_id=#{client_id}" \
                '&response_type=code&scope=/authenticate' \
                "&redirect_uri=#{url_encode_callback_url}"

    # Redirect user to ORCID for authorization
    redirect_to orcid_url
  end

  # Called by ORCID with an authorization code
  def auth_code_callback # rubocop:disable Metrics/MethodLength:
    token = params[:code]
    uri = URI(ENV['ORCID_AUTH_CODE_URL'])

    form_params = {
      client_id: client_id,
      client_secret: client_secret,
      grant_type: 'authorization_code',
      code: token,
      redirect_uri: ENV['AUTH_CODE_CALLBACK_URL']
    }

    # Send POST response back to ORCID requesting ORCID ID
    post_response = Net::HTTP.post_form(
      uri,
      form_params
    )

    # Handle the response to the POST
    response_hash = JSON.parse(post_response.body)

    if post_response.code == '200'
      # Successful response
      response_scheme = post_response.header.uri.scheme;
      response_host = post_response.header.uri.host;
      @orcid_identifier = "#{response_scheme}://#{response_host}/#{response_hash['orcid']}"

      create_record(cas_uid, @orcid_identifier)

      @orcid_name = response_hash['name']
      @orcid_record = OrcidRecord.find_by(uid: cas_uid)
      render 'auth_code_callback'
    else
      # Error response
      @error_code = post_response.code
      @error_code_type = post_response.code_type
      @error_message = response_hash['error']
      @error_description = response_hash['error_description']
      render 'auth_code_callback_error'
    end
  end

  private

    # Adds new OrcidRecord to the database
    def create_record(cas_uid, orcid_identifier)
      OrcidRecord.create(
        uid: cas_uid,
        orcid_id: orcid_identifier,
        registered_at: Time.now.utc
      )
    end

    # Returns the ORCID client id
    def client_id
      ENV['ORCID_CLIENT_ID']
    end

    # Returns the ORCID client secret
    def client_secret
      ENV['ORCID_CLIENT_SECRET']
    end
end
