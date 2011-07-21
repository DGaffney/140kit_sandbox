class Locks < Application
  # provides :xml, :yaml, :js

  def index
    @lock = Lock.all
    display @lock
  end

  def show(id)
    @lock = Lock.get(id)
    raise NotFound unless @lock
    display @lock
  end

  def new
    only_provides :html
    @lock = Lock.new
    display @lock
  end

  def edit(id)
    only_provides :html
    @lock = Lock.get(id)
    raise NotFound unless @lock
    display @lock
  end

  def create(lock)
    @lock = Lock.new(lock)
    if @lock.save
      redirect resource(@lock), :message => {:notice => "Lock was successfully created"}
    else
      message[:error] = "Lock failed to be created"
      render :new
    end
  end

  def update(id, lock)
    @lock = Lock.get(id)
    raise NotFound unless @lock
    if @lock.update(lock)
       redirect resource(@lock), :message => {:notice => "Lock was successfully updated"}
    else
      message[:error] = "Lock failed to be updated"
      display @lock, :edit
    end
  end

  def destroy(id)
    @lock = Lock.get(id)
    raise NotFound unless @lock
    if @lock.destroy
      redirect resource(:lock), :message => {:notice => "Lock was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # Lock
