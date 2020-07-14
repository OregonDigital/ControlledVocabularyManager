# Honeycomb integration

if Rails.env.development? || ENV.key?("HONEYCOMB_DEBUG")
  Honeycomb.configure do |config|
    config.client = Libhoney::NullClient.new
  end
else

  # Honeycomb Rails integration
  Honeycomb.configure do |config|
    config.write_key = ENV.fetch('HONEYCOMB_WRITEKEY', 'hereisareallylonglookingkey')
    config.dataset = ENV.fetch('HONEYCOMB_DATASET', 'scholars-test')
  end
end
