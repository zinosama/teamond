ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include ApplicationHelper

  # Add more helper methods to be used by all tests here...
  def is_logged_in?
  	!session[:user_id].nil?
  end

  def log_in_as(user, options = {})
  	password = options[:password] || 'password'
  	remember_me = options[:remember_me] || '1'
  	if integration_test?
  		post login_path, session: { email: user.email, password: password, remember_me: remember_me }
  	else
  		session[:user_id] = user.id
  	end
  end

  def get_addon_ids
    [ milktea_addons(:bubble), milktea_addons(:red_bean), milktea_addons(:green_bean) ].map{|addon| addon.id }
  end
  
  private 

  def integration_test?
  	defined? post_via_redirect
  end
end
