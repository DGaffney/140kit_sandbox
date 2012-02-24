class ResearchersController < ApplicationController
  def index
    # select researchers.id, count(curations.id) from researchers left join curations on curations.researcher_id = researchers.id group by researchers.id;
    @researchers = Researcher.find( :all,
                                    limit: 100,
                                    joins: "left join `curations` on curations.researcher_id = researchers.id",
                                    select: "researchers.id, researchers.name, researchers.user_name, count(curations.id) as `curations_count`",
                                    conditions: { hidden_account: false },
                                    group: "researchers.id"
                                  )
    # @researchers = Researcher.select([:id, :name, :user_name]).where(:hidden_account => false)
  end

  def show
    @researcher = Researcher.select([:id, :name, :user_name]).where(id: params[:id]).first
    @curations = @researcher.curations.select([:id, :name, :created_at])
  end
end
