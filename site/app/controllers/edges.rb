class Edges < Application
  # provides :xml, :yaml, :js

  def index
    @edge = Edge.all
    display @edge
  end

  def show(id)
    @edge = Edge.get(id)
    raise NotFound unless @edge
    display @edge
  end

  def new
    only_provides :html
    @edge = Edge.new
    display @edge
  end

  def edit(id)
    only_provides :html
    @edge = Edge.get(id)
    raise NotFound unless @edge
    display @edge
  end

  def create(edge)
    @edge = Edge.new(edge)
    if @edge.save
      redirect resource(@edge), :message => {:notice => "Edge was successfully created"}
    else
      message[:error] = "Edge failed to be created"
      render :new
    end
  end

  def update(id, edge)
    @edge = Edge.get(id)
    raise NotFound unless @edge
    if @edge.update(edge)
       redirect resource(@edge), :message => {:notice => "Edge was successfully updated"}
    else
      message[:error] = "Edge failed to be updated"
      display @edge, :edit
    end
  end

  def destroy(id)
    @edge = Edge.get(id)
    raise NotFound unless @edge
    if @edge.destroy
      redirect resource(:edge), :message => {:notice => "Edge was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # Edge
