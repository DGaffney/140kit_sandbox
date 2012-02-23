class Whitelistings < Application
  # provides :xml, :yaml, :js

  def index
    @whitelisting = Whitelisting.all
    display @whitelisting
  end

  def show(id)
    @whitelisting = Whitelisting.get(id)
    raise NotFound unless @whitelisting
    display @whitelisting
  end

  def new
    only_provides :html
    @whitelisting = Whitelisting.new
    display @whitelisting
  end

  def edit(id)
    only_provides :html
    @whitelisting = Whitelisting.get(id)
    raise NotFound unless @whitelisting
    display @whitelisting
  end

  def create(whitelisting)
    @whitelisting = Whitelisting.new(whitelisting)
    if @whitelisting.save
      redirect resource(@whitelisting), :message => {:notice => "Whitelisting was successfully created"}
    else
      message[:error] = "Whitelisting failed to be created"
      render :new
    end
  end

  def update(id, whitelisting)
    @whitelisting = Whitelisting.get(id)
    raise NotFound unless @whitelisting
    if @whitelisting.update(whitelisting)
       redirect resource(@whitelisting), :message => {:notice => "Whitelisting was successfully updated"}
    else
      message[:error] = "Whitelisting failed to be updated"
      display @whitelisting, :edit
    end
  end

  def destroy(id)
    @whitelisting = Whitelisting.get(id)
    raise NotFound unless @whitelisting
    if @whitelisting.destroy
      redirect resource(:whitelisting), :message => {:notice => "Whitelisting was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # Whitelisting
