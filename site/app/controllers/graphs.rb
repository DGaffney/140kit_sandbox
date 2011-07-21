class Graphs < Application
  # provides :xml, :yaml, :js

  def index
    @graph = Graph.all
    display @graph
  end

  def show(id)
    @graph = Graph.get(id)
    raise NotFound unless @graph
    display @graph
  end

  def new
    only_provides :html
    @graph = Graph.new
    display @graph
  end

  def edit(id)
    only_provides :html
    @graph = Graph.get(id)
    raise NotFound unless @graph
    display @graph
  end

  def create(graph)
    @graph = Graph.new(graph)
    if @graph.save
      redirect resource(@graph), :message => {:notice => "Graph was successfully created"}
    else
      message[:error] = "Graph failed to be created"
      render :new
    end
  end

  def update(id, graph)
    @graph = Graph.get(id)
    raise NotFound unless @graph
    if @graph.update(graph)
       redirect resource(@graph), :message => {:notice => "Graph was successfully updated"}
    else
      message[:error] = "Graph failed to be updated"
      display @graph, :edit
    end
  end

  def destroy(id)
    @graph = Graph.get(id)
    raise NotFound unless @graph
    if @graph.destroy
      redirect resource(:graph), :message => {:notice => "Graph was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # Graph
