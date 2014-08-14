CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',                        # required
    :aws_access_key_id      => ENV["AMAZON_ACCESS_KEY"],     # required
    :aws_secret_access_key  => ENV["AMAZON_SECRET_KEY"],    # required
    :region                 => 'eu-west-1',                  # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = ENV["AMAZON_BUCKET_NAME"]          # required
  config.fog_public     = false                              # optional, defaults to true
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end