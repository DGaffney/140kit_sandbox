class GraphPoints < Application
  # provides :xml, :yaml, :js

  def index
    @graph_point = GraphPoint.all
    display @graph_point
  end

  def show(id)
    @graph_point = GraphPoint.get(id)
    raise NotFound unless @graph_point
    display @graph_point
  end

  def new
    only_provides :html
    @graph_point = GraphPoint.new
    display @graph_point
  end

  def edit(id)
    only_provides :html
    @graph_point = GraphPoint.get(id)
    raise NotFound unless @graph_point
    display @graph_point
  end

  def create(graph_point)
    @graph_point = GraphPoint.new(graph_point)
    if @graph_point.save
      redirect resource(@graph_point), :message => {:notice => "GraphPoint was successfully created"}
    else
      message[:error] = "GraphPoint failed to be created"
      render :new
    end
  end

  def update(id, graph_point)
    @graph_point = GraphPoint.get(id)
    raise NotFound unless @graph_point
    if @graph_point.update(graph_point)
       redirect resource(@graph_point), :message => {:notice => "GraphPoint was successfully updated"}
    else
      message[:error] = "GraphPoint failed to be updated"
      display @graph_point, :edit
    end
  end

  def destroy(id)
    @graph_point = GraphPoint.get(id)
    raise NotFound unless @graph_point
    if @graph_point.destroy
      redirect resource(:graph_point), :message => {:notice => "GraphPoint was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # GraphPoint
