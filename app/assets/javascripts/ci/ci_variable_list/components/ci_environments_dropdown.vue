<script>
import { debounce, uniq } from 'lodash';
import { GlDropdownDivider, GlDropdownItem, GlCollapsibleListbox, GlSprintf } from '@gitlab/ui';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { __, s__, sprintf } from '~/locale';
import { convertEnvironmentScope } from '../utils';
import { ENVIRONMENT_QUERY_LIMIT } from '../constants';

export default {
  name: 'CiEnvironmentsDropdown',
  components: {
    GlCollapsibleListbox,
    GlDropdownDivider,
    GlDropdownItem,
    GlSprintf,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    areEnvironmentsLoading: {
      type: Boolean,
      required: true,
    },
    environments: {
      type: Array,
      required: true,
    },
    hasEnvScopeQuery: {
      type: Boolean,
      required: true,
    },
    selectedEnvironmentScope: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      isDropdownShown: false,
      selectedEnvironment: '',
      searchTerm: '',
    };
  },
  computed: {
    composedCreateButtonLabel() {
      return sprintf(__('Create wildcard: %{searchTerm}'), { searchTerm: this.searchTerm });
    },
    filteredEnvironments() {
      const lowerCasedSearchTerm = this.searchTerm.toLowerCase();
      return this.environments.filter((environment) => {
        return environment.toLowerCase().includes(lowerCasedSearchTerm);
      });
    },
    isDropdownLoading() {
      return this.areEnvironmentsLoading && this.hasEnvScopeQuery && !this.isDropdownShown;
    },
    isDropdownSearching() {
      return this.areEnvironmentsLoading && this.hasEnvScopeQuery && this.isDropdownShown;
    },
    searchedEnvironments() {
      // If hasEnvScopeQuery (applies only to projects for now), search query will be fired so this
      // component will already receive filtered environments during the refetch.
      // Otherwise (applies to groups), search the existing list of environments in the frontend
      let filtered = this.hasEnvScopeQuery ? this.environments : this.filteredEnvironments;

      // If there is no search term, make sure to include *
      if (this.hasEnvScopeQuery && !this.searchTerm) {
        filtered = uniq([...filtered, '*']);
      }

      return filtered.sort().map((environment) => ({
        value: environment,
        text: environment,
      }));
    },
    shouldRenderCreateButton() {
      return this.searchTerm && !this.environments.includes(this.searchTerm);
    },
    shouldRenderDivider() {
      return (
        (this.hasEnvScopeQuery || this.shouldRenderCreateButton) && !this.areEnvironmentsLoading
      );
    },
    environmentScopeLabel() {
      return convertEnvironmentScope(this.selectedEnvironmentScope);
    },
  },
  methods: {
    debouncedSearch: debounce(function debouncedSearch(searchTerm) {
      const newSearchTerm = searchTerm.trim();
      this.searchTerm = newSearchTerm;
      if (this.hasEnvScopeQuery) {
        this.$emit('search-environment-scope', newSearchTerm);
      }
    }, 500),
    selectEnvironment(selected) {
      this.$emit('select-environment', selected);
      this.selectedEnvironment = selected;
    },
    createEnvironmentScope() {
      this.$emit('create-environment-scope', this.searchTerm);
      this.selectEnvironment(this.searchTerm);
    },
    toggleDropdownShown(isShown) {
      this.isDropdownShown = isShown;
    },
  },
  ENVIRONMENT_QUERY_LIMIT,
  i18n: {
    maxEnvsNote: s__(
      'CiVariable|Maximum of %{limit} environments listed. For more environments, enter a search query.',
    ),
  },
};
</script>
<template>
  <gl-collapsible-listbox
    v-model="selectedEnvironment"
    block
    searchable
    :items="searchedEnvironments"
    :loading="isDropdownLoading"
    :searching="isDropdownSearching"
    :toggle-text="environmentScopeLabel"
    @search="debouncedSearch"
    @select="selectEnvironment"
    @shown="toggleDropdownShown(true)"
    @hidden="toggleDropdownShown(false)"
  >
    <template #footer>
      <gl-dropdown-divider v-if="shouldRenderDivider" />
      <div v-if="hasEnvScopeQuery" data-testid="max-envs-notice">
        <gl-dropdown-item class="gl-list-style-none" disabled>
          <gl-sprintf :message="$options.i18n.maxEnvsNote" class="gl-font-sm">
            <template #limit>
              {{ $options.ENVIRONMENT_QUERY_LIMIT }}
            </template>
          </gl-sprintf>
        </gl-dropdown-item>
      </div>
      <div v-if="shouldRenderCreateButton">
        <!-- TODO: Rethink create wildcard button. https://gitlab.com/gitlab-org/gitlab/-/issues/396928 -->
        <gl-dropdown-item
          class="gl-list-style-none"
          data-testid="create-wildcard-button"
          @click="createEnvironmentScope"
        >
          {{ composedCreateButtonLabel }}
        </gl-dropdown-item>
      </div>
    </template>
  </gl-collapsible-listbox>
</template>
