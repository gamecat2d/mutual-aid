# frozen_string_literal: true

class AsksController < PublicController
  def index
    redirect_to contributions_path
  end

  def new
    render_form(Submission.new)
  end

  def create
    submission = SubmissionForm.build submission_params
    if submission.save
      EmailNewSubmission.run!(
        submission: submission,
        user: context.user,
        system_setting: context.system_settings,
        organization: context.host_organization
      )
      redirect_to thank_you_path, notice: 'Ask was successfully created.'
    else
      render_form(submission)
    end
  end

  private

  def submission_params
    params[:submission].tap do |p|
      p[:form_name] = 'Ask_form'
      p[:listings_attributes][:type] = 'Ask'
    end
  end

  def render_form(submission)
    @form = Form.find_by!(contribution_type_name: 'Ask')
    @organization = context.host_organization

    @json = {
      submission: SubmissionBlueprint.render_as_hash(submission),
      configuration: ConfigurationBlueprint.render_as_hash(nil),
      form: FormBlueprint.render_as_hash(@form)
    }.to_json

    render :new
  end

  def determine_layout
    'without_navbar' unless context.system_settings.display_navbar?
  end
end
