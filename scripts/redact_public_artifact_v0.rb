#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
PLACEHOLDER = "[redacted_for_public_release]"

LOCAL_PATH_PATTERNS = [
  %r{<LOCAL_RESEARCH_WORKSPACE>/?},
  %r{<LOCAL_RESEARCH_WORKSPACE>/?}
].freeze

RAW_SOURCE_EXTENSIONS = %w[
  .pdf .eprint .zip .tar .tgz .gz .bbl .tex
].freeze

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

def redact_csv(path)
  table = CSV.read(path, headers: true)
  headers = table.headers
  redacted_columns = headers & %w[evidence evidence_quote]
  return 0 if redacted_columns.empty?

  CSV.open(path, "w", write_headers: true, headers: headers) do |csv|
    table.each do |row|
      redacted_columns.each { |column| row[column] = PLACEHOLDER if row[column].to_s != "" }
      csv << headers.map { |header| row[header] }
    end
  end

  redacted_columns.size
end

def replace_local_paths(path)
  return false unless text_file?(path)

  original = File.read(path)
  updated = original.dup
  LOCAL_PATH_PATTERNS.each do |pattern|
    updated = updated.gsub(pattern, "<LOCAL_RESEARCH_WORKSPACE>/")
  end
  return false if updated == original

  File.write(path, updated)
  true
end

removed_private_dirs = []
Dir.glob(File.join(ROOT, "**", "private")).each do |dir|
  next unless File.directory?(dir)

  removed_private_dirs << relative(dir)
  FileUtils.rm_rf(dir)
end

removed_raw_sources = []
Dir.glob(File.join(ROOT, "**", "*")).each do |path|
  next unless File.file?(path)
  next unless RAW_SOURCE_EXTENSIONS.include?(File.extname(path).downcase)

  removed_raw_sources << relative(path)
  FileUtils.rm_f(path)
end

redacted_csv_files = []
Dir.glob(File.join(ROOT, "**", "*.csv")).sort.each do |path|
  count = redact_csv(path)
  redacted_csv_files << relative(path) if count.positive?
end

path_rewrites = []
Dir.glob(File.join(ROOT, "**", "*")).sort.each do |path|
  next unless File.file?(path)
  next if File.extname(path).downcase == ".csv"

  path_rewrites << relative(path) if replace_local_paths(path)
end

puts "redacted_csv_files=#{redacted_csv_files.size}"
puts "removed_private_dirs=#{removed_private_dirs.size}"
puts "removed_raw_sources=#{removed_raw_sources.size}"
puts "path_rewrites=#{path_rewrites.size}"
