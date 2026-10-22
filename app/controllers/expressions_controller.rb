class ExpressionsController < AuthenticatedController
  include Pagy::Method

  MAIN_PAGE_TITLE = 'Publication expressions'

  def index
    @publication_work_id = params[:publication_id]

    get_expressions = Datagraphs::Api::GetExpressions.new

    # These are the available statuses
    @statuses = get_expressions.statuses(publication_work_id: @publication_work_id)

    # If none set in form, default to all available
    @selected_statuses = params[:statuses] || @statuses

    @total_count = get_expressions.count_for_statuses(publication_work_id: @publication_work_id, selected_statuses: @selected_statuses)

    publication = Datagraphs::Api::GetPublication.new.details(publication_work_id: @publication_work_id).first
    @publication = Hashie::Mash.new(publication)

    @pagy, _ = pagy(:offset, [], count: @total_count, page: params[:page], limit: 25)

    @expressions = get_expressions.for_work_id_and_statuses(
      publication_work_id: @publication_work_id,
      skip: @pagy.offset,
      limit: @pagy.limit,
      selected_statuses: @selected_statuses
    )

    @published_expression = Datagraphs::Api::GetExpression.new.published_for(publication_work_id: @publication_work_id)

    # We get these via the API to avoid Cypher query limits to fields
    expression_details = Datagraphs::Api::GetExpressionDetails.new.for(publication_expression_id: @published_expression.id)

    @page_title = @publication.title == 'Untitled' ? @expressions.first.title : @publication.title

    @teaser_text = expression_details.teaser_text
    @summary = expression_details.summary

    @crumb << { label: "Publications", url: publications_path }
    @crumb << { label: @page_title, url: publication_path(@publication.id) }
    @crumb << { label: "Expressions", url: nil }
  end

  def show
    expression_id = params[:id]

    get_expression = Datagraphs::Api::GetExpression.new

    @expression = get_expression.details(expression_id: expression_id)
    expression_details = Datagraphs::Api::GetExpressionDetails.new.for(publication_expression_id: @expression.id)

    @teaser_text = expression_details.teaser_text
    @summary = expression_details.summary

    @resources = get_expression.resources(expression_id: expression_id)
    @related_links = get_expression.related_links(expression_id: expression_id)
    @contributors = get_expression.contributors(expression_id: expression_id)
    @sections = get_expression.sections(expression_id: expression_id)

    title = @expression.title

    @crumb << { label: "Published publications", url: publications_path }
    @crumb << { label: @expression.title, url: publication_path(@expression.publication_work_id) }
    @crumb << { label: "Expressions", url: publication_expressions_path(@expression.publication_work_id) }

    @crumb << { label: "Version: #{@expression.version_number}", url: nil }

    @page_title =  title
  end
end
