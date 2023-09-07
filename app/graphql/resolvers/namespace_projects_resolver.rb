# frozen_string_literal: true

module Resolvers
  class NamespaceProjectsResolver < BaseResolver
    argument :include_subgroups, GraphQL::Types::Boolean,
             required: false,
             default_value: false,
             description: 'Include also subgroup projects.'

    argument :not_aimed_for_deletion, GraphQL::Types::Boolean,
             required: false,
             default_value: false,
             description: 'Include projects that are not aimed for deletion.'

    argument :search, GraphQL::Types::String,
             required: false,
             default_value: nil,
             description: 'Search project with most similar names or paths.'

    argument :sort, Types::Projects::NamespaceProjectSortEnum,
            required: false,
            default_value: nil,
            description: 'Sort projects by this criteria.'

    argument :ids, [GraphQL::Types::ID],
             required: false,
             default_value: nil,
             description: 'Filter projects by IDs.'

    argument :with_issues_enabled, GraphQL::Types::Boolean,
             required: false,
             description: "Return only projects with issues enabled."

    argument :with_merge_requests_enabled, GraphQL::Types::Boolean,
             required: false,
             description: "Return only projects with merge requests enabled."

    type Types::ProjectType, null: true

    def resolve(args)
      # The namespace could have been loaded in batch by `BatchLoader`.
      # At this point we need the `id` or the `full_path` of the namespace
      # to query for projects, so make sure it's loaded and not `nil` before continuing.

      ::Namespaces::ProjectsFinder.new(
        namespace: namespace,
        current_user: current_user,
        params: finder_params(args)
      ).execute
    end

    def self.resolver_complexity(args, child_complexity:)
      complexity = super
      complexity + 10
    end

    private

    def namespace
      strong_memoize(:namespace) do
        object.respond_to?(:sync) ? object.sync : object
      end
    end

    def finder_params(args)
      {
        include_subgroups: args.dig(:include_subgroups),
        not_aimed_for_deletion: args.dig(:not_aimed_for_deletion),
        sort: args.dig(:sort),
        search: args.dig(:search),
        ids: parse_gids(args.dig(:ids)),
        with_issues_enabled: args[:with_issues_enabled],
        with_merge_requests_enabled: args[:with_merge_requests_enabled]
      }
    end

    def parse_gids(gids)
      gids&.map { |gid| GitlabSchema.parse_gid(gid, expected_type: ::Project).model_id }
    end
  end
end

Resolvers::NamespaceProjectsResolver.prepend_mod_with('Resolvers::NamespaceProjectsResolver')
