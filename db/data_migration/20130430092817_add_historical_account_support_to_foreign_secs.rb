puts "Adding historical account support to the Foreign Secretary role"
Role.find_by_slug('first-secretary-of-state').update_attribute(:supports_historical_accounts, true)
