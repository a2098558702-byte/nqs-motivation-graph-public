#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"

ROOT = File.expand_path("..", __dir__)
PLACEHOLDER = "[redacted_for_public_release]"

RAW_SOURCE_EXTENSIONS = %w[
  .pdf .eprint .zip .tar .tgz .gz .bbl .tex
].freeze

PRIVATE_BASENAMES = %w[
  condition_key_private.csv
  blind_condition_key_private.csv
  anonymous_case_mapping_private.csv
  round0_candidate_link_key_private.csv
  unsealed_case_condition_index.csv
].freeze

LOCAL_HOME_FRAGMENT = File.join("", "Users", "huangbz") + File::SEPARATOR

def relative(path)
  path.sub(ROOT + "/", "")
end

def text_file?(path)
  return false if File.directory?(path)

  sample = File.binread(path, 4096)
  !sample.include?("\x00")
rescue StandardError
  false
end

errors = []

Dir.glob(File.join(ROOT, "**", "*")).each do |path|
  rel = relative(path)
  next if rel == ".git" || rel.start_with?(".git/")

  basename = File.basename(path)

  errors << "private directory present: #{rel}" if File.directory?(path) && basename == "private"
  errors << "private key file present: #{rel}" if File.file?(path) && PRIVATE_BASENAMES.include?(basename)
  errors << "raw source artifact present: #{rel}" if File.file?(path) && RAW_SOURCE_EXTENSIONS.include?(File.extname(path).downcase)

  next unless File.file?(path) && text_file?(path)

  text = File.read(path)
  errors << "local absolute path present: #{rel}" if text.include?(LOCAL_HOME_FRAGMENT)
end

Dir.glob(File.join(ROOT, "**", "*.csv")).each do |path|
  table = CSV.read(path, headers: true)
  redaction_columns = table.headers & %w[evidence evidence_quote]
  next if redaction_columns.empty?

  table.each_with_index do |row, index|
    redaction_columns.each do |column|
      value = row[column].to_s
      next if value == "" || value == PLACEHOLDER

      errors << "unredacted #{column} in #{relative(path)} row #{index + 2}"
      break
    end
  end
end

if errors.empty?
  puts "public_release_hygiene=ok"
else
  warn "public_release_hygiene=failed"
  errors.each { |error| warn "- #{error}" }
  exit 1
end
