class OffersController < PublicController
  def index
    redirect_to contributions_public_path
  end

  def new
    serialize(Submission.new)
  end

  def create
    submission = SubmissionForm.build submission_params

    if submission.save
      redirect_to contribution_thank_you_path, notice: 'Offer was successfully created.'
    else
      serialize(submission)
      render :new
    end
  end

  private

    def submission_params
      params[:submission].tap do |p|
        p[:form_name] = 'Offer_form'
        p[:listing_attributes][:type] = 'Offer'
        p[:location_attributes][:location_type] = LocationType.first  # FIXME: add field on form instead
      end
    end

    def serialize(submission)
      @json = {
        submission: SubmissionBlueprint.render_as_hash(submission),
        categories: CategoryBlueprint.render_as_hash(Category.visible.roots, view: :normal),
        contact_methods: ContactMethodBlueprint.render_as_hash(ContactMethod.enabled),
        service_areas: ServiceAreaBlueprint.render_as_hash(ServiceArea.all),
      }.to_json
    end
end
