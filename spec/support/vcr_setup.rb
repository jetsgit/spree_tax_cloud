VCR.configure do |c|
  c.cassette_library_dir = Rails.root.join("spec")
  c.hook_into :webmock
  c.ignore_localhost = true
end
