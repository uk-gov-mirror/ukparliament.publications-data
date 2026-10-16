class DataDashboardsController < PublicationsController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'Data dashboards'

  def index
    get_publications = Datagraphs::Api::GetPublications.new
    @total_count = get_publications.data_dashboards_count

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: DEFAULT_PAGE_SIZE)

    @publications = get_publications.all_data_dashboards(skip: @pagy.offset, limit: @pagy.limit)

    @crumb << { label: MAIN_PAGE_TITLE, url: nil }
    @page_title = MAIN_PAGE_TITLE
  end

  def show
    @publication_work_id = params[:id]
    get_publication = Datagraphs::Api::GetPublication.new

    @publication = get_publication.and_published_publication_details(publication_work_id: @publication_work_id)
    title = @publication.title

    sort_out_publication_details(get_publication)

    @crumb << { label: MAIN_PAGE_TITLE, url: data_dashboards_path }
    @crumb << { label: title, url: nil }
    @page_title =  title
  end

  def power_bi
    get_publications = Datagraphs::Api::GetPublications.new
    @total_count = get_publications.power_bi_data_dashboards_count

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: DEFAULT_PAGE_SIZE)

    @publications = get_publications.all_power_bi_data_dashboards(skip: @pagy.offset, limit: @pagy.limit)

    @crumb << { label: MAIN_PAGE_TITLE, url: data_dashboards_path }
    @crumb << { label: "Power BI", url: nil }
    @page_title = "Power BI Data Dashboards"

    render :index
  end

  def shiny
    get_publications = Datagraphs::Api::GetPublications.new
    @total_count = get_publications.shiny_data_dashboards_count

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: DEFAULT_PAGE_SIZE)

    @publications = get_publications.all_shiny_data_dashboards(skip: @pagy.offset, limit: @pagy.limit)

    @crumb << { label: MAIN_PAGE_TITLE, url: data_dashboards_path }
    @crumb << { label: "Shiny", url: nil }
    @page_title = "Shiny Data Dashboards"

    render :index
  end
end
