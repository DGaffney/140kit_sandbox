class JaccardCoefficients < Application
  # provides :xml, :yaml, :js

  def index
    @jaccard_coefficient = JaccardCoefficient.all
    display @jaccard_coefficient
  end

  def show(id)
    @jaccard_coefficient = JaccardCoefficient.get(id)
    raise NotFound unless @jaccard_coefficient
    display @jaccard_coefficient
  end

  def new
    only_provides :html
    @jaccard_coefficient = JaccardCoefficient.new
    display @jaccard_coefficient
  end

  def edit(id)
    only_provides :html
    @jaccard_coefficient = JaccardCoefficient.get(id)
    raise NotFound unless @jaccard_coefficient
    display @jaccard_coefficient
  end

  def create(jaccard_coefficient)
    @jaccard_coefficient = JaccardCoefficient.new(jaccard_coefficient)
    if @jaccard_coefficient.save
      redirect resource(@jaccard_coefficient), :message => {:notice => "JaccardCoefficient was successfully created"}
    else
      message[:error] = "JaccardCoefficient failed to be created"
      render :new
    end
  end

  def update(id, jaccard_coefficient)
    @jaccard_coefficient = JaccardCoefficient.get(id)
    raise NotFound unless @jaccard_coefficient
    if @jaccard_coefficient.update(jaccard_coefficient)
       redirect resource(@jaccard_coefficient), :message => {:notice => "JaccardCoefficient was successfully updated"}
    else
      message[:error] = "JaccardCoefficient failed to be updated"
      display @jaccard_coefficient, :edit
    end
  end

  def destroy(id)
    @jaccard_coefficient = JaccardCoefficient.get(id)
    raise NotFound unless @jaccard_coefficient
    if @jaccard_coefficient.destroy
      redirect resource(:jaccard_coefficient), :message => {:notice => "JaccardCoefficient was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # JaccardCoefficient
