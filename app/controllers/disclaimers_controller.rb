class DisclaimersController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'Disclaimers'

  def index
    @disclaimers = Datagraphs::Api::GetDisclaimers.new.all

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show
    disclaimer_id = params[:id]

    @disclaimer = Datagraphs::Api::GetDisclaimer.new.details(disclaimer_id: disclaimer_id)

    @total_count = Datagraphs::Api::GetPublications.new.for_a_disclaimer_count(disclaimer_id: disclaimer_id)

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    @publication_works = Datagraphs::Api::GetPublications.new.for_a_disclaimer(
      disclaimer_id: disclaimer_id,
      skip: @pagy.offset,
      limit: @pagy.limit
    )

    @page_title = @disclaimer.label

    @crumb << { label: MAIN_PAGE_TITLE, url: disclaimers_path }
    @crumb << { label: @page_title, url: nil }
  end
end
