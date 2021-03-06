# frozen_string_literal: true

namespace :albums do
  desc 'Resets tag tables'
  task reset: :environment do
    ActiveRecord::Base.connection.execute(
      <<~SQL.squish
        TRUNCATE TABLE albums_photos RESTART IDENTITY CASCADE;
        TRUNCATE TABLE albums RESTART IDENTITY CASCADE;
      SQL
    )
  end
end
