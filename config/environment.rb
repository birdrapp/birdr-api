# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# Use camelCaseKeys in JSON output
Jbuilder.key_format camelize: :lower
