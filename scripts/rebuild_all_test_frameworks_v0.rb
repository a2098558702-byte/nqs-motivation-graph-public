#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("..", __dir__)

steps = [
  ["Backfill missing reference lists", ["ruby", File.join(ROOT, "scripts", "backfill_missing_reference_lists_from_arxiv.rb")]],
  ["Build current coverage graph", ["ruby", File.join(ROOT, "scripts", "build_current_coverage_graph_v0.rb")]],
  ["Build open-ended trajectory framework", ["ruby", File.join(ROOT, "scripts", "build_current_coverage_test_framework_v0.rb")]],
  ["Build edge dependency assay", ["ruby", File.join(ROOT, "scripts", "build_edge_dependency_assay_v0.rb")]]
]

steps.each do |name, command|
  puts "\n== #{name} =="
  abort("Failed: #{name}") unless system(*command)
end

puts "\nAll test frameworks rebuilt."
