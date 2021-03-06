class ItemsController < ApplicationController
  before_action :authenticate, only: [:new, :create, :edit, :update]

  def index
    unless params[:search].blank?
      @items = Item.search(params[:search], hitsPerPage: 20)

      case @items.length
      when 0
        render 'not_found'
      when 1
        item = @items.first

        session[:highlight_result] = item.highlight_result
        redirect_to(item)
      else
        render 'search_results'
      end
    end
  rescue Exception #should only catch algolia relevant searches
    render 'not_found'
  end

  def new
    @item  = Item.new(name: params[:name] || nil)
    @order = @item.orders.build
  end

  def create
    @item = Item.new(item_params)
    @item.orders.first.user_id = current_user.id if @item.orders.first
    # create order separately for fined grained control. Same thing for upate?

    if @item.save
      redirect_to(@item)
    else
      render 'new'
    end
  end

  def edit
    @item  = Item.find(params[:id])
    @order = @item.orders.find_by(user: current_user)
  end

  def update
    @item  = Item.find(params[:id])
    @order = @item.orders.find_by(user: current_user)

    if @item.update(item_params)
      redirect_to(item_path(@item), notice: t(:item_update_successful))
    else
      render action: 'edit'
    end
  end

  def show
    @item = Item.find(params[:id])
    @item.highlight_result = session.delete(:highlight_result)
    @order = @item.orders.build
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path(search: Item.from_param(params[:id]))
  end

  private

  def item_params
    # if order id does not match current_user.id its a breach
    params.require(:item).permit(:name, :tag_list, :author_list, :course_list, orders_attributes: [:price, :quality, :edition, :id])
  end
end
