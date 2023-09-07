# frozen_string_literal: true

module Gitlab
  module EtagCaching
    module Router
      class Rails
        extend EtagCaching::Router::Helpers

        # We enable an ETag for every request matching the regex.
        # To match a regex the path needs to match the following:
        #   - Don't contain a reserved word (expect for the words used in the
        #     regex itself)
        #   - Ending in `noteable/issue/<id>/notes` for the `issue_notes` route
        #   - Ending in `issues/id`/realtime_changes` for the `issue_title` route
        USED_IN_ROUTES = %w[noteable issue notes issues realtime_changes
                            commit pipelines merge_requests builds
                            new environments].freeze
        RESERVED_WORDS = Gitlab::PathRegex::ILLEGAL_PROJECT_PATH_WORDS - USED_IN_ROUTES
        RESERVED_WORDS_REGEX = Regexp.union(*RESERVED_WORDS.map(&Regexp.method(:escape)))
        RESERVED_WORDS_PREFIX = %(^(?!.*\/(#{RESERVED_WORDS_REGEX})\/).*)

        ROUTES = [
          [
            %r(#{RESERVED_WORDS_PREFIX}/noteable/issue/\d+/notes\z),
            'issue_notes',
            ::Projects::NotesController,
            :index
          ],
          [
            %r(#{RESERVED_WORDS_PREFIX}/noteable/merge_request/\d+/notes\z),
            'merge_request_notes',
            ::Projects::NotesController,
            :index
          ],
          [
            %r(#{RESERVED_WORDS_PREFIX}/issues/\d+/realtime_changes\z),
            'issue_title',
            ::Projects::IssuesController,
            :realtime_changes
          ],
          [
            %r(#{RESERVED_WORDS_PREFIX}/commit/\S+/pipelines\.json\z),
            'commit_pipelines',
            ::Projects::CommitController,
            :pipelines
          ],
          [
            %r(#{RESERVED_WORDS_PREFIX}/merge_requests/new\.json\z),
            'new_merge_request_pipelines',
            ::Projects::MergeRequests::CreationsController,
            :new
          ],
          [
            %r(#{RESERVED_WORDS_PREFIX}/merge_requests/\d+/pipelines\.json\z),
            'merge_request_pipelines',
            ::Projects::MergeRequestsController,
            :pipelines
          ],
          [
            %r(#{RESERVED_WORDS_PREFIX}/pipelines\.json\z),
            'project_pipelines',
            ::Projects::PipelinesController,
            :index
          ],
          [
            %r(#{RESERVED_WORDS_PREFIX}/pipelines/\d+\.json\z),
            'project_pipeline',
            ::Projects::PipelinesController,
            :show
          ],
          [
            %r(#{RESERVED_WORDS_PREFIX}/builds/\d+\.json\z),
            'project_build',
            ::Projects::BuildsController,
            :show
          ],
          [
            %r(#{RESERVED_WORDS_PREFIX}/clusters/\d+/environments\z),
            'cluster_environments',
            ::Groups::ClustersController,
            :environments
          ],
          [
            %r(#{RESERVED_WORDS_PREFIX}/-/environments\.json\z),
            'environments',
            ::Projects::EnvironmentsController,
            :index
          ],
          [
            %r(#{RESERVED_WORDS_PREFIX}/import/github/realtime_changes\.json\z),
            'realtime_changes_import_github',
            ::Import::GithubController,
            :realtime_changes
          ],
          [
            %r(#{RESERVED_WORDS_PREFIX}/import/gitea/realtime_changes\.json\z),
            'realtime_changes_import_gitea',
            ::Import::GiteaController,
            :realtime_changes
          ],
          [
            %r(#{RESERVED_WORDS_PREFIX}/merge_requests/\d+/cached_widget\.json\z),
            'merge_request_widget',
            ::Projects::MergeRequests::ContentController,
            :cached_widget
          ]
        ].map { |attrs| build_rails_route(*attrs) }.freeze

        # Overridden in EE to add more routes
        def self.all_routes
          ROUTES
        end

        def self.match(request)
          all_routes.find { |route| route.match(request.path_info) }
        end

        def self.cache_key(request)
          request.path
        end
      end
    end
  end
end

Gitlab::EtagCaching::Router::Rails.prepend_mod_with('Gitlab::EtagCaching::Router::Rails')
