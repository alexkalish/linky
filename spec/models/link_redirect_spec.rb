require 'rails_helper'

RSpec.describe LinkRedirect, type: :model do

    let(:year) { 1950 }
    let(:month) { 1 }
    let(:now) { Time.zone.now }
    let(:link) { create(:link) }
    let(:another_link) { create(:link) }
    let(:referrer) { "http://google.com" }


  def select_all_link_redirects
    result = nil
    ApplicationRecord.connection_pool.with_connection do |conn|
      result = conn.execute("SELECT link_id, referrer, occurred_at FROM link_redirects;")
    end

    result
  end

  describe("#insert") do

    it("records the provided valid link in the DB") do
      expect(LinkRedirect.insert(link)).to be true
      rows = select_all_link_redirects
      expect(rows.ntuples).to eq(1)
      expect(rows[0]["link_id"]).to eq(link.id)
      expect(rows[0]["referrer"]).to be nil
    end

    it("records the provided valid link and referrer in the DB") do
      expect(LinkRedirect.insert(link, referrer: referrer)).to be true
      rows = select_all_link_redirects
      expect(rows.ntuples).to eq(1)
      expect(rows[0]["link_id"]).to eq(link.id)
      expect(rows[0]["referrer"]).to eq(referrer)
    end

    it("returns false and does not insert a row with an unsaved link") do
      expect(LinkRedirect.insert(build(:link))).to be false
      rows = select_all_link_redirects
      expect(rows.ntuples).to eq(0)
    end

  end

  describe("#count_by_referrer") do

    it("returns an empty array when no link redirect rows exist") do
      expect(LinkRedirect.count_by_referrer(link, now, now)).to be_empty
    end

    it("returns a single aggregation result for multiple matching link redirect rows") do
      LinkRedirect.insert(link)
      LinkRedirect.insert(link)
      result = LinkRedirect.count_by_referrer(link, now, now) 
      expect(result.length).to eq(1)
      expect(result.first["redirects"]).to eq(2)
      expect(result.first["referrer"]).to be nil
    end

    it("returns a single aggregation result for each referrer in matching link redirect rows") do
      2.times do
        LinkRedirect.insert(link)
        LinkRedirect.insert(link, referrer: referrer)
      end
      result = LinkRedirect.count_by_referrer(link, now, now) 
      expect(result.length).to eq(2)
      expect(result.first["redirects"]).to eq(2)
      expect(result.first["referrer"]).to eq(referrer)
      expect(result.second["redirects"]).to eq(2)
      expect(result.second["referrer"]).to be nil
    end

    it("returns an aggregation result that excludes rows outside the query period") do
      LinkRedirect.insert(link)
      LinkRedirect.insert(link, occurred_at: now - 2.days)
      result = LinkRedirect.count_by_referrer(link, now, now) 
      expect(result.length).to eq(1)
      expect(result.first["redirects"]).to eq(1)
    end

    it("returns an aggregation result that excludes rows from another link row") do
      LinkRedirect.insert(link, referrer: referrer)
      LinkRedirect.insert(another_link)
      result = LinkRedirect.count_by_referrer(link, now, now) 
      expect(result.length).to eq(1)
      expect(result.first["redirects"]).to eq(1)
      # Only "link" has a referrer, so assertion below ensures that the returned row is not aggregated
      # from "another_link"
      expect(result.first["referrer"]).to eq(referrer)
    end

    it("returns an aggregation result that includes rows across partitions") do
      past = now - 2.months
      LinkRedirect.create_partition(past.year, past.month)
      LinkRedirect.insert(link)
      LinkRedirect.insert(link, occurred_at: past)
      result = LinkRedirect.count_by_referrer(link, past, now) 
      expect(result.length).to eq(2)
      expect(result.first["redirects"]).to eq(1)
      expect(result.second["redirects"]).to eq(1)
    end

  end

  describe("#partition_table_exists?") do

    it("returns true if the table already exists") do
      LinkRedirect.create_partition(year, month)
      expect(LinkRedirect.partition_table_exists?(year, month)).to be true
    end

    it("returns false if the table doesn't exist") do
      expect(LinkRedirect.partition_table_exists?(year, month)).to be false
    end

  end

  describe("#create_partition") do

    let(:table_name) { "p#{Time.utc(year, month).strftime("%Y_%m")}" }

    it("returns true if the table was successfully created") do
      expect(LinkRedirect.create_partition(year, month)).to be true
      expect_partition_table_exists(table_name)
    end

    it("returns false if the table alread exists") do
      LinkRedirect.create_partition(year, month)
      expect(LinkRedirect.create_partition(year, month)).to be false 
    end

  end

  def expect_partition_table_exists(table_name)
    table_query = "SELECT 1 FROM information_schema.tables WHERE table_name = '#{table_name}' AND table_schema = 'link_redirect';"
    result = nil
    ApplicationRecord.connection_pool.with_connection do |conn|
      result = conn.execute(table_query)
    end
    expect(result.ntuples).to eq(1)
    expect(result.getvalue(0,0)).to eq(1)
  end
end
