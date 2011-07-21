class Tickets < Application
  # provides :xml, :yaml, :js

  def index
    @tickets = Ticket.all
    display @tickets
  end

  def show(id)
    @ticket = Ticket.get(id)
    raise NotFound unless @ticket
    display @ticket
  end

  def new
    only_provides :html
    @ticket = Ticket.new
    display @ticket
  end

  def edit(id)
    only_provides :html
    @ticket = Ticket.get(id)
    raise NotFound unless @ticket
    display @ticket
  end

  def create(ticket)
    @ticket = Ticket.new(ticket)
    if @ticket.save
      redirect resource(@ticket), :message => {:notice => "Ticket was successfully created"}
    else
      message[:error] = "Ticket failed to be created"
      render :new
    end
  end

  def update(id, ticket)
    @ticket = Ticket.get(id)
    raise NotFound unless @ticket
    if @ticket.update(ticket)
       redirect resource(@ticket), :message => {:notice => "Ticket was successfully updated"}
    else
      message[:error] = "Ticket failed to be updated"
      display @ticket, :edit
    end
  end

  def destroy(id)
    @ticket = Ticket.get(id)
    raise NotFound unless @ticket
    if @ticket.destroy
      redirect resource(:tickets), :message => {:notice => "Ticket was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # Tickets
