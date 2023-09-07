# frozen_string_literal: true

module Resolvers
  class DeploymentResolver < BaseResolver
    argument :iid,
             GraphQL::Types::ID,
             required: true,
             description: 'Project-level internal ID of the Deployment.'

    type Types::DeploymentType, null: true

    alias_method :project, :object

    def resolve(iid:)
      return unless project.present? && project.is_a?(::Project)

      Deployment.for_iid(project, iid)
    end
  end
end
