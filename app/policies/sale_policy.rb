class SalePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def index?
    user.status == "admin"
  end

  def subindex?
    user.status == "admin"
  end

  def amzn?
    user.status == "admin"
  end
    def etsycall?
    user.status == "admin"
  end
  def etsyauthorize?
    user.status == "admin"
  end

  def home?
    user.status == "admin"
  end

  def api?
    user.status == "admin"
  end

    def edit_data?
    user.status == "admin"
  end

    def destroy_data?
    user.status == "admin"
  end

end
