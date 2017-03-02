class Admin::OrdersController < ApplicationController
  layout "admin"

  before_action :authenticate_user!
  before_action :admin_required

  def index
    @orders = Order.order("id DESC")

    if params[:total].present?
      @orders = @orders.where( "total > ?", params[:total] )
    end

    if params[:ids].present?
      @orders = @orders.where( :id => params[:ids].split(",") )
    end

    if params[:status] == "pending"
      @orders = @orders.where( :aasm_state => ["order_placed", "paid"] )
    elsif params[:status] == "done"
      @orders = @orders.where.not( :aasm_state => ["order_placed", "paid"] )
    end

    if params[:date].present?
      d = Date.parse( params[:date] )
      @orders = @orders.where( :created_at => d.beginning_of_day..d.end_of_day )
    end

    @orders = @orders.paginate(:page => params[:page])
  end

  def show
    @order = Order.find(params[:id])
    @product_lists = @order.product_lists
  end

  def ship
    @order = Order.find(params[:id])
    @order.ship!
    OrderMailer.notify_ship(@order).deliver!
    redirect_to :back
  end

  def shipped
    @order = Order.find(params[:id])
    @order.deliver!
    redirect_to :back
  end

  def cancel
    @order = Order.find(params[:id])
    @order.cancell_order!
    OrderMailer.notify_cancel(@order).deliver!
    redirect_to :back
  end

  def return
    @order = Order.find(params[:id])
    @order.return_good!
    redirect_to :back
  end
end
