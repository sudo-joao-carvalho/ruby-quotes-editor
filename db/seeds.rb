# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

users = YAML.load_file(Rails.root.join('test', 'fixtures', 'users.yml'))

# Iterate over each user definition and create a user record
users.each do |_, attributes|
  company = Company.find_or_create_by(name: attributes['company'])

  User.find_or_create_by(email: attributes['email']) do |user|
    user.password = 'password' # Set a default password
    user.company = company
  end
end

# Load data from quotes.yml fixture
quotes = YAML.load_file(Rails.root.join('test', 'fixtures', 'quotes.yml'))

# Iterate over each quote definition and create a quote record
quotes.each do |_, attributes|
  company = Company.find_by(name: attributes['company'])

  Quote.find_or_create_by(name: attributes['name'], company: company)
end

# Load data from line_item_dates.yml fixture
line_item_dates = YAML.load_file(Rails.root.join('test', 'fixtures', 'line_item_dates.yml'))

line_item_dates.each do |key, attributes|
  date_str = attributes['date']
  quote_name = attributes['quote']
  quote = Quote.find_by(name: quote_name)

  if quote.nil?
    puts "Quote '#{quote_name}' not found for LineItemDate '#{key}'"
    next
  end

  # Parse the date string into a Date object
  begin
    date = Date.parse(date_str)
    puts "Creating LineItemDate '#{key}' with date '#{date}' and quote '#{quote_name}'"
    LineItemDate.find_or_create_by(date: date, quote: quote)
  rescue ArgumentError
    puts "Invalid date format '#{date_str}' for LineItemDate '#{key}'"
  end
end

# Load data from line_items.yml fixture
line_items = YAML.load_file(Rails.root.join('test', 'fixtures', 'line_items.yml'))

line_items.each do |key, attributes|
  line_item_date_str = attributes['line_item_date']
  line_item_date = LineItemDate.find_by(date: line_item_date_str)

  if line_item_date.nil?
    puts "LineItemDate #{line_item_date_str} not found for LineItem #{key}"
    next
  end

  # Create LineItem record
  LineItem.find_or_create_by(
    name: attributes['name'],
    description: attributes['description'],
    quantity: attributes['quantity'],
    unit_price: attributes['unit_price'],
    line_item_date: line_item_date
  )
end