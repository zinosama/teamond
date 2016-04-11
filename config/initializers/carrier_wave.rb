if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      # Configuration for Amazon S3
      :provider              => 'AWS',
      :aws_access_key_id     => ENV['S3_TEAMOND_ACCESS_KEY'],
      :aws_secret_access_key => ENV['S3_TEAMOND_SECRET_KEY']
    }
    config.fog_directory     =  ENV['S3_TEAMOND_BUCKET']
  end
end