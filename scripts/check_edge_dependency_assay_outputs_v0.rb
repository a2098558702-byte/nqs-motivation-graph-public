#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
PUBLIC_FRAMEWORK = File.join(ROOT, "experiments", "current_coverage_v0_edge_dependency_assay")
PRIVATE_FRAMEWORK = File.join(ROOT, "trajectory_experiments", "current_coverage_v0_edge_dependency_assay")
FRAMEWORK = Dir.exist?(PUBLIC_FRAMEWORK) ? PUBLIC_FRAMEWORK : PRIVATE_FRAMEWORK
PUBLIC_SEALED = File.join(FRAMEWORK, "inputs", "redacted_sealed_trial_v1")
PRIVATE_SEALED = File.join(ROOT, "trajectory_experiments", "sealed_trial_v1")
SEALED = Dir.exist?(PUBLIC_SEALED) ? PUBLIC_SEALED : PRIVATE_SEALED
RUN_ID = ARGV[0] || abort("Usage: ruby scripts/check_edge_dependency_assay_outputs_v0.rb RUN_ID")
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

def parse_markdown_link_tables(text)
  rows = []
  lines = text.lines
  index = 0
  current_round = "unknown"
  while index < lines.length
    stripped = lines[index].strip.downcase
    current_round = "round0" if stripped.include?("round0") || stripped.include?("round 0")
    current_round = "round1" if stripped.include?("round1") || stripped.include?("round 1")
    current_round = "round2" if stripped.include?("round2") || stripped.include?("round 2")

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
          "claim_id" => cells[0],
          "step_index" => cells[1],
          "from_item_id" => cells[2],
          "link_id" => cells[3],
          "to_item_id" => cells[4],
          "traversal" => cells[5].downcase,
          "why_step_matters" => cells[6],
          "table_round" => current_round
        }
      end
      index += 1
    end
  end
  rows
end

def links_for_unit(unit)
  dir = File.join(SEALED, unit)
  links = []
  links.concat(read_csv(File.join(dir, "links.csv")).map { |row| row.merge("allowed_round" => "round0") })
  links.concat(read_csv(File.join(dir, "update_a_links.csv")).map { |row| row.merge("allowed_round" => "round1") })
  links.concat(read_csv(File.join(dir, "update_b_links.csv")).map { |row| row.merge("allowed_round" => "round2") })
  links
end

def round_rank(link_id)
  return 0 if link_id.start_with?("L")
  return 1 if link_id.start_with?("A")
  return 2 if link_id.start_with?("B")

  99
end

def table_round_rank(table_round)
  return 0 if table_round == "round0"
  return 1 if table_round == "round1"
  return 2 if table_round == "round2"

  99
end

abort("Missing run rounds directory: #{ROUNDS}") unless Dir.exist?(ROUNDS)
FileUtils.mkdir_p(AUDITS)

summary_rows = []
detail_rows = []

