import Vue from 'vue';
// eslint-disable-next-line no-restricted-imports
import Vuex from 'vuex';
import batchCommentsModule from '~/batch_comments/stores/modules/batch_comments';
import diffsModule from '~/diffs/store/modules';
import notesModule from '~/notes/stores/modules';
import findingsDrawer from '~/mr_notes/stores/drawer';

Vue.use(Vuex);

export default function createDiffsStore() {
  return new Vuex.Store({
    modules: {
      page: {
        namespaced: true,
        state: {
          activeTab: 'notes',
        },
      },
      diffs: diffsModule(),
      notes: notesModule(),
      batchComments: batchCommentsModule(),
      findingsDrawer: findingsDrawer(),
    },
  });
}
