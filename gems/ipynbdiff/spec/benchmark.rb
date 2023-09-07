# frozen_string_literal: true

require 'ipynbdiff'
require 'benchmark'
require 'benchmark/memory'
require_relative 'test_helper'

# rubocop:disable Layout/LineLength
large_cell = '{
  "cell_type": "code",
  "execution_count": 9,
  "id": "24f32781-48bf-4378-b30c-ccdce7b05ba0",
  "metadata": {},
  "outputs": [
    {
      "data": {
        "image/png": "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\n",
        "text/plain": [
          "<Figure size 2000x600 with 1 Axes>"
        ]
      },
      "metadata": {
        "needs_background": "light"
      },
      "output_type": "display_data"
    }
  ],
  "source": [
    "do_plot(is_sin = False)"
  ]
},'
# rubocop:enable Layout/LineLength

base = '{
 "cells": [
    <<>>{
    "cell_type": "markdown",
    "id": "1",
    "metadata": {
     "tags": [
        "hello",
        "world"
     ]
    },
    "source": [
     "# A\n",
     "\n",
     "B"
    ]
   }
 ],
 "metadata": {
 }
}'

SMALL_NOTEBOOK = base.gsub('<<>>', large_cell)
LARGE_NOTEBOOK = base.gsub('<<>>', Array.new(100, large_cell).join("\n"))

puts "Small Notebook: #{SMALL_NOTEBOOK.bytesize}"
puts "Large Notebook: #{LARGE_NOTEBOOK.bytesize}"

def cases(benchmark_runner)
  benchmark_runner.report('small_notebook') { IpynbDiff.transform(SMALL_NOTEBOOK) }
  benchmark_runner.report('large_notebook') { IpynbDiff.transform(LARGE_NOTEBOOK) }
end

Benchmark.benchmark { |x| cases(x) }
Benchmark.memory { |x| cases(x) }
