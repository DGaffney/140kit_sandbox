class Mails < Application
  # provides :xml, :yaml, :js

  def index
    @mail = Mail.all
    display @mail
  end

  def show(id)
    @mail = Mail.get(id)
    raise NotFound unless @mail
    display @mail
  end

  def new
    only_provides :html
    @mail = Mail.new
    display @mail
  end

  def edit(id)
    only_provides :html
    @mail = Mail.get(id)
    raise NotFound unless @mail
    display @mail
  end

  def create(mail)
    @mail = Mail.new(mail)
    if @mail.save
      redirect resource(@mail), :message => {:notice => "Mail was successfully created"}
    else
      message[:error] = "Mail failed to be created"
      render :new
    end
  end

  def update(id, mail)
    @mail = Mail.get(id)
    raise NotFound unless @mail
    if @mail.update(mail)
       redirect resource(@mail), :message => {:notice => "Mail was successfully updated"}
    else
      message[:error] = "Mail failed to be updated"
      display @mail, :edit
    end
  end

  def destroy(id)
    @mail = Mail.get(id)
    raise NotFound unless @mail
    if @mail.destroy
      redirect resource(:mail), :message => {:notice => "Mail was successfully deleted"}
    else
      raise InternalServerError
    end
  end

end # Mail
