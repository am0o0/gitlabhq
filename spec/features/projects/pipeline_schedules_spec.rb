# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Pipeline Schedules', :js, feature_category: :groups_and_projects do
  include Spec::Support::Helpers::ModalHelpers

  let!(:project) { create(:project, :repository) }
  let!(:pipeline_schedule) { create(:ci_pipeline_schedule, :nightly, project: project) }
  let!(:pipeline) { create(:ci_pipeline, pipeline_schedule: pipeline_schedule, project: project) }
  let(:scope) { nil }
  let!(:user) { create(:user) }
  let!(:maintainer) { create(:user) }

  context 'logged in as the pipeline schedule owner' do
    before do
      project.add_developer(user)
      pipeline_schedule.update!(owner: user)
      gitlab_sign_in(user)
    end

    describe 'GET /projects/pipeline_schedules' do
      before do
        visit_pipelines_schedules
      end

      it 'edits the pipeline' do
        page.find('[data-testid="edit-pipeline-schedule-btn"]').click

        expect(page).to have_content(s_('PipelineSchedules|Edit pipeline schedule'))
      end
    end

    describe 'PATCH /projects/pipelines_schedules/:id/edit' do
      before do
        edit_pipeline_schedule
      end

      it 'displays existing properties' do
        description = find_field('schedule-description').value
        expect(description).to eq('pipeline schedule')
        expect(page).to have_button('master')
        expect(page).to have_button(_('Select timezone'))
      end

      it 'edits the scheduled pipeline' do
        fill_in 'schedule-description', with: 'my brand new description'

        save_pipeline_schedule

        expect(page).to have_content('my brand new description')
      end

      context 'when ref is nil' do
        before do
          pipeline_schedule.update_attribute(:ref, nil)
          edit_pipeline_schedule
        end

        it 'shows the pipeline schedule with default ref' do
          page.within('#schedule-target-branch-tag') do
            expect(first('.gl-button-text').text).to eq('master')
          end
        end
      end

      context 'when ref is empty' do
        before do
          pipeline_schedule.update_attribute(:ref, '')
          edit_pipeline_schedule
        end

        it 'shows the pipeline schedule with default ref' do
          page.within('#schedule-target-branch-tag') do
            expect(first('.gl-button-text').text).to eq('master')
          end
        end
      end
    end
  end

  context 'logged in as a project maintainer' do
    before do
      project.add_maintainer(user)
      pipeline_schedule.update!(owner: maintainer)
      gitlab_sign_in(user)
    end

    describe 'GET /projects/pipeline_schedules' do
      before do
        visit_pipelines_schedules

        wait_for_requests
      end

      describe 'The view' do
        it 'displays the required information description' do
          page.within('[data-testid="pipeline-schedule-table-row"]') do
            expect(page).to have_content('pipeline schedule')
            expect(find('[data-testid="next-run-cell"] time')['title'])
              .to include(pipeline_schedule.real_next_run.strftime('%b %-d, %Y'))
            expect(page).to have_link('master')
            expect(find("[data-testid='last-pipeline-status'] a")['href']).to include(pipeline.id.to_s)
          end
        end

        it 'creates a new scheduled pipeline' do
          click_link 'New schedule'

          expect(page).to have_content('Schedule a new pipeline')
        end

        it 'changes ownership of the pipeline' do
          find("[data-testid='take-ownership-pipeline-schedule-btn']").click

          page.within('#pipeline-take-ownership-modal') do
            click_button s_('PipelineSchedules|Take ownership')

            wait_for_requests
          end

          page.within('[data-testid="pipeline-schedule-table-row"]') do
            expect(page).not_to have_content('No owner')
            expect(page).to have_link('Sidney Jones')
          end
        end

        it 'deletes the pipeline' do
          page.within('[data-testid="pipeline-schedule-table-row"]') do
            click_button s_('PipelineSchedules|Delete pipeline schedule')
          end

          accept_gl_confirm(button_text: s_('PipelineSchedules|Delete pipeline schedule'))

          expect(page).not_to have_css('[data-testid="pipeline-schedule-table-row"]')
        end
      end

      context 'when ref is nil' do
        before do
          pipeline_schedule.update_attribute(:ref, nil)
          visit_pipelines_schedules
          wait_for_requests
        end

        it 'shows a list of the pipeline schedules with empty ref column' do
          target = find('[data-testid="pipeline-schedule-target"]')

          page.within('[data-testid="pipeline-schedule-table-row"]') do
            expect(target.text).to eq(s_('PipelineSchedules|None'))
          end
        end
      end

      context 'when ref is empty' do
        before do
          pipeline_schedule.update_attribute(:ref, '')
          visit_pipelines_schedules
          wait_for_requests
        end

        it 'shows a list of the pipeline schedules with empty ref column' do
          target = find('[data-testid="pipeline-schedule-target"]')

          expect(target.text).to eq(s_('PipelineSchedules|None'))
        end
      end
    end

    describe 'POST /projects/pipeline_schedules/new' do
      before do
        visit_new_pipeline_schedule
      end

      it 'sets defaults for timezone and target branch' do
        expect(page).to have_button('master')
        expect(page).to have_button('Select timezone')
      end

      it 'creates a new scheduled pipeline' do
        fill_in_schedule_form
        create_pipeline_schedule

        expect(page).to have_content('my fancy description')
      end

      it 'prevents an invalid form from being submitted' do
        create_pipeline_schedule

        expect(page).to have_content("Cron timezone can't be blank")
      end
    end

    context 'when user creates a new pipeline schedule with variables' do
      before do
        visit_pipelines_schedules
        click_link 'New schedule'
        fill_in_schedule_form
        all('[name="schedule[variables_attributes][][key]"]')[0].set('AAA')
        all('[name="schedule[variables_attributes][][secret_value]"]')[0].set('AAA123')
        all('[name="schedule[variables_attributes][][key]"]')[1].set('BBB')
        all('[name="schedule[variables_attributes][][secret_value]"]')[1].set('BBB123')
        create_pipeline_schedule
      end

      it 'user sees the new variable in edit window', quarantine: 'https://gitlab.com/gitlab-org/gitlab/-/issues/397040' do
        find(".content-list .pipeline-schedule-table-row:nth-child(1) .btn-group a[title='Edit']").click
        page.within('.ci-variable-list') do
          expect(find(".ci-variable-row:nth-child(1) .js-ci-variable-input-key").value).to eq('AAA')
          expect(find(".ci-variable-row:nth-child(1) .js-ci-variable-input-value", visible: false).value).to eq('AAA123')
          expect(find(".ci-variable-row:nth-child(2) .js-ci-variable-input-key").value).to eq('BBB')
          expect(find(".ci-variable-row:nth-child(2) .js-ci-variable-input-value", visible: false).value).to eq('BBB123')
        end
      end
    end

    context 'when user edits a variable of a pipeline schedule' do
      before do
        create(:ci_pipeline_schedule, project: project, owner: user).tap do |pipeline_schedule|
          create(:ci_pipeline_schedule_variable, key: 'AAA', value: 'AAA123', pipeline_schedule: pipeline_schedule)
        end

        visit_pipelines_schedules
        first('[data-testid="edit-pipeline-schedule-btn"]').click
        click_button _('Reveal values')
        first('[data-testid="pipeline-form-ci-variable-key"]').set('foo')
        first('[data-testid="pipeline-form-ci-variable-value"]').set('bar')
        save_pipeline_schedule
      end

      it 'user sees the updated variable' do
        first('[data-testid="edit-pipeline-schedule-btn"]').click

        expect(first('[data-testid="pipeline-form-ci-variable-key"]').value).to eq('foo')
        expect(first('[data-testid="pipeline-form-ci-variable-value"]').value).to eq('')

        click_button _('Reveal values')

        expect(first('[data-testid="pipeline-form-ci-variable-value"]').value).to eq('bar')
      end
    end

    context 'when user removes a variable of a pipeline schedule' do
      before do
        create(:ci_pipeline_schedule, project: project, owner: user).tap do |pipeline_schedule|
          create(:ci_pipeline_schedule_variable, key: 'AAA', value: 'AAA123', pipeline_schedule: pipeline_schedule)
        end

        visit_pipelines_schedules
        first('[data-testid="edit-pipeline-schedule-btn"]').click
        find('[data-testid="remove-ci-variable-row"]').click
        save_pipeline_schedule
      end

      it 'user does not see the removed variable in edit window' do
        first('[data-testid="edit-pipeline-schedule-btn"]').click

        expect(first('[data-testid="pipeline-form-ci-variable-key"]').value).to eq('')
        expect(first('[data-testid="pipeline-form-ci-variable-value"]').value).to eq('')
      end
    end

    context 'when active is true and next_run_at is NULL' do
      before do
        create(:ci_pipeline_schedule, project: project, owner: user).tap do |pipeline_schedule|
          pipeline_schedule.update_attribute(:next_run_at, nil) # Consequently next_run_at will be nil
        end
      end

      it 'user edit and recover the problematic pipeline schedule' do
        visit_pipelines_schedules
        first('[data-testid="edit-pipeline-schedule-btn"]').click
        fill_in 'schedule_cron', with: '* 1 2 3 4'
        save_pipeline_schedule

        page.within(first('[data-testid="pipeline-schedule-table-row"]')) do
          expect(page).to have_css("[data-testid='next-run-cell'] time")
        end
      end
    end
  end

  context 'logged in as non-member' do
    before do
      gitlab_sign_in(user)
    end

    describe 'GET /projects/pipeline_schedules' do
      before do
        visit_pipelines_schedules
      end

      describe 'The view' do
        it 'does not show create schedule button' do
          expect(page).not_to have_link('New schedule')
        end
      end
    end
  end

  context 'not logged in' do
    describe 'GET /projects/pipeline_schedules' do
      before do
        visit_pipelines_schedules
      end

      describe 'The view' do
        it 'does not show create schedule button' do
          expect(page).not_to have_link('New schedule')
        end
      end
    end
  end

  def visit_new_pipeline_schedule
    visit new_project_pipeline_schedule_path(project, pipeline_schedule)
  end

  def edit_pipeline_schedule
    visit edit_project_pipeline_schedule_path(project, pipeline_schedule)
  end

  def visit_pipelines_schedules
    visit project_pipeline_schedules_path(project, scope: scope)
  end

  def select_timezone
    find('#schedule-timezone .gl-new-dropdown-toggle').click
    find("li", text: "Arizona").click
  end

  def select_target_branch
    click_button 'master'
  end

  def create_pipeline_schedule
    click_button s_('PipelineSchedules|Create pipeline schedule')
  end

  def save_pipeline_schedule
    click_button s_('PipelineSchedules|Edit pipeline schedule')
  end

  def fill_in_schedule_form
    fill_in 'schedule-description', with: 'my fancy description'
    fill_in 'schedule_cron', with: '* 1 2 3 4'

    select_timezone
    select_target_branch
    find('body').click # close dropdown
  end
end
