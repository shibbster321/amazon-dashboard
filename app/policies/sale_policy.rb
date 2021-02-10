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
end
