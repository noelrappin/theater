require "billy/rspec"

Billy.configure do |c|
  c.cache = true
  c.cache_request_headers = false
  c.ignore_params = ["https://js.stripe.com/v2/channel.html"]
  c.path_blacklist = []
  c.merge_cached_responses_whitelist = []
  c.persist_cache = true
  c.ignore_cache_port = true # defaults to true
  c.non_successful_cache_disabled = false
  c.non_successful_error_level = :warn
  c.non_whitelisted_requests_disabled = false
  c.cache_path = "spec/vcr_cassettes/billy/"
  c.proxied_request_host = nil
  c.proxied_request_port = 80
end
