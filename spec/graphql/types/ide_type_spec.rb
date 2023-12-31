# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['Ide'], feature_category: :web_ide do
  specify { expect(described_class.graphql_name).to eq('Ide') }

  it 'has the expected fields' do
    expected_fields = %w[
      codeSuggestionsEnabled
    ]

    expect(described_class).to have_graphql_fields(*expected_fields)
  end
end
