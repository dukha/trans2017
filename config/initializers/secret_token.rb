# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

# rails 4 remove secret_token once everything works
Translator::Application.config.secret_token = 'af5753943f022e784922af3fd685656c6f1a1ca5b0f65e3ddb3d409d95480b783ca2df8033b654a6175f35dd73e4c65e5e659c822329d169ad2f4a1968b4a98c'
# rails 4 add secret_key_base
Translator::Application.config.secret_key_base = 'xx762a2f23950e306261908d4e5519ffe71ce626b119e9fc03a012ba86f46d82ef32d72f283633bacc2f59cf94ce5968552fe97d157e7f00560c1217d4592dda09abc'