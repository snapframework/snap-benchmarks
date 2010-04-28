# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_ror_session',
  :secret      => '5d82a09ecbca53e8b2bcbea77e7295f8e2dcddcd1908e9c24b22bfd6c292f3cbf4841be8dc5395354d0b43ffebec22640b0518e2e397330467edd9216b2d07c6'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
