# frozen_string_literal: true

class Ci::BuildPendingState < Ci::ApplicationRecord
  include Ci::Partitionable
  include SafelyChangeColumnDefault

  columns_changing_default :partition_id

  belongs_to :build, class_name: 'Ci::Build', foreign_key: :build_id, inverse_of: :pending_state

  partitionable scope: :build

  enum state: Ci::Stage.statuses
  enum failure_reason: CommitStatus.failure_reasons

  validates :build, presence: true

  def crc32
    trace_checksum.try do |checksum|
      checksum.to_s.split('crc32:').last.to_i(16)
    end
  end
end
