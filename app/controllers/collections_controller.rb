require 'ostruct'

class CollectionsController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'Collections'

  def index
    @collections = Datagraphs::Api::GetCollections.new.all

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show
    collection_id = params[:id]

    @collection = Datagraphs::Api::GetCollection.new.details

    get_publications = Datagraphs::Api::GetPublications.new

    @total_count = get_publications.for_a_collection_count(collection_id: collection_id)

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    @publication_works = get_publications.for_a_collection(
      collection_id: collection_id,
      lead_publication_work_id: @collection.lead_publication_work_id,
      skip: @pagy.offset,
      limit: @pagy.limit
    )

    @page_title = @collection.name

    @crumb << { label: MAIN_PAGE_TITLE, url: collections_path }
    @crumb << { label: @page_title, url: nil }
  end
end
