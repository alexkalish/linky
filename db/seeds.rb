# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

# Create link redirect partitions for the next three months.  Ideally, new partitions
# would be added via a regularly scheduled job that might also archive old ones.  But
# for now, this works.
now = Time.zone.now
3.times do |n|
  timestamp = now + n.months
  LinkRedirect.create_partition(timestamp.year, timestamp.month)
end
