# frozen_string_literal: true

namespace :flickr do
  desc "Imports a Flickr export (from 2018)"
  task import: :environment do
    photo_files = []
    Dir.glob("#{Rails.root}/flickr/photos/*.{jpg,png}").each do |file_name|
      photo_files << file_name
    end

    not_found = []

    Dir.glob("#{Rails.root}/flickr/json/photo_*.json").each do |file_name|
      file = File.read(file_name)
      photo_hash = JSON.parse(file)

      id = photo_hash['id']
      original_filename = %r{[^\/]+$}.match(photo_hash['original'])[0]
      photo_file_matches = photo_files.select { |i| i[/#{id}/] }
      break if photo_file_matches.size > 1

      photo_file = photo_file_matches[0]

      if photo_file
        photo = Photo.create(
          name: photo_hash['name'],
          description: photo_hash['description'],
          date_taken: photo_hash['date_taken'],
          license: photo_hash['license'],
          exif: photo_hash['exif'],
          serial_number: photo_hash['id'],
          flickr_views: photo_hash['count_views'],
          flickr_faves: photo_hash['count_faves'],
          imported_at: photo_hash['date_imported'],
          flickr_photopage: photo_hash['photopage'],
          flickr_original: photo_hash['original'],
          flickr_json: photo_hash
        )

        photo.image_attacher(model_cache: false)
        photo.image = File.open(photo_file, binmode: true)
        photo.image_derivatives!
        photo.save
      else
        not_found << id + ' ' + original_filename
      end

      putc '.'
    end

    puts ''
    puts not_found
  end

  desc 'Sets the privacy of Flickr photos according to the original JSON'
  task import_privacy: :environment do
    affected_rows = ActiveRecord::Base.connection.update("UPDATE photos SET privacy = (flickr_json->>'privacy')::photo_privacy")
    puts "#{affected_rows} photos updated"
  end

  desc 'Import tags from Flickr'
  task import_tags: :environment do
    tagging_source = TaggingSource.find_by(name: 'Flickr')

    Photo.unscoped.all.each do |photo|
      flickr_tag_list = photo.flickr_json['tags'].map { |t| t['tag'].downcase }.join(',')
      if flickr_tag_list != ''
        tagging_source.tag(photo, with: flickr_tag_list, on: :tags)
        puts "Photo #{photo.id} / #{photo.slug} - Tagged with: #{flickr_tag_list}"
      else
        puts "Photo #{photo.id} / #{photo.slug} - Not tagged"
      end
    end
  end
end
