class InventorysController < ApplicationController
  def index
    @inventorys = Inventory.all

  end

    def show
    @product = @product_type.products

  end

    private
  def find_product_instance
    @product = ProductType.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:title, :photo)
  end
end
