// eslint-disable-next-line no-restricted-imports
import { mapGetters } from 'vuex';

export default {
  computed: {
    ...mapGetters(['getNoteableDataByProp']),
    isProjectArchived() {
      return this.getNoteableDataByProp('is_project_archived');
    },
    archivedProjectDocsPath() {
      return this.getNoteableDataByProp('archived_project_docs_path');
    },
    lockedIssueDocsPath() {
      return this.getNoteableDataByProp('locked_discussion_docs_path');
    },
  },
  methods: {
    isLocked(issue) {
      return Boolean(issue.discussion_locked);
    },
  },
};
