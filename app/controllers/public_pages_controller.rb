# frozen_string_literal: true

# FIXME: Extract actions into separate controllers or consolidate with existing ones
class PublicPagesController < PublicController
  def about
    @about_us_text = HtmlSanitizer.new(@system_setting.about_us_text).sanitize
  end

  def contributions
    redirect_to listings_path # TODO: - change current /listings endpoint to point to this one
  end

  def landing_page
    @json = GenerateLandingPageJson.run!(
      system_setting: context.system_settings,
      organization: context.host_organization
    )
  end

  def version
    version = JSON.parse(File.read(Rails.root.join('package.json'))).dig('version')
    render json: {
      subject: 'version',
      status: version,
      color: 'blue'
    }
  end
end
