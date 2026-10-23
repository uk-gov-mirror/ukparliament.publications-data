require 'ostruct'

class ResearchServicesController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = "Research services"

  def index
    @research_services = Datagraphs::Api::GetResearchServices.new.all
    @page_title = MAIN_PAGE_TITLE

    @crumb << { label: @page_title, url: nil }
  end

  def show
    redirect_to publications_research_service_path(params[:id])
  end

  def publications
    research_service_id = params[:id]
    @research_service = Datagraphs::Api::GetResearchService.new.details(research_service_id)

    get_publications = Datagraphs::Api::GetPublications.new
    @total_count = get_publications.count_for_a_research_service(research_service_id)

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    @publications = get_publications.for_a_research_service(
      research_service_id: research_service_id,
      skip: @pagy.offset,
      limit: @pagy.limit
    )

    @sections = Datagraphs::Api::GetSections.new.for_a_research_service(research_service_id)

    @page_title =  @research_service.name

    @crumb << { label: 'Research services', url: research_services_path }
    @crumb << { label: @page_title, url: research_service_path(research_service_id) }
    @crumb << { label: 'Publications', url: nil }
  end

  def sections
    research_service_id = params[:id]
    @research_service = Datagraphs::Api::GetResearchService.new.details(research_service_id)

    @sections = Datagraphs::Api::GetSections.new.for_a_research_service(research_service_id)

    @page_title =  @research_service.name

    @crumb << { label: 'Research services', url: research_services_path }
    @crumb << { label: @page_title, url: research_service_path(research_service_id) }
    @crumb << { label: 'Sections', url: nil }
  end

  def promoted_concepts
    research_service_id = params[:id]
    @research_service = Datagraphs::Api::GetResearchService.new.details(research_service_id)

    get_concepts = Datagraphs::Api::GetConcepts.new

    @total_count = get_concepts.count_for_promoted_by(research_service_id: research_service_id)

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    @concepts = get_concepts.promoted_by(
      research_service_id: research_service_id,
      skip: @pagy.offset,
      limit: @pagy.limit
    )

    @page_title =  @research_service.name

    @crumb << { label: 'Research services', url: research_services_path }
    @crumb << { label: @page_title, url: research_service_path(research_service_id) }
    @crumb << { label: 'Promoted concepts', url: nil }
  end

  def promoted_collections
    research_service_id = params[:id]
    @research_service = Datagraphs::Api::GetResearchService.new.details(research_service_id)

    get_collections = Datagraphs::Api::GetCollections.new

    @total_count = get_collections.count_for_promoted_by(research_service_id: research_service_id)

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    @collections = get_collections.promoted_by(
      research_service_id: research_service_id,
      skip: @pagy.offset,
      limit: @pagy.limit
    )

    @page_title =  @research_service.name

    @crumb << { label: 'Research services', url: research_services_path }
    @crumb << { label: @page_title, url: research_service_path(research_service_id) }
    @crumb << { label: 'Promoted concepts', url: nil }
  end
end
