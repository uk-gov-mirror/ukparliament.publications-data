require 'ostruct'

class PublicationsController < AuthenticatedController
  include Pagy::Method
  include ApplicationHelper # For nice date time

  MAIN_PAGE_TITLE = 'Published publications'
  DEFAULT_PAGE_SIZE = 25

  def index
    get_publications = Datagraphs::Api::GetPublications.new
    @total_count = get_publications.get_total

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: DEFAULT_PAGE_SIZE)

    @publications = get_publications.all(skip: @pagy.offset, limit: @pagy.limit)

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show
    @publication_work_id = params[:id]
    get_publication = Datagraphs::Api::GetPublication.new

    @publication = get_publication.and_published_publication_details(publication_work_id: @publication_work_id)
    title = @publication.title

    sort_out_publication_details(get_publication)

    @crumb << { label: MAIN_PAGE_TITLE, url: publications_path }
    @crumb << { label: title, url: nil }
    @page_title =  title
  end

  private

  def sort_out_publication_details(get_publication = Datagraphs::Api::GetPublication.new)

    published_expression_id = @publication.published_expression_id
    expression_details = Datagraphs::Api::GetExpressionDetails.new.for(publication_expression_id: published_expression_id)

    @teaser_text = expression_details.teaser_text
    @summary = expression_details.summary

    @optional_extras = get_publication.and_optional_extras(publication_work_id: @publication_work_id)
    @related_links = get_publication.and_related_links(publication_work_id: @publication_work_id)

    # We do this differently as we need to merge the dates in there
    @disclaimers = @optional_extras.disclaimers

    @withdrawal_periods = sort_out_withdrawal_periods(@optional_extras.wps)

    @contributions = get_publication.and_contributors(publication_work_id: @publication_work_id)

    resources = get_publication.and_resources(publication_work_id: @publication_work_id)
    @resources = resources.select { |resource| resource.file_title.present? }
  end

  def sort_out_withdrawal_periods(wps)
    # Iterate through all of the withdrawal periods
    wps.map do |w|
      # Transform keys in place from camel case to underscore case
      w.transform_keys!(&:underscore)

      # Create an open struct
      OpenStruct.new(w)
    end.sort_by(&:withdrawn_at).reverse
  end
end