Dir.children(ROUNDS).grep(/\Aunit_\d+_trajectory\.md\z/).sort.each do |file|
  unit = file.sub(/_trajectory\.md\z/, "")
  text = File.read(File.join(ROUNDS, file))
  parsed_rows = parse_markdown_link_tables(text)
  link_index = links_for_unit(unit).each_with_object({}) { |row, index| index[row["link_id"]] = row }

  valid = 0
  invalid = 0
  missing = 0
  endpoint_mismatch = 0
  traversal_bad = 0
  continuity_bad = 0
  future_round_suspect = 0
  future_round_violation = 0

  rows_by_claim = parsed_rows.group_by { |row| row["claim_id"] }
  rows_by_claim.each_value do |claim_rows|
    sorted = claim_rows.sort_by { |row| row["step_index"].to_i }
    sorted.each_cons(2) do |left, right|
      continuity_bad += 1 unless left["to_item_id"] == right["from_item_id"]
    end
  end

  parsed_rows.each do |row|
    link = link_index[row["link_id"]]
    if link.nil?
      missing += 1
      invalid += 1
      detail_rows << row.merge(
        "unit_id" => unit,
        "status" => "missing_link_id",
        "expected_from_item_id" => "",
        "expected_to_item_id" => "",
        "allowed_round" => ""
      )
      next
    end

    expected_from = link["from_item_id"]
    expected_to = link["to_item_id"]
    traversal = row["traversal"]
    traversal_ok = %w[forward reverse].include?(traversal)
    endpoints_ok =
      if traversal == "reverse"
        row["from_item_id"] == expected_to && row["to_item_id"] == expected_from
      else
        row["from_item_id"] == expected_from && row["to_item_id"] == expected_to
      end

    traversal_bad += 1 unless traversal_ok
    endpoint_mismatch += 1 unless endpoints_ok
    future_round_suspect += 1 if round_rank(row["link_id"]) == 99
    round_ok = round_rank(row["link_id"]) <= table_round_rank(row["table_round"])
    future_round_violation += 1 unless round_ok

    status =
      if traversal_ok && endpoints_ok && round_ok
        "ok"
      elsif !round_ok
        "future_round_link_used"
      else
        "endpoint_or_traversal_mismatch"
      end
    valid += 1 if status == "ok"
    invalid += 1 unless status == "ok"
    detail_rows << row.merge(
      "unit_id" => unit,
      "status" => status,
      "expected_from_item_id" => expected_from,
        "expected_to_item_id" => expected_to,
        "allowed_round" => link["allowed_round"]
      )
  end

  summary_rows << {
    "unit_id" => unit,
    "trajectory_file" => File.join(ROUNDS, file).sub(ROOT + "/", ""),
    "parsed_link_steps" => parsed_rows.size,
    "valid_link_steps" => valid,
    "invalid_link_steps" => invalid,
    "missing_link_ids" => missing,
    "endpoint_mismatches" => endpoint_mismatch,
    "bad_traversal_values" => traversal_bad,
    "path_continuity_breaks" => continuity_bad,
    "unknown_prefix_link_ids" => future_round_suspect,
    "future_round_link_violations" => future_round_violation,
    "insufficient_link_support_mentions" => text.scan(/insufficient_link_support/i).size,
    "node_local_fallback_mentions" => text.scan(/node_local_fallback_only/i).size
  }
end

abort("No trajectory files found under #{ROUNDS}") if summary_rows.empty?

write_csv(
  File.join(AUDITS, "mechanical_link_audit_summary.csv"),
  %w[
    unit_id trajectory_file parsed_link_steps valid_link_steps invalid_link_steps
    missing_link_ids endpoint_mismatches bad_traversal_values path_continuity_breaks
    unknown_prefix_link_ids future_round_link_violations
    insufficient_link_support_mentions node_local_fallback_mentions
  ],
  summary_rows
)

write_csv(
  File.join(AUDITS, "mechanical_link_audit_details.csv"),
  %w[
    unit_id claim_id step_index table_round from_item_id link_id to_item_id traversal why_step_matters
    status expected_from_item_id expected_to_item_id allowed_round
  ],
  detail_rows
)

markdown_rows = summary_rows.map do |row|
  "| #{row["unit_id"]} | #{row["parsed_link_steps"]} | #{row["valid_link_steps"]} | #{row["invalid_link_steps"]} | #{row["path_continuity_breaks"]} | #{row["future_round_link_violations"]} | #{row["insufficient_link_support_mentions"]} |"
end

File.write(File.join(AUDITS, "MECHANICAL_LINK_AUDIT.md"), <<~MD)
  # Mechanical Link Audit

  This audit checks only mechanical claims in the required link-step tables. It does not score scientific quality.

  | unit_id | parsed_link_steps | valid_link_steps | invalid_link_steps | path_continuity_breaks | future_round_link_violations | insufficient_link_support_mentions |
  |---|---:|---:|---:|---:|---:|---:|
  #{markdown_rows.join("\n")}

  Detail CSV:

  - `mechanical_link_audit_summary.csv`
  - `mechanical_link_audit_details.csv`
MD

puts "audit_dir=#{AUDITS}"
summary_rows.each do |row|
  puts [
    row["unit_id"],
    "parsed=#{row["parsed_link_steps"]}",
    "valid=#{row["valid_link_steps"]}",
    "invalid=#{row["invalid_link_steps"]}",
    "continuity_breaks=#{row["path_continuity_breaks"]}"
  ].join(" ")
end
