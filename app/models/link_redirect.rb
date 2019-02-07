# Model providing access to the link redirect data in the database.  This is not an
# ActiveRecord class, as PG table partitioning does not currently play-well with Rails.
# Additionally, there is little value in providing per row access via an ORM, as the data
# is only intended for aggregated reporting.  Instead, class methods are provided for
# inserting new rows and querying for aggregated rules.
class LinkRedirect

  SCHEMA_NAME = "link_redirect"

  # Insert a new row into the link_redirects tables with the provided link and referrer string.
  def self.insert(link, referrer: nil, occurred_at: Time.zone.now)
    unless referrer.nil?
      referrer.strip!
      referrer = nil if referrer.empty?
    end
    begin
      with_connection do |conn|
        conn.execute(<<-SQL)
          INSERT INTO link_redirects (link_id, referrer, occurred_at)
          VALUES (#{conn.quote(link)}, #{conn.quote(referrer)}, #{conn.quote(occurred_at)});
        SQL
      end
    rescue ActiveRecord::StatementInvalid, PG::Error => e
      Rails.logger.error(e)
      return false
    end
    
    true
  end

  # Count the numer of redirects for a specific link that occurred by referrer between
  # the start_time and end_time provided. Data is returned aggregated by day and the
  # provided bounds are truncated to day precision for the search.  Results are
  # inclusive of provided end_time.
  def self.count_by_referrer(link, start_time, end_time)
    result = nil
    begin
      with_connection do |conn|
        result = conn.execute(<<-SQL)
          SELECT COUNT(1) AS redirects, referrer, occurred_at::date AS occurred_on
          FROM link_redirects
          WHERE occurred_at BETWEEN date_trunc('day', timestamptz #{conn.quote(start_time)})
          AND date_trunc('day', timestamptz #{conn.quote(end_time + 1.day)})
          AND link_id = #{conn.quote(link)}
          GROUP BY referrer, occurred_at::date
          ORDER BY occurred_on, redirects, referrer;
        SQL
      end
    rescue ActiveRecord::StatementInvalid, PG::Error => e
      Rails.logger.error(e)
      return []
    end

    if result.ntuples > 0
      (0..(result.ntuples - 1)).map { |n| result[n] }
    else
      []
    end
  end

  # Returns true if the partition matching the provided year and month exists.
  def self.partition_table_exists?(year, month)
    start_time = Time.utc(year, month)
    result = nil
    with_connection do |conn|
      result = conn.execute(<<-SQL)
        SELECT 1 FROM information_schema.tables
        WHERE table_name = #{conn.quote(partition_table_name(start_time))} AND table_schema = #{conn.quote(SCHEMA_NAME)};
      SQL
    end

    # Table exists if one row is returned with the value of 1.
    result.ntuples == 1 && result.getvalue(0,0) == 1
  end

  # Create a new partition table in the link_result schema for the calendar month identified by the
  # provided year and month arguments. Returns true if the table was created, false otherwise.
  def self.create_partition(year, month)
    start_time = Time.utc(year, month)
    end_time = start_time + 1.month
    res = nil
    begin 
      with_connection do |conn|
        res = conn.execute(<<-SQL)
          CREATE TABLE #{conn.quote_table_name(qualified_partition_table_name(start_time))}
          PARTITION OF link_redirects 
          FOR VALUES FROM (#{conn.quote(start_time)}) TO (#{conn.quote(end_time)});
        SQL
      end
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error(e)
      return false
    end
    Rails.logger.info(res)

    true
  end


  def self.partition_table_name(timestamp)
    "p#{timestamp.strftime("%Y_%m")}"
  end
  private_class_method :partition_table_name

  def self.qualified_partition_table_name(timestamp)
    "#{SCHEMA_NAME}.#{partition_table_name(timestamp)}"
  end
  private_class_method :qualified_partition_table_name

  def self.with_connection
    ApplicationRecord.connection_pool.with_connection do |conn|
      conn.transaction do
        yield conn
      end
    end
  end
  private_class_method :with_connection

end
