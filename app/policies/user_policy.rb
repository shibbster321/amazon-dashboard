class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def index?
    user.status == "admin"
  end

  def update?
    user.status == "admin"
  end

    def edit?
    user.status == "admin"
  end

    def destroy?
    user.status == "admin"
  end
end
