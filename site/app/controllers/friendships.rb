class Friendships < Application
  # provides :xml, :yaml, :js

  def index
    @friendship = Friendship.all
    display @friendship
  end

  def show(id)
    @friendship = Friendship.get(id)
    raise NotFound unless @friendship
    display @friendship
  end

  def new
    only_provides :html
    @friendship = Friendship.new
    display @friendship
  end

  def edit(id)
    only_provides :html
    @friendship = Friendship.get(id)
    raise NotFound unless @friendship
    display @friendship
  end

  def create(friendship)
    @friendship = Friendship.new(friendship)
    if @friendship.save
      redirect resource(@friendship), :message => {:notice => "Friendship was successfully created"}
    else
      message[:error] = "Friendship failed to be created"
      render :new
    end
  end

  def update(id, friendship)
    @friendship = Friendship.get(id)
    raise NotFound unless @friendship
    if @friendship.update(friendship)
       redirect resource(@friendship), :message => {:notice => "Friendship was successfully updated"}
    else
      message[:error] = "Friendship failed to be updated"
      display @friendship, :edit
    end
  end

  def destroy(id)
    @friendship = Friendship.get(id)
    raise NotFound unless @friendship
    if @friendship.destroy
      redirect resource(:friendship), :message => {:notice => "Friendship was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # Friendship
