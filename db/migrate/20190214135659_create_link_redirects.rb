class CreateLinkRedirects < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE SCHEMA IF NOT EXISTS link_redirect;

      CREATE TABLE link_redirects (
        occurred_at TIMESTAMP WITH TIME ZONE NOT NULL,
        link_id INTEGER REFERENCES links NOT NULL,
        referrer TEXT
      ) PARTITION BY RANGE (occurred_at);

      CREATE INDEX ON link_redirects (occurred_at);
      CREATE INDEX ON link_redirects (link_id);
    SQL
  end
  def down
    execute <<-SQL
      DROP TABLE link_redirects;
      DROP SCHEMA link_redirect CASCADE;
    SQL
  end
end
