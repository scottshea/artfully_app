require File.expand_path('../boot', __FILE__)

require 'rails/all'

require 'yaml'
YAML::ENGINE.yamler = 'syck'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module ArtfullyApp
  class Application < Rails::Application

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true


    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    
    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation, :number, :verification_value, :cvv, :card_number]
    ENV.keys.each {|k| Exceptional::ENVIRONMENT_FILTER << k}
    
    #Heroku needs this flag set.  Other hosting providers may not.
    config.assets.initialize_on_precompile = false
    
    #ArtfullyOse asset paths
    config.assets.paths << "#{Rails.root}/app/assets/sass"
    config.assets.paths << "#{Rails.root}/app/assets/jquery"
    config.assets.precompile += ['jquery/*','themes/default.css','widget-cart.css', 'storefront.css', 'pages/pages.css', 'printing.css', 'bootstrap.css', 'bootstrap-overrides.css', 'box-office.js', 'storefront.js', 'bootstrap.js', 'pages.js', 'widget-cart.js', 'artfully.js', 'artfully-v2.js']
    
    config.after_initialize do 
      #Braintree config
      config.braintree.merchant_id    = ENV['BRAINTREE_MERCHANT_ID']   || 'your_merchant_id'
      config.braintree.public_key     = ENV['BRAINTREE_PUBLIC_KEY']    || 'your_public_key'
      config.braintree.private_key    = ENV['BRAINTREE_PRIVATE_KEY']   || 'your_private_key'

      #S3 Config
      config.s3.bucket                = ENV['S3_BUCKET']               || 'your_bucket'
      config.s3.access_key_id         = ENV['S3_ACCESS_KEY_ID']        || 'your_access_key_id'
      config.s3.secret_access_key     = ENV['S3_SECRET_ACCESS_KEY']    || 'your_secret'

      #d2s3 config 
      D2S3::S3Config.load_config
    end
    
    Delayed::Worker.delay_jobs = false
  end
end
