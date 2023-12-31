import { GlBadge, GlIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import StatusBadge from '~/issuable/components/status_badge.vue';

describe('StatusBadge component', () => {
  let wrapper;

  const mountComponent = (propsData) => {
    wrapper = shallowMount(StatusBadge, { propsData });
  };

  const findBadge = () => wrapper.findComponent(GlBadge);

  describe.each`
    issuableType       | badgeText   | state       | badgeVariant | badgeIcon
    ${'merge_request'} | ${'Open'}   | ${'opened'} | ${'success'} | ${'merge-request-open'}
    ${'merge_request'} | ${'Closed'} | ${'closed'} | ${'danger'}  | ${'merge-request-close'}
    ${'merge_request'} | ${'Merged'} | ${'merged'} | ${'info'}    | ${'merge'}
    ${'issue'}         | ${'Open'}   | ${'opened'} | ${'success'} | ${'issues'}
    ${'issue'}         | ${'Closed'} | ${'closed'} | ${'info'}    | ${'issue-closed'}
    ${'epic'}          | ${'Open'}   | ${'opened'} | ${'success'} | ${'epic'}
    ${'epic'}          | ${'Closed'} | ${'closed'} | ${'info'}    | ${'epic-closed'}
  `(
    'when issuableType=$issuableType and state=$state',
    ({ issuableType, badgeText, state, badgeVariant, badgeIcon }) => {
      beforeEach(() => {
        mountComponent({ state, issuableType });
      });

      it(`renders badge with text '${badgeText}'`, () => {
        expect(findBadge().text()).toBe(badgeText);
      });

      it(`sets badge variant as '${badgeVariant}`, () => {
        expect(findBadge().props('variant')).toBe(badgeVariant);
      });

      it(`sets badge icon as '${badgeIcon}'`, () => {
        expect(findBadge().findComponent(GlIcon).props('name')).toBe(badgeIcon);
      });
    },
  );
});
