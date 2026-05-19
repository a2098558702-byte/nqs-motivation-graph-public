#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
PUBLIC_FRAMEWORK = File.join(ROOT, "experiments", "current_coverage_v0_adaptive_g6_assay")
PRIVATE_FRAMEWORK = File.join(ROOT, "trajectory_experiments", "current_coverage_v0_adaptive_g6_assay")
FRAMEWORK = Dir.exist?(PUBLIC_FRAMEWORK) ? PUBLIC_FRAMEWORK : PRIVATE_FRAMEWORK
RUN_ID = ARGV[0] || abort("Usage: ruby scripts/check_adaptive_candidate_internal_outputs_v0.rb RUN_ID")
UNIT_ID = "unit_906"
RUN_DIR = File.join(FRAMEWORK, "model_runs", RUN_ID)
ROUNDS = File.join(RUN_DIR, "rounds")
AUDITS = File.join(RUN_DIR, "audits")

TABLE_HEADER = /\|\s*claim_id\s*\|\s*step_index\s*\|\s*from_item_id\s*\|\s*link_id\s*\|\s*to_item_id\s*\|\s*traversal\s*\|\s*why_step_matters\s*\|/i

def read_csv(path)
  return [] unless File.exist?(path)

  CSV.read(path, headers: true).map(&:to_h)
end

def write_csv(path, headers, rows)
  CSV.open(path, "w", write_headers: true, headers: headers) do |csv|
    rows.each { |row| csv << headers.map { |header| row[header] } }
  end
end

def parse_tables(text, round)
  rows = []
  lines = text.lines
  index = 0
  while index < lines.length
    unless lines[index].match?(TABLE_HEADER)
      index += 1
      next
    end
    index += 1
    index += 1 if index < lines.length && lines[index].include?("---")
    while index < lines.length && lines[index].strip.start_with?("|")
      cells = lines[index].strip.split("|", -1)[1...-1].map { |cell| cell.strip.gsub(/\A`|`\z/, "") }
      if cells.length >= 7
        rows << {
          "round" => round,
          "claim_id" => cells[0],
          "step_index" => cells[1],
          "from_item_id" => cells[2],
          "link_id" => cells[3],
          "to_item_id" => cells[4],
          "traversal" => cells[5].downcase,
          "why_step_matters" => cells[6]
        }
      end
      index += 1
    end
  end
  rows
end

def links_for_round(run_dir, round)
  case round
  when "round0"
    read_csv(File.join(FRAMEWORK, "inputs", "round0_candidate_links.csv"))
  when "round1"
    read_csv(File.join(run_dir, "packets", "round1", "internal_links.csv"))
  when "round2"
    read_csv(File.join(run_dir, "packets", "round2", "internal_links.csv"))
  else
    []
  end
end

abort("Missing rounds dir: #{ROUNDS}") unless Dir.exist?(ROUNDS)
FileUtils.mkdir_p(AUDITS)

detail_rows = []
summary_rows = []

%w[round0 round1 round2].each do |round|
  output = File.join(ROUNDS, "#{UNIT_ID}_#{round}.md")
  abort("Missing output: #{output}") unless File.exist?(output)

  parsed = parse_tables(File.read(output), round)
  links = links_for_round(RUN_DIR, round).each_with_object({}) { |row, index| index[row["link_id"]] = row }

  valid = 0
  invalid = 0
  missing = 0
  endpoint_mismatch = 0
  continuity_breaks = 0

  parsed.group_by { |row| row["claim_id"] }.each_value do |claim_rows|
    claim_rows.sort_by { |row| row["step_index"].to_i }.each_cons(2) do |left, right|
      continuity_breaks += 1 unless left["to_item_id"] == right["from_item_id"]
    end
  end

  parsed.each do |row|
    link = links[row["link_id"]]
    if link.nil?
      missing += 1
      invalid += 1
      detail_rows << row.merge("status" => "missing_link_id", "expected_from_item_id" => "", "expected_to_item_id" => "")
      next
    end

    expected_from = link["from_item_id"]
    expected_to = link["to_item_id"]
    endpoints_ok =
      if row["traversal"] == "reverse"
        row["from_item_id"] == expected_to && row["to_item_id"] == expected_from
      else
        row["from_item_id"] == expected_from && row["to_item_id"] == expected_to
      end

    endpoint_mismatch += 1 unless endpoints_ok
    status = endpoints_ok ? "ok" : "endpoint_or_traversal_mismatch"
    valid += 1 if status == "ok"
    invalid += 1 unless status == "ok"
    detail_rows << row.merge("status" => status, "expected_from_item_id" => expected_from, "expected_to_item_id" => expected_to)
  end

  summary_rows << {
    "round" => round,
    "parsed_link_steps" => parsed.size,
    "valid_link_steps" => valid,
    "invalid_link_steps" => invalid,
    "missing_link_ids" => missing,
    "endpoint_mismatches" => endpoint_mismatch,
    "path_continuity_breaks" => continuity_breaks
  }
end

write_csv(
  File.join(AUDITS, "adaptive_link_audit_summary.csv"),
  %w[round parsed_link_steps valid_link_steps invalid_link_steps missing_link_ids endpoint_mismatches path_continuity_breaks],
  summary_rows
)

write_csv(
  File.join(AUDITS, "adaptive_link_audit_details.csv"),
  %w[round claim_id step_index from_item_id link_id to_item_id traversal why_step_matters status expected_from_item_id expected_to_item_id],
  detail_rows
)

File.write(File.join(AUDITS, "ADAPTIVE_LINK_AUDIT.md"), <<~MD)
  # Adaptive G6 Link Audit

  | round | parsed_link_steps | valid_link_steps | invalid_link_steps | endpoint_mismatches | path_continuity_breaks |
  |---|---:|---:|---:|---:|---:|
  #{summary_rows.map { |row| "| #{row["round"]} | #{row["parsed_link_steps"]} | #{row["valid_link_steps"]} | #{row["invalid_link_steps"]} | #{row["endpoint_mismatches"]} | #{row["path_continuity_breaks"]} |" }.join("\n")}
MD

puts "audit=#{File.join(AUDITS, "ADAPTIVE_LINK_AUDIT.md")}"
summary_rows.each do |row|
  puts "#{row["round"]} parsed=#{row["parsed_link_steps"]} valid=#{row["valid_link_steps"]} invalid=#{row["invalid_link_steps"]} continuity=#{row["path_continuity_breaks"]}"
end
